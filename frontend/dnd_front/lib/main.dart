// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:dnd_front/models/routines.dart';
import 'package:dnd_front/routines.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/login.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<LoginModel>(create: (context) => LoginModel()),
        ChangeNotifierProvider<RoutinesModel>(
            create: (context) => RoutinesModel())
      ],
      child: MyApp(),
    ),
  );
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
            context.read<LoginModel>().login = value;
            context.read<RoutinesModel>().fillFromProfileManager(value);
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
