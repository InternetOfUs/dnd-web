import 'package:flutter/material.dart';

enum Weekday { monday, tuesday, wednesday, thursday, friday, saturday, sunday }

class Routine {
  final Weekday weekday;
  final String dateFrom;
  final String dateTo;
  final String? label;

  Routine(this.weekday, this.dateFrom, this.dateTo, this.label);

  @override
  String toString() {
    return "${weekday.name} From: $dateFrom  To: $dateTo";
  }
}

class NormsPage {
  final String userid;
  final List<Routine> routines;

  NormsPage(this.userid, this.routines);

  static Future<NormsPage> fetchNorms(userid) async {
    List<Routine> myRoutines = [];
    myRoutines.add(Routine(Weekday.monday, "", "", ""));
    myRoutines.add(Routine(Weekday.tuesday, "", "", ""));
    myRoutines.add(Routine(Weekday.wednesday, "", "", ""));
    myRoutines.add(Routine(Weekday.thursday, "", "", ""));
    myRoutines.add(Routine(Weekday.friday, "", "", ""));
    myRoutines.add(Routine(Weekday.saturday, "", "", ""));
    myRoutines.add(Routine(Weekday.sunday, "", "", ""));
    return NormsPage(userid, myRoutines);
  }

  Widget build(BuildContext context) {
    return Column(children: [
      const Text("The time periods of a week are: "),
      ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        // Let the ListView know how many items it needs to build.
        itemCount: routines.length,
        // Provide a builder function. This is where the magic happens.
        // Convert each item into a widget based on the type of item it is.
        itemBuilder: (context, index) {
          final item = routines[index];

          return ListTile(
            title: Text(item.toString()),
            subtitle: Text("test $userid"),
          );
        },
      )
    ]);
  }
}

class NormsEditor extends StatefulWidget {
  final String userid;
  NormsEditor(this.userid);

  @override
  State<NormsEditor> createState() => _NormsEditorState();
}

class _NormsEditorState extends State<NormsEditor> {
  late Future<NormsPage> futureNormsPage;
  late String userid = "0";

  @override
  void initState() {
    super.initState();
    //  Map arguments = ModalRoute.of(context)?.settings.arguments as Map;
    futureNormsPage = NormsPage.fetchNorms(userid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Norms editor'),
        ),
        body: Center(
          child: Column(children: [
            Text("You are logged as $userid"),
            const Text("TODO fill norms", style: TextStyle(color: Colors.red)),
            FutureBuilder<NormsPage>(
              future: futureNormsPage,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return snapshot.data!.build(context);
                } else if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                }

                // By default, show a loading spinner.
                return const CircularProgressIndicator();
              },
            )
          ]),
        ));
  }
}
