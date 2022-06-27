import 'package:dnd_front/models/login.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RoutinePage extends StatefulWidget {
  RoutinePage({Key? key}) : super(key: key);

  @override
  State<RoutinePage> createState() => _RoutinePageState();
}

class _RoutinePageState extends State<RoutinePage> {
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
