// File: backend/routes/insights.js
const express = require('express');
const router = express.Router();
const axios = require('axios');
const AIInsight = require('../models/AIInsight');
const Cycle = require('../models/Cycle');
const SymptomLog = require('../models/SymptomLog');
const auth = require('../middleware/auth');
const { pool } = require('../config/database');

// Get current cycle insights with AI predictions
router.get('/current', auth, async (req, res) => {
  try {
    const cycles = await Cycle.findByUserId(req.userId, 10);

    if (cycles.length === 0) {
      return res.json({
        message: 'No cycle data yet',
        currentPhase: 'unknown',
        hasData: false
      });
    }

    const latestCycle = cycles[0];
    const today = new Date();
    const startDate = new Date(latestCycle.start_date);
    const daysSinceStart = Math.floor((today - startDate) / (1000 * 60 * 60 * 24));

    const stats = await Cycle.getAverageCycleLength(req.userId);
    const avgCycleLength = stats.avg_length ? parseFloat(stats.avg_length) : 28;

    // Determine current phase
    let currentPhase = 'unknown';
    if (daysSinceStart >= 0 && daysSinceStart <= 5) {
      currentPhase = 'menstrual';
    } else if (daysSinceStart > 5 && daysSinceStart <= 13) {
      currentPhase = 'follicular';
    } else if (daysSinceStart > 13 && daysSinceStart <= 17) {
      currentPhase = 'ovulation';
    } else {
      currentPhase = 'luteal';
    }

    // Try to get AI prediction
    let aiInsights = null;
    try {
      const cyclesForAI = await Cycle.getForAnalysis(req.userId, 10);
      const symptoms = await SymptomLog.getForAnalysis(req.userId, 90);
      
      // Get health metrics
      const healthResult = await pool.query(
        'SELECT birthdate, height, weight, use_metric FROM health_metrics WHERE user_id = $1',
        [req.userId]
      );
      const healthMetrics = healthResult.rows[0] || null;

      if (cyclesForAI.length >= 2) {
        const response = await axios.post(
          `${process.env.AI_SERVICE_URL}/analyze`,
          {
            userId: req.userId,
            cycles: cyclesForAI.map(c => ({
              startDate: c.start_date,
              endDate: c.end_date,
              cycleLength: c.cycle_length,
              flow: c.flow
            })),
            symptoms: symptoms.map(s => ({
              date: s.date,
              symptoms: s.symptoms,
              sleepHours: s.sleep_hours,
              stressLevel: s.stress_level
            })),
            healthMetrics: healthMetrics ? {
              birthdate: healthMetrics.birthdate,
              height: parseFloat(healthMetrics.height),
              weight: parseFloat(healthMetrics.weight),
              useMetric: healthMetrics.use_metric
            } : null
          },
          { timeout: 15000 }
        );
        aiInsights = response.data;

        // Save to database
        await AIInsight.create({
          userId: req.userId,
          insightType: 'comprehensive_analysis',
          prediction: aiInsights.prediction,
          anomaly: aiInsights.anomaly,
          cycleData: {
            cycleInsights: aiInsights.cycleInsights,
            symptomInsights: aiInsights.symptomInsights,
            healthInsights: aiInsights.healthInsights,
            recommendations: aiInsights.recommendations
          },
          shouldDisplay: true,
          displayPriority: aiInsights.riskAssessment?.level === 'high' ? 10 : 5
        });
      }
    } catch (aiError) {
      console.log('AI service error:', aiError.message);
    }

    // Baseline prediction
    const nextPeriodDate = new Date(startDate);
    nextPeriodDate.setDate(nextPeriodDate.getDate() + Math.round(avgCycleLength));

    const response = {
      hasData: true,
      currentPhase,
      daysSinceStart,
      avgCycleLength: Math.round(avgCycleLength),
      latestCycleStart: latestCycle.start_date,
      totalCycles: cycles.length,
      regularityScore: stats.std_dev ? Math.max(0, 1 - (parseFloat(stats.std_dev) / avgCycleLength)) : null,
    };

    if (aiInsights) {
      response.prediction = aiInsights.prediction;
      response.anomaly = aiInsights.anomaly;
      response.cycleInsights = aiInsights.cycleInsights;
      response.symptomInsights = aiInsights.symptomInsights;
      response.healthInsights = aiInsights.healthInsights;
      response.recommendations = aiInsights.recommendations;
      response.riskAssessment = aiInsights.riskAssessment;
      response.personalizedInsights = aiInsights.personalizedInsights;
    } else {
      response.prediction = {
        nextPeriodDate,
        confidence: cycles.length >= 3 ? 0.7 : 0.4,
        method: 'baseline',
        predictionQuality: cycles.length >= 3 ? 'Moderate - Based on averages' : 'Low - Need more data'
      };
    }

    res.json(response);
  } catch (error) {
    console.error('Get current insights error:', error);
    res.status(500).json({ error: error.message });
  }
});

// Request comprehensive AI analysis
router.post('/analyze', auth, async (req, res) => {
  try {
    const cycles = await Cycle.getForAnalysis(req.userId, 12);
    const symptoms = await SymptomLog.getForAnalysis(req.userId, 90);

    if (cycles.length < 2) {
      return res.json({
        success: false,
        message: 'Not enough data for AI analysis. Please log at least 2 complete cycles.',
        hasData: false
      });
    }

    try {
      // Get health metrics
      const healthResult = await pool.query(
        'SELECT birthdate, height, weight, use_metric FROM health_metrics WHERE user_id = $1',
        [req.userId]
      );
      const healthMetrics = healthResult.rows[0] || null;

      const response = await axios.post(
        `${process.env.AI_SERVICE_URL}/analyze`,
        {
          userId: req.userId,
          cycles: cycles.map(c => ({
            startDate: c.start_date,
            endDate: c.end_date,
            cycleLength: c.cycle_length,
            flow: c.flow
          })),
          symptoms: symptoms.map(s => ({
            date: s.date,
            symptoms: s.symptoms,
            sleepHours: s.sleep_hours,
            stressLevel: s.stress_level
          })),
          healthMetrics: healthMetrics ? {
            birthdate: healthMetrics.birthdate,
            height: parseFloat(healthMetrics.height),
            weight: parseFloat(healthMetrics.weight),
            useMetric: healthMetrics.use_metric
          } : null
        },
        { timeout: 15000 }
      );

      const aiData = response.data;

      // Save insight
      await AIInsight.create({
        userId: req.userId,
        insightType: 'comprehensive_analysis',
        prediction: aiData.prediction,
        anomaly: aiData.anomaly,
        cycleData: {
          cycleInsights: aiData.cycleInsights,
          symptomInsights: aiData.symptomInsights,
          healthInsights: aiData.healthInsights,
          recommendations: aiData.recommendations,
          riskAssessment: aiData.riskAssessment
        },
        shouldDisplay: true,
        displayPriority: aiData.riskAssessment?.level === 'high' ? 10 : 5
      });

      res.json({
        success: true,
        message: 'AI analysis complete',
        hasData: true,
        ...aiData
      });
    } catch (aiError) {
      console.error('AI service error:', aiError.message);
      
      // Return baseline prediction as fallback
      const stats = await Cycle.getAverageCycleLength(req.userId);
      const avgLength = stats.avg_length ? parseFloat(stats.avg_length) : 28;
      
      const latestCycle = cycles[0];
      const nextPeriodDate = new Date(latestCycle.start_date);
      nextPeriodDate.setDate(nextPeriodDate.getDate() + Math.round(avgLength));

      res.json({
        success: true,
        message: 'Using baseline predictions (AI service unavailable)',
        hasData: true,
        prediction: {
          nextPeriodDate,
          confidence: cycles.length >= 3 ? 0.6 : 0.3,
          method: 'baseline',
          predictionQuality: 'Moderate - Based on averages'
        }
      });
    }
  } catch (error) {
    console.error('Analyze error:', error);
    res.status(500).json({ error: error.message });
  }
});

// Get insight history
router.get('/history', auth, async (req, res) => {
  try {
    const limit = parseInt(req.query.limit) || 30;
    const insights = await AIInsight.findByUserId(req.userId, limit);
    res.json({ insights });
  } catch (error) {
    console.error('Get insights history error:', error);
    res.status(500).json({ error: error.message });
  }
});

// Get unviewed insights
router.get('/unviewed', auth, async (req, res) => {
  try {
    const insights = await AIInsight.getUnviewed(req.userId);
    res.json({ insights });
  } catch (error) {
    console.error('Get unviewed insights error:', error);
    res.status(500).json({ error: error.message });
  }
});

// Mark insight as viewed
router.put('/:id/viewed', auth, async (req, res) => {
  try {
    const insight = await AIInsight.markAsViewed(req.params.id, req.userId);

    if (!insight) {
      return res.status(404).json({ error: 'Insight not found' });
    }

    res.json({ message: 'Insight marked as viewed', insight });
  } catch (error) {
    console.error('Mark insight viewed error:', error);
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;