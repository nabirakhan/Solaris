import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String email;
  final String? userId;

  const OTPVerificationScreen({
    Key? key,
    required this.email,
    this.userId,
  }) : super(key: key);

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final List<TextEditingController> _otpControllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(6, (index) => FocusNode());

  bool _isLoading = false;
  bool _isResending = false;
  String? _errorMessage;
  int _countdown = 0;
  Timer? _timer;
  int _attemptsRemaining = 3;

  @override
  void initState() {
    super.initState();
    _startCountdown(60);
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startCountdown(int seconds) {
    setState(() => _countdown = seconds);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          timer.cancel();
        }
      });
    });
  }

   Future<void> _verifyOTP() async {
  final otp = _otpControllers.map((c) => c.text).join();

  if (otp.length != 6) {
    setState(() => _errorMessage = 'Please enter all 6 digits');
    return;
  }

  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });

  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  final result = await authProvider.verifyOTP(
    email: widget.email,
    otp: otp,
  );

  setState(() => _isLoading = false);

  if (result['success'] == true && mounted) {
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text('Email verified successfully!'),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    // Navigate to home after short delay
    await Future.delayed(Duration(milliseconds: 500));
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  } else if (mounted) {
    setState(() {
      _errorMessage = result['error'] ?? 'Invalid verification code';
    });
    // Clear OTP fields on error
    for (var controller in _otpControllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }
}

  Future<void> _resendOTP() async {
    if (_countdown > 0) return;

    setState(() {
      _isResending = true;
      _errorMessage = null;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final result = await authProvider.resendOTP(email: widget.email);

    setState(() => _isResending = false);

    if (result['success'] == true) {
      setState(() {
        _attemptsRemaining = result['attemptsRemaining'] ?? 2;
      });
      _startCountdown(60);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.email, color: Colors.white),
                SizedBox(width: 12),
                Text('New code sent! Check your email.'),
              ],
            ),
            backgroundColor: AppTheme.primaryPink,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } else {
      setState(() {
        _errorMessage = result['error'] ?? 'Failed to resend code';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.almostWhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.primaryPink),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Verify Email',
          style: TextStyle(
            color: AppTheme.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Envelope Icon
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryPink,
                        AppTheme.primaryPurple,
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.email_outlined,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Title
              Text(
                'Check your email',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 12),

              // Subtitle
              Text(
                'We sent a 6-digit verification code to:',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textGray,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.email,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryPink,
                ),
              ),

              const SizedBox(height: 40),

              // OTP Input Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 50,
                    child: TextField(
                      controller: _otpControllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppTheme.borderGray,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppTheme.borderGray,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppTheme.primaryPink,
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 5) {
                          _focusNodes[index + 1].requestFocus();
                        } else if (value.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }

                        // Auto-verify when all 6 digits are entered
                        if (index == 5 && value.isNotEmpty) {
                          _verifyOTP();
                        }
                      },
                    ),
                  );
                }),
              ),

              const SizedBox(height: 24),

              // Error Message
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[300]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 32),

              // Verify Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOTP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryPink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Verify Email',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 24),

              // Resend Code Section
              Center(
                child: _countdown > 0
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            size: 18,
                            color: AppTheme.textGray,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Resend code in ${_countdown}s',
                            style: TextStyle(
                              color: AppTheme.textGray,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      )
                    : TextButton(
                        onPressed: _isResending ? null : _resendOTP,
                        child: _isResending
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppTheme.primaryPink,
                                  ),
                                ),
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.refresh,
                                    size: 18,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Resend code ($_attemptsRemaining attempts left)',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.primaryPink,
                        ),
                      ),
              ),

              const SizedBox(height: 16),

              // Help Text
              Center(
                child: Text(
                  'Didn\'t receive the code? Check your spam folder',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textGray,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}