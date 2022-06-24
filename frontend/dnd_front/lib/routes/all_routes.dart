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
      '/norms_editor/': (context) => NormsEditor("0")
    },
    onGenerateRoute: (RouteSettings settings) {
      var routes = <String, WidgetBuilder>{
        "/": (ctx) => const LoginScreen(),
        "/norms_editor/": (ctx) => NormsEditor(settings.arguments as String),
      };
      WidgetBuilder? builder = routes[settings.arguments as String];
      return MaterialPageRoute(builder: (ctx) => builder!(ctx));
    },
  );
}
