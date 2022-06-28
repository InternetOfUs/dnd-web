import 'package:dnd_front/models/login.dart';
import 'package:dnd_front/models/routines.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class RoutinePage extends StatelessWidget {
  const RoutinePage({Key? key}) : super(key: key);

  Widget buildRoutine(BuildContext context, Routine routine, int index,
      RoutinesModel routinesModels) {
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
            Routine newRoutine = Routine(routine.weekeday, "", "", "");
            routinesModels.addAt(newRoutine, index);
          },
          child: const Text('add time slot'),
        ),
        DropdownButton<String>(
          icon: const Icon(Icons.location_pin),
          elevation: 16,
          style: const TextStyle(color: Colors.deepPurple),
          underline: Container(
            height: 2,
            color: Colors.deepPurpleAccent,
          ),
          onChanged: (String? newValue) {},
          hint: const Text("Where are you usually at this time?"),
          items: routinesModels.labels
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Routines')),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(children: [
              Consumer<LoginModel>(
                  builder: (context, loginModel, child) =>
                      Text(loginModel.login)),
              Consumer<RoutinesModel>(
                  builder: (context, routinesModels, child) => ListView.builder(
                        itemCount: routinesModels.routines.length,
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          final item = routinesModels.routines[index];
                          return buildRoutine(
                              context, item, index, routinesModels);
                        },
                      )),
              const Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(height: 50)),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Save'),
              ),
            ]),
          ),
        ));
  }
}
