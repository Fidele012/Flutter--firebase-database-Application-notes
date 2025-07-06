import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  // Custom email validation
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final email = value.trim();
    
    // Check if email is empty after trimming
    if (email.isEmpty) {
      return 'Email cannot be empty';
    }

    // Check if email contains uppercase letters
    if (email != email.toLowerCase()) {
      return 'Email must be in lowercase letters only';
    }

    // Check basic email format
    if (!email.contains('@')) {
      return 'Email must contain @ symbol';
    }

    // Split email into local and domain parts
    final parts = email.split('@');
    if (parts.length != 2) {
      return 'Invalid email format';
    }

    final localPart = parts[0];
    final domain = parts[1];

    // Check if local part is empty
    if (localPart.isEmpty) {
      return 'Email username cannot be empty';
    }

    // Check if local part contains only lowercase letters and numbers
    final localPartRegex = RegExp(r'^[a-z0-9]+$');
    if (!localPartRegex.hasMatch(localPart)) {
      return 'Email username must contain only lowercase letters and numbers';
    }

    // Check if domain is gmail.com or yahoo.com
    if (domain != 'gmail.com' && domain != 'yahoo.com') {
      return 'Email must be from Gmail or Yahoo (gmail.com or yahoo.com)';
    }

    return null;
  }

  // Custom password validation
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    final password = value;

    // Check minimum length
    if (password.length < 6) {
      return 'Password must be at least 6 characters long';
    }

    // Check for uppercase letters
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    // Check for lowercase letters
    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }

    // Check for numbers
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    // Check for symbols/special characters
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one symbol (!@#\$%^&*(),.?":{}|<>)';
    }

    return null;
  }

  // Custom confirm password validation
  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }

    return null;
  }

  // Get user-friendly error messages for Firebase errors
  String _getFirebaseErrorMessage(String errorCode) {
    switch (errorCode.toLowerCase()) {
      case 'email-already-in-use':
        return 'This email is already registered. Please use a different email or sign in instead.';
      case 'invalid-email':
        return 'The email address is not valid. Please check and try again.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'operation-not-allowed':
        return 'Email/password sign-up is not enabled. Please contact support.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection and try again.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'requires-recent-login':
        return 'Please sign in again to complete this action.';
      case 'timeout':
        return 'Request timed out. Please try again.';
      case 'unknown':
        return 'An unexpected error occurred. Please try again.';
      default:
        return errorCode.isNotEmpty ? errorCode : 'An error occurred. Please try again.';
    }
  }

  // Comprehensive validation before signup
  bool _validateAllFields() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // Check for empty fields
    if (email.isEmpty) {
      _showSnackBar('Please enter your email address.', isError: true);
      return false;
    }

    if (password.isEmpty) {
      _showSnackBar('Please enter a password.', isError: true);
      return false;
    }

    if (confirmPassword.isEmpty) {
      _showSnackBar('Please confirm your password.', isError: true);
      return false;
    }

    // Check email format
    final emailError = _validateEmail(email);
    if (emailError != null) {
      _showSnackBar(emailError, isError: true);
      return false;
    }

    // Check password strength
    final passwordError = _validatePassword(password);
    if (passwordError != null) {
      _showSnackBar(passwordError, isError: true);
      return false;
    }

    // Check password match
    if (password != confirmPassword) {
      _showSnackBar('Passwords do not match. Please check and try again.', isError: true);
      return false;
    }

    return true;
  }

  Future<void> _signUp() async {
    // Validate form using Flutter's built-in validation
    if (!_formKey.currentState!.validate()) {
      _showSnackBar('Please fix the errors above and try again.', isError: true);
      return;
    }

    // Additional comprehensive validation
    if (!_validateAllFields()) {
      return;
    }

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      
      // Show loading message
      _showSnackBar('Creating your account...');
      
      final success = await authProvider.signUp(email, password);

      if (mounted) {
        if (success) {
          _showSnackBar('🎉 Account created successfully! Welcome aboard!');
          // Small delay to show success message before navigating
          await Future.delayed(const Duration(milliseconds: 1500));
          if (mounted) {
            Navigator.of(context).pop();
          }
        } else {
          // Handle Firebase-specific errors
          String errorMessage = 'Failed to create account.';
          
          if (authProvider.errorMessage.isNotEmpty) {
            errorMessage = _getFirebaseErrorMessage(authProvider.errorMessage);
          }
          
          _showSnackBar(errorMessage, isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('An unexpected error occurred. Please try again.', isError: true);
      }
    }
  }

  void _navigateBack() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isLoading) {
      _showSnackBar('Please wait while we process your request.', isError: true);
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _navigateBack,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Create Account Header
                    Text(
                      'Create Account',
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Join us to start taking notes',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                      decoration: InputDecoration(
                        labelText: 'Email (Gmail or Yahoo only)',
                        prefixIcon: const Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        helperText: 'Use lowercase letters and numbers only',
                        helperStyle: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      validator: _validatePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        helperText: 'Min 6 chars: A-Z, a-z, 0-9, symbols',
                        helperStyle: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Confirm Password Field
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      validator: _validateConfirmPassword,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        helperText: 'Re-enter your password',
                        helperStyle: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Sign Up Button
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: authProvider.isLoading ? null : _signUp,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: authProvider.isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Sign Up',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Navigate to Sign In
                    TextButton(
                      onPressed: authProvider.isLoading ? null : _navigateBack,
                      child: const Text('Already have an account? Sign In'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}