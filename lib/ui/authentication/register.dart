import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chat_app/ui/authentication/login.dart';
import 'package:chat_app/ui/components/custom_button.dart';
import 'package:chat_app/ui/components/custom_input_field.dart';
import '../../core/view_models/auth_provider.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  String? _emailErrorText;
  String? _passwordErrorText;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register(AuthenticationProvider authProvider) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    setState(() {
      _emailErrorText = null;
      _passwordErrorText = null;
    });

    if (email.isEmpty) {
      setState(() => _emailErrorText = 'Email cannot be empty');
      return;
    }

    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      setState(() => _emailErrorText = 'Enter a valid email address');
      return;
    }

    if (password.isEmpty) {
      setState(() => _passwordErrorText = 'Password cannot be empty');
      return;
    }

    if (password.length < 6) {
      setState(
          () => _passwordErrorText = 'Password must be at least 6 characters');
      return;
    }

    try {
      await authProvider.register(email, password);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginView()),
      );
    } catch (e) {
      setState(() => _emailErrorText = 'An unexpected error occurred: $e');
    }
  }

  void _navigateToLoginScreen() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return Consumer<AuthenticationProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          body: Center(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_add_alt_1, size: 64, color: primaryColor),
                    const SizedBox(height: 8),
                    Text(
                      "Create Your Account",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 32),
                    CustomInputField(
                      controller: _emailController,
                      label: 'Email',
                      isEmail: true,
                      errorText: _emailErrorText,
                      backgroundColor: Colors.grey.shade200,
                    ),
                    const SizedBox(height: 8.0),
                    CustomInputField(
                      controller: _passwordController,
                      label: 'Password',
                      obscureText: !_isPasswordVisible,
                      toggleVisibility: () {
                        setState(
                            () => _isPasswordVisible = !_isPasswordVisible);
                      },
                      errorText: _passwordErrorText,
                      backgroundColor: Colors.grey.shade200,
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(
                              () => _isPasswordVisible = !_isPasswordVisible);
                        },
                        child: Tooltip(
                          message: _isPasswordVisible
                              ? 'Hide Password'
                              : 'Show Password',
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            transitionBuilder: (child, animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                            child: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              key: ValueKey<bool>(_isPasswordVisible),
                              color: primaryColor,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 12.0,
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    authProvider.isLoading
                        ? const CircularProgressIndicator()
                        : DynamicFilledButton(
                            buttonText: 'Register',
                            onPressed: () => _register(authProvider),
                          ),
                    const SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account?"),
                        TextButton(
                          onPressed: _navigateToLoginScreen,
                          child: const Text('Login'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
