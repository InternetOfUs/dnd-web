import 'package:dnd_front/models/login.dart';
import 'package:dnd_front/models/routines.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RoutinePage extends StatelessWidget {
  const RoutinePage({Key? key}) : super(key: key);

  Widget buildRoutine(BuildContext context, Routine routine) {
    return ListTile(title: Text(routine.weekdayStr));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Routines')),
        body: Column(children: [
          Consumer<LoginModel>(
              builder: (context, loginModel, child) => Text(loginModel.login)),
          Consumer<RoutinesModel>(
              builder: (context, routinesModels, child) => ListView.builder(
                    itemCount: routinesModels.routines.length,
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final item = routinesModels.routines[index];
                      return buildRoutine(context, item);
                    },
                  ))
        ]));
  }
}
