import 'package:flutter/foundation.dart';

class Routine {
  final int _weekday;
  final String _time_from;
  final String _time_to;
  final String? label;

  String get weekdayStr => "$_weekday";

  Routine(this._weekday, this._time_from, this._time_to, this.label);
}

class RoutinesModel extends ChangeNotifier {
  final List<Routine> _routines = [];

  List<Routine> get routines => List<Routine>.from(_routines);

  void add(Routine routine) {
    _routines.add(routine);
    notifyListeners();
  }

  Future<void> fillFromProfileManager(login) async {
    _routines.clear();
    for (var i = 1; i < 8; i++) {
      Routine routine = Routine(i, "", "", "");
      _routines.add(routine);
    }
    notifyListeners();
  }
}
