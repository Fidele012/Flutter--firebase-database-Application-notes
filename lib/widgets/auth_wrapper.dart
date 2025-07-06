import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/sign_in_screen.dart';
import '../screens/notes_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isAuthenticated) {
          return const NotesScreen();
        } else {
          return const SignInScreen();
        }
      },
    );
  }
}