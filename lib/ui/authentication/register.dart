import 'package:chat_app/core/sevices/auth_service.dart';
import 'package:chat_app/ui/authentication/login.dart';
import 'package:chat_app/ui/components/auth_navigation.dart';
import 'package:chat_app/ui/components/custom_button.dart';
import 'package:chat_app/ui/components/custom_input_field.dart';
import 'package:flutter/material.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  String? _emailErrorText;
  String? _passwordErrorText;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
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

    setState(() => _isLoading = true);

    try {
      await _authService.signUpWithEmailAndPassword(email, password);

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginView()),
      );
    } catch (e, stackTrace) {
      print('Error during registration: $e');
      print(stackTrace);
      setState(() => _emailErrorText = 'An unexpected error occurred: $e');
    } finally {
      print('Stopping loading...');
      setState(() => _isLoading = false);
    }
  }

  void _navigateToLoginScreen() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.tertiary,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        title: const Text('Register'),
        elevation: 0,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CustomInputField(
                controller: _emailController,
                label: 'Email',
                isEmail: true,
                errorText: _emailErrorText,
                backgroundColor: Colors.white,
              ),
              const SizedBox(height: 8.0),
              CustomInputField(
                controller: _passwordController,
                label: 'Password',
                obscureText: !_isPasswordVisible,
                toggleVisibility: () {
                  setState(() => _isPasswordVisible = !_isPasswordVisible);
                },
                errorText: _passwordErrorText,
                backgroundColor: Colors.white,
              ),
              const SizedBox(height: 24.0),
              _isLoading
                  ? const CircularProgressIndicator()
                  : DynamicFilledButton(
                      buttonText: 'Register',
                      onPressed: _register,
                    ),
              const SizedBox(height: 16.0),
              AuthNavigation(
                text: 'Already have an account?',
                textButton: 'Login',
                navigate: _navigateToLoginScreen,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
