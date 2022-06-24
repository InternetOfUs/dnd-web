import 'package:flutter/material.dart';

import 'dnd/dnd.dart';

/// {@template counter_app}
/// A [MaterialApp] which sets the `home` to [CounterPage].
/// {@endtemplate}
class DnDApp extends MaterialApp {
  /// {@macro counter_app}
  const DnDApp({Key? key}) : super(key: key, home: const DnDPage());
}
