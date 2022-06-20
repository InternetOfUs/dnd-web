import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fake login screen'),
      ),
      body: Center(
        child: TextFormField(
          decoration: const InputDecoration(
            border: UnderlineInputBorder(),
            labelText:
                'Enter the user id (will be replaced by 0auth2 later...)',
          ),
          onFieldSubmitted: (String value) {
            Navigator.pushNamed(context, "/norms_editor/");
          },
        ),
      ),
    );
  }
}
