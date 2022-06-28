import 'package:dnd_front/models/login.dart';
import 'package:dnd_front/models/routines.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class RoutinePage extends StatelessWidget {
  const RoutinePage({Key? key}) : super(key: key);

  Widget buildRoutine(BuildContext context, Routine routine) {
    return Row(
      children: [
        SizedBox(width: 90.0, child: Text(routine.weekdayStr)),
        const SizedBox(width: 60.0, child: Text("From: ")),
        const SizedBox(
          width: 100.0,
          child: TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: '0.00am',
            ),
          ),
        ),
        const SizedBox(width: 30.0, child: Text("To: ")),
        const SizedBox(
          width: 100.0,
          child: TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: '0.00am',
            ),
          ),
        ),
        OutlinedButton(
          onPressed: () {
            debugPrint('Received click');
          },
          child: const Text('add time slot'),
        ),
        const SizedBox(
          width: 200.0,
          // TODO replace by combo box
          child: TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'where are you usually?',
            ),
          ),
        ),
      ],
    );
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
                  )),
          const Align(
              alignment: Alignment.centerRight, child: SizedBox(height: 50)),
          ElevatedButton(
            onPressed: () {},
            child: const Text('Save'),
          ),
        ]));
  }
}
