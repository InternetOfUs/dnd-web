import 'dart:ui';

import 'package:dnd_front/models/login.dart';
import 'package:dnd_front/models/routines.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class RoutinePage extends StatelessWidget {
  const RoutinePage({Key? key}) : super(key: key);

  ElevatedButton buildEntryBtn(BuildContext context, Routine routine,
      RoutinesModel routinesModels, String userid, int index) {
    var color = Colors.green;
    var bgColor = Colors.pink.shade50;
    var icon = Icons.cloud_upload_rounded;
    var msg = "Save this rule";
    var disableButton = !routine.isValid();
    if ((routine.routineStatus == RoutineStatus.routineDownloaded ||
            routine.routineStatus == RoutineStatus.routineUploaded) &&
        routine.hasChanged()) {
      routine.routineStatus = RoutineStatus.routineEdited;
      print("routine has changed");
      //routinesModels.update();
    }
    if (!routine.isValid()) {
      color = Colors.grey;
    } else {
      switch (routine.routineStatus) {
        case RoutineStatus.routineDownloaded:
          color = Colors.blue;
          icon = Icons.cloud_download_rounded;
          msg = "Rule downloaded";
          break;
        case RoutineStatus.routineEdited:
          color = Colors.cyan;
          icon = Icons.cloud_upload_rounded;
          msg = "Save this modification";
          break;
        case RoutineStatus.routineError:
          color = Colors.red;
          icon = Icons.cloud_off_outlined;
          msg = "Error with this rule";
          break;
        case RoutineStatus.routineNew:
          color = Colors.green;
          icon = Icons.cloud_upload_rounded;
          break;
        case RoutineStatus.routineSending:
          color = Colors.deepPurple;
          icon = Icons.send;
          msg = "Sending...";
          break;
        case RoutineStatus.routineUploaded:
          color = Colors.green;
          icon = Icons.check;
          msg = "Rule sent successfully";
          disableButton = true;
          break;
      }
    }
    return ElevatedButton.icon(
      onPressed: disableButton
          ? null
          : () {
              routinesModels.sendRoutine(routine, userid);
            },
      icon: Icon(icon, color: color),
      label: Text(msg,
          style: TextStyle(
            color: color,
            fontFeatures: const [FontFeature.tabularFigures()],
          )),
      style: ElevatedButton.styleFrom(
          primary: bgColor, minimumSize: const Size(200, 30)),
    );
  }

  Widget buildRoutine(BuildContext context, Routine routine, int index,
      RoutinesModel routinesModels, String userid) {
    var txtFrom = TextEditingController();
    var txtTo = TextEditingController();
    txtFrom.text = routine.timeFrom;
    txtTo.text = routine.timeTo;
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Card(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(width: 20.0),
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
                      const SizedBox(width: 20.0),
                      const SizedBox(width: 60.0, child: Text("From: ")),
                      SizedBox(
                        width: 100.0,
                        child: TextField(
                          controller: txtFrom,
                          onTap: () async {
                            final newTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                              builder: (context, child) {
                                return MediaQuery(
                                  data: MediaQuery.of(context)
                                      .copyWith(alwaysUse24HourFormat: true),
                                  child: child ?? Container(),
                                );
                              },
                            );
                            if (newTime != null) {
                              var df = DateFormat("h:mm a");
                              var dt = df.parse(newTime.format(context));
                              var finaltime = DateFormat('HH:mm').format(dt);
                              routine.timeFrom = finaltime;
                              routinesModels.update();
                            }
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: '00:00',
                          ),
                        ),
                      ),
                      const SizedBox(width: 20.0),
                      const SizedBox(width: 30.0, child: Text("To: ")),
                      SizedBox(
                        width: 100.0,
                        child: TextField(
                          controller: txtTo,
                          onTap: () async {
                            final newTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                              builder: (context, child) {
                                return MediaQuery(
                                  data: MediaQuery.of(context)
                                      .copyWith(alwaysUse24HourFormat: true),
                                  child: child ?? Container(),
                                );
                              },
                            );
                            if (newTime != null) {
                              var df = DateFormat("h:mm a");
                              var dt = df.parse(newTime.format(context));
                              var finaltime = DateFormat('HH:mm').format(dt);
                              routine.timeTo = finaltime;
                              routinesModels.update();
                            }
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: '00:00',
                          ),
                        ),
                      ),
                      const SizedBox(width: 20.0),
                      OutlinedButton(
                        onPressed: () {
                          Routine newRoutine =
                              Routine(routine.weekeday, "", "", "");
                          routinesModels.addAt(newRoutine, index);
                        },
                        child: const Text('add time slot'),
                      ),
                      const SizedBox(width: 20.0)
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(width: 20.0),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                              onPressed: () {
                                routinesModels.deleteRoutine(routine, userid);
                                routinesModels.removeAt(index);
                              },
                              icon: const Icon(Icons.cancel_outlined,
                                  color: Colors.red)),
                          const SizedBox(width: 8),
                          buildEntryBtn(
                              context, routine, routinesModels, userid, index),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Routines')),
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Consumer2<RoutinesModel, LoginModel>(
                  builder: (context, routinesModels, loginModel, child) =>
                      ListView.builder(
                        itemCount: routinesModels.routines.length,
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        physics: ScrollPhysics(),
                        itemBuilder: (context, index) {
                          var item = routinesModels.routines[index];
                          return buildRoutine(context, item, index,
                              routinesModels, loginModel.login);
                        },
                      )),
            ]),
          ),
        ));
  }
}
