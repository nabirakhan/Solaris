const { createClient } = require('@supabase/supabase-js');

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_KEY; // Use service role key for server-side

if (!supabaseUrl || !supabaseKey) {
  console.error('❌ Missing Supabase credentials in environment variables');
  console.error('   Please set SUPABASE_URL and SUPABASE_SERVICE_KEY in your .env file');
}

const supabase = createClient(supabaseUrl, supabaseKey);

/**
 * Upload profile picture to Supabase Storage
 * @param {string} userId - User ID
 * @param {Buffer} fileBuffer - Image file buffer
 * @param {string} fileName - Original filename
 * @param {string} mimeType - File MIME type
 * @returns {Promise<string>} - Public URL of uploaded image
 */
async function uploadProfilePicture(userId, fileBuffer, fileName, mimeType) {
  try {
    console.log('📤 Uploading profile picture to Supabase Storage...');
    console.log('   User ID:', userId);
    console.log('   File:', fileName);
    console.log('   Size:', fileBuffer.length, 'bytes');

    // Generate unique filename
    const fileExt = fileName.split('.').pop();
    const timestamp = Date.now();
    const filePath = `${userId}/profile-${timestamp}.${fileExt}`;

    // Delete old profile picture if exists (keeps storage clean)
    await deleteUserProfilePictures(userId);

    // Upload to Supabase Storage
    const { data, error } = await supabase.storage
      .from('profile-pictures')
      .upload(filePath, fileBuffer, {
        contentType: mimeType,
        cacheControl: '3600',
        upsert: false
      });

    if (error) {
      console.error('❌ Supabase upload error:', error);
      throw new Error(`Upload failed: ${error.message}`);
    }

    // Get public URL
    const { data: { publicUrl } } = supabase.storage
      .from('profile-pictures')
      .getPublicUrl(filePath);

    console.log('✅ Image uploaded successfully to Supabase Storage');
    console.log('   Public URL:', publicUrl);

    return publicUrl;

  } catch (error) {
    console.error('❌ Error uploading to Supabase Storage:', error);
    throw error;
  }
}

/**
 * Delete all profile pictures for a user
 * @param {string} userId - User ID
 */
async function deleteUserProfilePictures(userId) {
  try {
    // List all files in user's folder
    const { data: files, error: listError } = await supabase.storage
      .from('profile-pictures')
      .list(userId);

    if (listError) {
      console.error('⚠️ Error listing files:', listError);
      return;
    }

    if (files && files.length > 0) {
      console.log(`🗑️ Deleting ${files.length} old profile picture(s) for user ${userId}...`);
      
      // Delete all files
      const filePaths = files.map(file => `${userId}/${file.name}`);
      const { error: deleteError } = await supabase.storage
        .from('profile-pictures')
        .remove(filePaths);

      if (deleteError) {
        console.error('⚠️ Error deleting old files:', deleteError);
      } else {
        console.log('✅ Deleted old profile pictures');
      }
    }
  } catch (error) {
    console.error('⚠️ Error in deleteUserProfilePictures:', error);
    // Don't throw - this is a cleanup operation
  }
}

/**
 * Delete a specific profile picture by URL
 * @param {string} publicUrl - Public URL of the image
 */
async function deleteProfilePictureByUrl(publicUrl) {
  try {
    // Extract file path from URL
    // URL format: https://xxx.supabase.co/storage/v1/object/public/profile-pictures/userId/filename
    const urlParts = publicUrl.split('/profile-pictures/');
    if (urlParts.length < 2) {
      console.error('⚠️ Invalid Supabase URL format:', publicUrl);
      return;
    }

    const filePath = urlParts[1];
    console.log('🗑️ Deleting profile picture:', filePath);

    const { error } = await supabase.storage
      .from('profile-pictures')
      .remove([filePath]);

    if (error) {
      console.error('⚠️ Error deleting file:', error);
    } else {
      console.log('✅ Deleted profile picture');
    }
  } catch (error) {
    console.error('⚠️ Error in deleteProfilePictureByUrl:', error);
  }
}

/**
 * Get storage usage for a user
 * @param {string} userId - User ID
 * @returns {Promise<{fileCount: number, totalSize: number}>}
 */
async function getUserStorageInfo(userId) {
  try {
    const { data: files, error } = await supabase.storage
      .from('profile-pictures')
      .list(userId);

    if (error) {
      console.error('Error getting storage info:', error);
      return { fileCount: 0, totalSize: 0 };
    }

    const fileCount = files ? files.length : 0;
    const totalSize = files ? files.reduce((sum, file) => sum + (file.metadata?.size || 0), 0) : 0;

    return { fileCount, totalSize };
  } catch (error) {
    console.error('Error in getUserStorageInfo:', error);
    return { fileCount: 0, totalSize: 0 };
  }
}

/**
 * Check if Supabase Storage is properly configured
 * @returns {Promise<boolean>}
 */
async function checkStorageHealth() {
  try {
    // Try to list buckets
    const { data, error } = await supabase.storage.listBuckets();
    
    if (error) {
      console.error('❌ Supabase Storage health check failed:', error);
      return false;
    }

    const hasProfileBucket = data.some(bucket => bucket.name === 'profile-pictures');
    
    if (!hasProfileBucket) {
      console.warn('⚠️ Profile-pictures bucket not found. Please create it in Supabase dashboard.');
      return false;
    }

    console.log('✅ Supabase Storage is healthy');
    return true;
  } catch (error) {
    console.error('❌ Error checking Supabase Storage health:', error);
    return false;
  }
}

module.exports = {
  uploadProfilePicture,
  deleteUserProfilePictures,
  deleteProfilePictureByUrl,
  getUserStorageInfo,
  checkStorageHealth
};