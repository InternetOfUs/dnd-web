import 'package:flutter/foundation.dart';

enum Weekday {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday,
  error
}

class Routine {
  final int _weekday;
  final String _timeFrom;
  final String _timeTo;
  final String? _label;

  Weekday toWeekday() {
    switch (_weekday) {
      case 1:
        {
          return Weekday.monday;
        }
      case 2:
        {
          return Weekday.tuesday;
        }
      case 3:
        {
          return Weekday.wednesday;
        }
      case 4:
        {
          return Weekday.thursday;
        }
      case 5:
        {
          return Weekday.friday;
        }
      case 6:
        {
          return Weekday.saturday;
        }
      case 7:
        {
          return Weekday.sunday;
        }
      default:
        {
          return Weekday.error;
        }
    }
  }

  String get weekdayStr => toWeekday().name;

  Routine(this._weekday, this._timeFrom, this._timeTo, this._label);
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
