import 'package:dnd_front/models/login.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RoutinePage extends StatelessWidget {
  const RoutinePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Routines')),
        body: Column(children: [
          Consumer<LoginModel>(
              builder: (context, loginModel, child) => Text(loginModel.login))
        ]));
  }
}
