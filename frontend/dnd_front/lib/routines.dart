import 'package:flutter/material.dart';

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
        body: Column(children: [Text("Hello ${globals.user}")]));
  }
}
