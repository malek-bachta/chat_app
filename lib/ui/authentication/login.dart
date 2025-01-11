import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chat_app/ui/home_page.dart';
import 'package:chat_app/ui/authentication/register.dart';
import 'package:chat_app/ui/components/custom_button.dart';
import 'package:chat_app/ui/components/custom_input_field.dart';

import '../../core/view_models/auth_provider.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
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

  void _navigateToRegisterScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const Register()),
    );
  }

  Future<void> _login(AuthenticationProvider authProvider) async {
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

    try {
      await authProvider.login(email, password, authProvider.isRememberMe);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } catch (e) {
      setState(() => _passwordErrorText = 'Invalid email or password.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthenticationProvider>(builder: (
      context,
      authProvider,
      child,
    ) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          title: const Text('Login'),
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
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
                  suffixIcon: GestureDetector(
                    onTap: () {
                      setState(() => _isPasswordVisible = !_isPasswordVisible);
                    },
                    child: Tooltip(
                      message: _isPasswordVisible
                          ? 'Hide Password'
                          : 'Show Password',
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                              opacity: animation, child: child);
                        },
                        child: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          key: ValueKey<bool>(_isPasswordVisible),
                          color: Theme.of(context).colorScheme.primary,
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
                Row(
                  children: <Widget>[
                    Checkbox(
                      value: authProvider.isRememberMe,
                      onChanged: (value) {
                        authProvider.setRememberMe(value!);
                      },
                    ),
                    const Text('Remember me'),
                  ],
                ),
                const SizedBox(height: 24.0),
                authProvider.isLoading
                    ? const CircularProgressIndicator()
                    : DynamicFilledButton(
                        buttonText: 'Login',
                        onPressed: () => _login(authProvider),
                      ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: _navigateToRegisterScreen,
                      child: const Text('Register'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
