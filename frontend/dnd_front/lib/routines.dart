import 'package:dnd_front/models/login.dart';
import 'package:dnd_front/models/routines.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class RoutinePage extends StatelessWidget {
  const RoutinePage({Key? key}) : super(key: key);

  Widget buildRoutine(BuildContext context, Routine routine, int index,
      RoutinesModel routinesModels) {
    var txtFrom = TextEditingController();
    var txtTo = TextEditingController();
    txtFrom.text = routine.timeFrom;
    txtTo.text = routine.timeTo;
    return Row(
      children: [
        DropdownButton<String>(
          icon: const Icon(Icons.calendar_today),
          elevation: 16,
          style: const TextStyle(color: Colors.deepPurple),
          underline: Container(
            height: 2,
            color: Colors.black,
          ),
          onChanged: (String? newValue) {
            routine.fromWeekday(newValue!);
            routinesModels.update();
          },
          value: routine.weekdayStr,
          items: routinesModels.weekdays
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
        const SizedBox(width: 60.0, child: Text("From: ")),
        SizedBox(
          width: 100.0,
          child: TextField(
            controller: txtFrom,
            onTap: () async {
              final newTime = await showTimePicker(
                context: context,
                initialTime: const TimeOfDay(hour: 7, minute: 15),
              );
              if (newTime != null) {
                routine.timeFrom = newTime.format(context);
                routinesModels.update();
              }
            },
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: '0.00am',
            ),
          ),
        ),
        const SizedBox(width: 30.0, child: Text("To: ")),
        SizedBox(
          width: 100.0,
          child: TextField(
            controller: txtTo,
            onTap: () async {
              final newTime = await showTimePicker(
                context: context,
                initialTime: const TimeOfDay(hour: 9, minute: 15),
              );
              if (newTime != null) {
                routine.timeTo = newTime.format(context);
                routinesModels.update();
              }
            },
            decoration: const InputDecoration(
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
          onChanged: (String? newValue) {
            routine.label = newValue!;
            routinesModels.update();
          },
          value: routine.label == "" ? null : routine.label,
          hint: const Text("Where are you usually at this time?"),
          items: routinesModels.labels
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
        IconButton(
            onPressed: () {
              routinesModels.removeAt(index);
            },
            icon: const Icon(Icons.cancel_outlined, color: Colors.red)),
        IconButton(
            onPressed: !routine.isValid()
                ? null
                : () {
                    // TODO send routine
                  },
            icon: Icon(Icons.cloud_upload_rounded,
                color: routine.isValid() ? Colors.green : Colors.grey)),
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
