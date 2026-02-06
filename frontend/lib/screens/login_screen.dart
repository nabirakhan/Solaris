import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../config/constants.dart';
import 'otp_verification_screen.dart'; 

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoginMode = true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: AppConstants.slowAnimation,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
      _animationController.reset();
      _animationController.forward();
    });
  }

  Future<void> _handleEmailAuth() async {
  if (!_formKey.currentState!.validate()) return;

  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  Map<String, dynamic> result;

  if (_isLoginMode) {
    result = await authProvider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  } else {
    result = await authProvider.signup(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      name: _emailController.text.split('@')[0],
    );
  }

  if (result['success'] == true && mounted) {
    if (_isLoginMode) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      // For signup, navigate to OTP screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => OTPVerificationScreen(
            email: _emailController.text.trim(),
            userId: result['userId'],
          ),
        ),
      );
    }
  } else if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['error'] ?? 'Authentication failed'),
        backgroundColor: AppConstants.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(AppConstants.borderRadiusMedium),
        ),
      ),
    );
  }
}

Future<void> _handleGoogleSignIn() async {
  final authProvider = Provider.of<AuthProvider>(context, listen: false);

  final result = await authProvider.signInWithGoogle();

  if (result['success'] == true && mounted) {
    Navigator.of(context).pushReplacementNamed('/home');
  } else if (mounted && result['error'] != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['error']!),
        backgroundColor: AppConstants.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(AppConstants.borderRadiusMedium),
        ),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppConstants.primaryGradient,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLogo(),
                      const SizedBox(height: AppConstants.paddingXLarge),
                      _buildLoginCard(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Hero(
      tag: 'app_logo',
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: FutureBuilder<Widget>(
          future: _loadLogoImage(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              );
            } else if (snapshot.hasError) {
              print('❌ Logo Error: ${snapshot.error}');
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error,
                      color: Colors.white,
                      size: 40,
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Image Error\nCheck Console',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            } else {
              return snapshot.data ?? _buildFallbackIcon();
            }
          },
        ),
      ),
    );
  }

  Future<Widget> _loadLogoImage() async {
    try {
      // Try to load the image
      final image = AssetImage('assets/icons/solaris_logo.png');

      // Check if asset bundle can load it
      try {
        await rootBundle.load('assets/icons/solaris_logo.png');
        print('✅ Asset loaded successfully from bundle');
      } catch (e) {
        print('❌ Bundle error: $e');
        throw Exception(
            'Asset not found in bundle: assets/icons/solaris_logo.png');
      }

      return Padding(
        padding: const EdgeInsets.all(5),
        child: ClipOval(
          child: Image(
            image: image,
            fit: BoxFit.contain,
          ),
        ),
      );
    } catch (e) {
      print('❌ Image loading error: $e');
      rethrow;
    }
  }

  Widget _buildFallbackIcon() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite,
            size: AppConstants.iconSizeXLarge * 1.5,
            color: Colors.white,
          ),
          SizedBox(height: 5),
          Text(
            'Using Fallback Icon',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginCard() {
    return Card(
      elevation: AppConstants.elevationHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusXLarge),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _isLoginMode ? 'Welcome Back!' : 'Create Account',
                style: AppConstants.headingMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.paddingSmall),
              Text(
                _isLoginMode
                    ? 'Sign in to continue tracking'
                    : 'Join Solaris to start your journey',
                style: AppConstants.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.paddingLarge),
              _buildEmailField(),
              const SizedBox(height: AppConstants.paddingMedium),
              _buildPasswordField(),
              const SizedBox(height: AppConstants.paddingLarge),
              _buildSubmitButton(),
              const SizedBox(height: AppConstants.paddingMedium),
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingMedium,
                    ),
                    child: Text(
                      'OR',
                      style: AppConstants.bodySmall,
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: AppConstants.paddingMedium),
              _buildGoogleButton(),
              const SizedBox(height: AppConstants.paddingLarge),
              _buildToggleButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'Email',
        prefixIcon: const Icon(Icons.email_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        ),
        filled: true,
        fillColor: AppConstants.backgroundColor,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email';
        }
        if (!value.contains('@')) {
          return 'Please enter a valid email';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: 'Password',
        prefixIcon: const Icon(Icons.lock_outlined),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        ),
        filled: true,
        fillColor: AppConstants.backgroundColor,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        if (!_isLoginMode && value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
    );
  }

  Widget _buildSubmitButton() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return AnimatedContainer(
          duration: AppConstants.fastAnimation,
          height: 56,
          child: ElevatedButton(
            onPressed: authProvider.isLoading ? null : _handleEmailAuth,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
              elevation: AppConstants.elevationMedium,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppConstants.borderRadiusMedium),
              ),
            ),
            child: authProvider.isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    _isLoginMode ? 'Sign In' : 'Sign Up',
                    style: AppConstants.buttonText,
                  ),
          ),
        );
      },
    );
  }

  Widget _buildGoogleButton() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return OutlinedButton.icon(
          onPressed: authProvider.isLoading ? null : _handleGoogleSignIn,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            side: BorderSide(
              color: AppConstants.primaryColor.withOpacity(0.5),
            ),
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(AppConstants.borderRadiusMedium),
            ),
          ),
          icon: Image.asset(
            'assets/images/google_logo.png',
            height: 24,
            width: 24,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.login, color: AppConstants.primaryColor);
            },
          ),
          label: const Text(
            'Continue with Google',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppConstants.textPrimary,
            ),
          ),
        );
      },
    );
  }

  Widget _buildToggleButton() {
    return TextButton(
      onPressed: _toggleMode,
      child: RichText(
        text: TextSpan(
          style: AppConstants.bodyMedium,
          children: [
            TextSpan(
              text: _isLoginMode
                  ? "Don't have an account? "
                  : "Already have an account? ",
            ),
            TextSpan(
              text: _isLoginMode ? 'Sign Up' : 'Sign In',
              style: const TextStyle(
                color: AppConstants.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
