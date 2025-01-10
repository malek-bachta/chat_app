import 'package:chat_app/core/sevices/auth_service.dart';
import 'package:chat_app/ui/authentication/register.dart';
import 'package:chat_app/ui/home_page.dart';
import 'package:chat_app/ui/components/auth_navigation.dart';
import 'package:chat_app/ui/components/custom_button.dart';
import 'package:chat_app/ui/components/custom_input_field.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _rememberMe = false;

  String? _emailErrorText;
  String? _passwordErrorText;

  @override
  void initState() {
    super.initState();
    _loadSavedEmail();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('savedEmail');
    final rememberMe = prefs.getBool('rememberMe') ?? false;

    if (savedEmail != null && rememberMe) {
      setState(() {
        _emailController.text = savedEmail;
        _rememberMe = true;
      });
    }
  }

  Future<void> _saveEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString('savedEmail', email);
      await prefs.setBool('rememberMe', true);
    } else {
      await prefs.remove('savedEmail');
      await prefs.setBool('rememberMe', false);
    }
  }

  Future<void> _login() async {
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

    setState(() => _isLoading = true);

    try {
      final user =
          await _authService.signInWithEmailAndPassword(email, password);
      if (user != null) {
        await _saveEmail(email); // Save email if "Remember Me" is enabled
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else {
        setState(() => _passwordErrorText = 'Invalid email or password.');
      }
    } catch (e) {
      setState(() => _emailErrorText = 'An error occurred. Please try again.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _navigateToRegisterScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const Register()),
    );
  }

  Widget _buildRememberMeCheckbox() {
    return Row(
      children: <Widget>[
        Checkbox(
          value: _rememberMe,
          onChanged: (value) {
            setState(() => _rememberMe = value!);
          },
        ),
        const Text('Remember me'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
                
                
              ),
              _buildRememberMeCheckbox(),
              const SizedBox(height: 24.0),
              _isLoading
                  ? const CircularProgressIndicator()
                  : DynamicFilledButton(
                      buttonText: 'Login',
                      onPressed: _login,
                    ),
              const SizedBox(height: 16.0),
              AuthNavigation(
                text: 'Don\'t have an account?',
                textButton: 'Register',
                navigate: _navigateToRegisterScreen,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
