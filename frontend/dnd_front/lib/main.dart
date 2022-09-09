// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui' as ui;
import 'package:responsive_framework/responsive_framework.dart';
import 'package:dnd_front/models/routines.dart';
import 'package:dnd_front/routines.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_strategy/url_strategy.dart';
import 'models/login.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'dart:convert' show jsonDecode;
import 'package:http/http.dart' as http;
import 'dart:js' as js;
import 'dart:html';

void main() {
  setPathUrlStrategy();
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
    return MaterialApp(
      builder: (context, child) => ResponsiveWrapper.builder(child,
          maxWidth: 1200,
          minWidth: 480,
          defaultScale: true,
          breakpoints: [
            ResponsiveBreakpoint.resize(480, name: MOBILE),
            ResponsiveBreakpoint.autoScale(800, name: TABLET),
            ResponsiveBreakpoint.resize(1000, name: DESKTOP),
          ],
          background: Container(color: Color(0xFFF5F5F5))),
      home: MyHome(),
      scrollBehavior: MaterialScrollBehavior().copyWith(
        dragDevices: {
          ui.PointerDeviceKind.mouse,
          ui.PointerDeviceKind.touch,
          ui.PointerDeviceKind.stylus,
          ui.PointerDeviceKind.unknown
        },
      ),
    );
  }
}

class MyHome extends StatelessWidget {
  Future<String?> getData() {
    return Future.delayed(Duration(seconds: 1), () {
      return window.localStorage["token"];
      // throw Exception("Custom Error");
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('DnD App')),
      body: FutureBuilder(
        builder: (ctx, snapshot) {
          // Checking if future is resolved or not
          if (snapshot.connectionState == ConnectionState.done) {
            // If we got an error
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  '${snapshot.error} occurred',
                  style: TextStyle(fontSize: 18),
                ),
              );

              // if we got our data
            } else if (snapshot.hasData) {
              // Extracting data from snapshot object
              final data = snapshot.data as String;
              context.read<LoginModel>().login = data;
              context.read<RoutinesModel>().fillFromProfileManager(data);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RoutinePage()),
              );
            }
          }

          // Displaying LoadingSpinner to indicate waiting state
          return Center(
            child: Column(
              children: [
                OutlinedButton(
                  onPressed: () {
                    js.context.callMethod('open',
                        ['https://www.youtube.com/watch?v=1WDyRU0qeG0']);
                  },
                  child: const Text('watch the tutorial'),
                ),
                ElevatedButton(
                  child: Text('Auth with wenet-hub'),
                  onPressed: () {
                    js.context.callMethod('open', [
                      'http://internetofus.u-hopper.com/prod/hub/frontend/oauth/login?client_id=iRagYthYlA'
                    ]);
                  },
                )
              ],
            ),
          );
        },

        // Future that needs to be resolved
        // inorder to display something on the Canvas
        future: getData(),
      ),
    );
  }
}
