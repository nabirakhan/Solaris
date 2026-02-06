// File: lib/widgets/profile_picture_picker.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_theme.dart';

class ProfilePicturePicker extends StatefulWidget {
  final String? currentImageUrl;
  final Function(File) onImageSelected;
  final double size;
  
  const ProfilePicturePicker({
    Key? key,
    this.currentImageUrl,
    required this.onImageSelected,
    this.size = 120,
  }) : super(key: key);

  @override
  State<ProfilePicturePicker> createState() => _ProfilePicturePickerState();
}

class _ProfilePicturePickerState extends State<ProfilePicturePicker> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  String? _webImageUrl;
  bool _isLoading = false;

  Future<void> _pickImage(ImageSource source) async {
    try {
      setState(() => _isLoading = true);
      
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      
      if (image != null) {
        print('📸 Image picked: ${image.path}');
        
        // For web, we need to handle differently
        if (image.path.startsWith('http')) {
          // Web platform - use network image
          setState(() {
            _webImageUrl = image.path;
            _isLoading = false;
          });
          widget.onImageSelected(File(''));
        } else {
          // Mobile platform - use File
          final File imageFile = File(image.path);
          setState(() {
            _selectedImage = imageFile;
            _isLoading = false;
          });
          widget.onImageSelected(imageFile);
        }
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('❌ Error picking image: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            child: Wrap(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Choose Profile Picture',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 20),
                      if (!_isWebPlatform)
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.blushPink,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: AppTheme.primaryPink,
                            ),
                          ),
                          title: const Text('Take Photo'),
                          onTap: () {
                            Navigator.pop(context);
                            _pickImage(ImageSource.camera);
                          },
                        ),
                      ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.blushPink,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.photo_library,
                            color: AppTheme.primaryPink,
                          ),
                        ),
                        title: const Text('Choose from Gallery'),
                        onTap: () {
                          Navigator.pop(context);
                          _pickImage(ImageSource.gallery);
                        },
                      ),
                      if (widget.currentImageUrl != null || _selectedImage != null || _webImageUrl != null)
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                          ),
                          title: const Text('Remove Photo'),
                          onTap: () {
                            Navigator.pop(context);
                            setState(() {
                              _selectedImage = null;
                              _webImageUrl = null;
                            });
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool get _isWebPlatform {
    return identical(0, 0.0);
  }

  // Helper method to get complete image URL
  String _getCompleteImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    
    print('🖼️ Processing URL: $url');
    
    // If it's already a data URL or full URL, return as is
    if (url.startsWith('data:image/') || 
        url.startsWith('http://') || 
        url.startsWith('https://')) {
      print('✅ URL is complete: $url');
      return url;
    }
    
    // If it's a relative URL, prepend the base URL
    if (url.startsWith('/')) {
      final completeUrl = 'https://solaris-vhc8.onrender.com$url';
      print('✅ Converted relative URL to: $completeUrl');
      return completeUrl;
    }
    
    print('⚠️ Unknown URL format: $url');
    return url;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showImageSourceDialog,
      child: Stack(
        children: [
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.primaryPink,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryPink.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipOval(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.primaryPink,
                        ),
                      ),
                    )
                  : _buildImageWidget(),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryPink,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryPink.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageWidget() {
    // Handle web platform first
    if (_webImageUrl != null && _webImageUrl!.isNotEmpty) {
      print('🖼️ Displaying web image URL');
      return Image.network(
        _webImageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('❌ Web image error: $error');
          return _buildDefaultAvatar();
        },
      );
    }
    // Handle mobile platform selected image
    else if (_selectedImage != null) {
      print('🖼️ Displaying selected file image');
      if (_isWebPlatform) {
        return _buildDefaultAvatar();
      } else {
        return Image.file(
          _selectedImage!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('❌ File image error: $error');
            return _buildDefaultAvatar();
          },
        );
      }
    }
    // Handle existing URL (from backend)
    else if (widget.currentImageUrl != null && widget.currentImageUrl!.isNotEmpty) {
      final imageUrl = _getCompleteImageUrl(widget.currentImageUrl);
      
      // Check if it's a data URL (base64 image)
      if (imageUrl.startsWith('data:image/')) {
        print('🖼️ Processing data URL image');
        try {
          final uri = Uri.parse(imageUrl);
          if (uri.data != null) {
            return Image.memory(
              uri.data!.contentAsBytes(),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                print('❌ Error loading data URL image: $error');
                return _buildDefaultAvatar();
              },
            );
          }
        } catch (e) {
          print('❌ Error parsing data URL: $e');
          return _buildDefaultAvatar();
        }
      }
      
      // Regular network URL - use Image.network for better error handling
      print('🖼️ Processing network URL: $imageUrl');
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryPink),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          print('❌ Network image error: $error');
          print('❌ URL: $imageUrl');
          print('❌ Stack trace: $stackTrace');
          return _buildDefaultAvatar();
        },
      );
    }
    // Default avatar
    else {
      print('🖼️ Displaying default avatar');
      return _buildDefaultAvatar();
    }
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: AppTheme.blushPink,
      child: const Center(
        child: Icon(
          Icons.person,
          size: 60,
          color: AppTheme.primaryPink,
        ),
      ),
    );
  }
}