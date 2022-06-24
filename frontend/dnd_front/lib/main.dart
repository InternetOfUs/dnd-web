import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';

import 'app.dart';
import 'dnd_observer.dart';

void main() {
  BlocOverrides.runZoned(
    () => runApp(const DnDApp()),
    blocObserver: DnDObserver(),
  );
}
