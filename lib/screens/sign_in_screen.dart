import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'sign_up_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.red[600] : Colors.green[600],
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // Custom email validation matching SignUp requirements
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

  // Custom password validation matching SignUp requirements
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

  // Firebase error messages for sign-in specific errors
  String _getErrorMessage(String errorCode) {
    switch (errorCode.toLowerCase()) {
      case 'user-not-found':
        return '❌ No account found with this email. Please sign up first.';
      case 'wrong-password':
        return '❌ Incorrect password. Please check your password and try again.';
      case 'invalid-email':
        return '❌ Invalid email format. Please enter a valid email address.';
      case 'invalid-credential':
        return '❌ Invalid email or password. Please check your credentials.';
      case 'user-disabled':
        return '❌ This account has been disabled. Please contact support.';
      case 'too-many-requests':
        return '❌ Too many failed sign-in attempts. Please try again later.';
      case 'network-request-failed':
        return '❌ Network error. Please check your internet connection.';
      case 'operation-not-allowed':
        return '❌ Email/password sign-in is not enabled. Please contact support.';
      case 'requires-recent-login':
        return '❌ Please sign out and sign in again to continue.';
      case 'internal-error':
        return '❌ An internal error occurred. Please try again later.';
      case 'missing-email':
        return '❌ Please enter your email address.';
      case 'missing-password':
        return '❌ Please enter your password.';
      case 'weak-password':
        return '❌ Password does not meet security requirements.';
      case 'email-already-in-use':
        return '❌ This email is already registered. Please sign in instead.';
      case 'account-exists-with-different-credential':
        return '❌ Account exists with different sign-in method. Try a different method.';
      case 'credential-already-in-use':
        return '❌ This credential is already associated with another account.';
      case 'timeout':
        return '❌ Request timed out. Please try again.';
      default:
        if (errorCode.contains('network')) {
          return '❌ Network error. Please check your internet connection and try again.';
        } else if (errorCode.contains('timeout')) {
          return '❌ Request timed out. Please try again.';
        } else if (errorCode.contains('permission')) {
          return '❌ Permission denied. Please contact support.';
        } else {
          return '❌ Sign-in failed. Please check your credentials and try again.';
        }
    }
  }

  // Comprehensive validation before sign-in
  bool _validateAllFields() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // Check for empty fields
    if (email.isEmpty) {
      _showSnackBar('❌ Please enter your email address.', isError: true);
      return false;
    }

    if (password.isEmpty) {
      _showSnackBar('❌ Please enter your password.', isError: true);
      return false;
    }

    // Check email format (must match signup requirements)
    final emailError = _validateEmail(email);
    if (emailError != null) {
      _showSnackBar('❌ $emailError', isError: true);
      return false;
    }

    // Check password format (must match signup requirements)
    final passwordError = _validatePassword(password);
    if (passwordError != null) {
      _showSnackBar('❌ $passwordError', isError: true);
      return false;
    }

    return true;
  }

  Future<void> _signIn() async {
    // Validate form using Flutter's built-in validation
    if (!_formKey.currentState!.validate()) {
      _showSnackBar('⚠️ Please fix the errors above and try again.', isError: true);
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
      _showSnackBar('🔐 Signing you in...');

      final success = await authProvider.signIn(email, password);

      if (mounted) {
        if (success) {
          _showSnackBar('✅ Welcome back! You have been signed in successfully.');
          // Small delay to show success message
          await Future.delayed(const Duration(milliseconds: 1500));
        } else if (authProvider.errorMessage.isNotEmpty) {
          // Extract error code from the error message if it follows Firebase format
          String errorCode = authProvider.errorMessage.toLowerCase();
          
          // Handle common Firebase error message formats
          if (errorCode.contains('[') && errorCode.contains(']')) {
            final start = errorCode.indexOf('[') + 1;
            final end = errorCode.indexOf(']');
            if (end > start) {
              errorCode = errorCode.substring(start, end);
            }
          }
          
          final userFriendlyMessage = _getErrorMessage(errorCode);
          _showSnackBar(userFriendlyMessage, isError: true);
        } else {
          _showSnackBar('❌ Sign-in failed. Please check your credentials and try again.', isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('❌ An unexpected error occurred. Please try again.', isError: true);
      }
    }
  }

  void _navigateToSignUp() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isLoading) {
      _showSnackBar('⚠️ Please wait while we process your request.', isError: true);
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const SignUpScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    // App Title
                    Text(
                      'Notes App',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),

                    // Welcome Back
                    Text(
                      'Welcome Back',
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to your account',
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
                    const SizedBox(height: 24),

                    // Sign In Button
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: authProvider.isLoading ? null : _signIn,
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
                                'Sign In',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Navigate to Sign Up
                    TextButton(
                      onPressed: authProvider.isLoading ? null : _navigateToSignUp,
                      child: const Text('Don\'t have an account? Sign Up'),
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