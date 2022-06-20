import 'package:dnd_front/widgets/login.dart';
import 'package:dnd_front/widgets/norms_editor.dart';
import 'package:flutter/material.dart';

MaterialApp getRoutes() {
  return MaterialApp(
    title: 'Named Routes Demo',
    // Start the app with the "/" named route. In this case, the app starts
    // on the FirstScreen widget.
    initialRoute: '/',
    routes: {
      // When navigating to the "/" route, build the FirstScreen widget.
      '/': (context) => const LoginScreen(),
      '/norms_editor/': (context) => const NormsEditor()
    },
  );
}
