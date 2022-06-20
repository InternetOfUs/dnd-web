import 'package:flutter/material.dart';

class NormsEditor extends StatefulWidget {
  const NormsEditor({Key? key}) : super(key: key);

  @override
  State<NormsEditor> createState() => _NormsEditorState();
}

class _NormsEditorState extends State<NormsEditor> {
  @override
  Widget build(BuildContext context) {
    Map arguments = ModalRoute.of(context)?.settings.arguments as Map;

    return Scaffold(
        appBar: AppBar(
          title: const Text('Norms editor'),
        ),
        body: Center(
          child: Column(children: [
            Text("You are logged as ${arguments['user']}"),
            const Text("TODO fill norms", style: TextStyle(color: Colors.red))
          ]),
        ));
  }
}
