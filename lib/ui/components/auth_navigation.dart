import 'package:flutter/material.dart';

class AuthNavigation extends StatelessWidget {
  final String text;
  final String textButton;
  final VoidCallback navigate;
  const AuthNavigation({
    super.key,
    required this.text,
    required this.textButton,
    required this.navigate,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(text,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.primary,
            )),
        TextButton(
          onPressed: navigate,
          child: Text('$textButton here',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              )),
        ),
      ],
    );
  }
}
