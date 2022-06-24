// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:dnd_front/routines.dart';
import 'package:flutter/material.dart';
import 'globals.dart' as globals;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: MyHome());
  }
}

class MyHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('DnD App')),
      body: Center(
        child: TextFormField(
          style: textTheme.headline2,
          decoration: const InputDecoration(
            border: UnderlineInputBorder(),
            labelText:
                'Enter the user id (will be replaced by 0auth2 later...)',
          ),
          onFieldSubmitted: (String value) {
            //context.read<DnDCubit>().setUser(value);
            globals.user = value;
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RoutinePage()),
            );
          },
        ),
      ),
    );
  }
}
