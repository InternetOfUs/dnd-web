import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

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

  int get weekeday => _weekday;
  String get timeFrom => _timeFrom;
  String get timeTo => _timeTo;
  String get label => _label ?? "";

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
  final List<String> _labels = [];

  List<Routine> get routines => List<Routine>.from(_routines);
  List<String> get labels => List<String>.from(_labels);
  List<String> get weekdays {
    List<String> res = [];
    for (var name in Weekday.values) {
      res.add(name.toString().split('.').elementAt(1));
    }
    return res;
  }

  void add(Routine routine) {
    _routines.add(routine);
    notifyListeners();
  }

  void addAt(Routine routine, int at) {
    _routines.insert(at, routine);
    notifyListeners();
  }

  void removeAt(int index) {
    _routines.removeAt(index);
    notifyListeners();
  }

  Future<void> fillFromProfileManager(login) async {
    _routines.clear();
    for (var i = 1; i < 8; i++) {
      Routine routine = Routine(i, "", "", "");
      _routines.add(routine);
    }
    retreiveLabels();
  }

  Future<void> retreiveLabels() async {
    final response = await http.get(Uri.parse('wenet_regions_mapping.json'));
    var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
    _labels.clear();
    _labels.add("");
    _labels.add("prefer not to share");
    for (var k in decodedResponse.keys) {
      _labels.add(k);
    }
    notifyListeners();
  }
}
