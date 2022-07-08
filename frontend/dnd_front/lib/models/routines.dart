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

enum RoutineStatus {
  routineNew,
  routineSending,
  routineUploaded,
  routineDownloaded,
  routineError,
}

class Routine {
  int _weekday;
  String _timeFrom;
  String _timeTo;
  String? _label;
  RoutineStatus _routineStatus = RoutineStatus.routineNew;

  int get weekeday => _weekday;
  String get timeFrom => _timeFrom;
  String get timeTo => _timeTo;
  String get label => _label ?? "";
  RoutineStatus get routineStatus => _routineStatus;
  set label(String newLabel) {
    _label = newLabel;
  }

  set timeFrom(String time) {
    _timeFrom = time;
  }

  set timeTo(String time) {
    _timeTo = time;
  }

  int fromWeekday(String w) {
    int res = -1;
    Weekday.values.asMap().forEach((index, value) {
      String valueStr = value.toString().split(".").elementAt(1);
      if (valueStr == w) {
        res = index + 1;
      }
    });
    if (res > 0) {
      _weekday = res;
    }
    return res;
  }

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

  bool isValid() {
    return _timeFrom.isNotEmpty && _timeTo.isNotEmpty;
  }

  Map<String, dynamic> toJson() => {
        "weekday": _weekday,
        "time_from": _timeFrom,
        "time_to": _timeTo,
        "label": _label
      };
  Routine.fromJson(Map<String, dynamic> json)
      : _weekday = json["weekday"],
        _timeFrom = json["time_from"],
        _timeTo = json["time_to"],
        _label = json["label"] ?? "";
}

class DnDEntryWithUser {
  final String _userid;
  final Routine _routine;

  DnDEntryWithUser(this._userid, this._routine);

  Map<String, dynamic> toJson() => {
        "userid": _userid,
        "entry": _routine.toJson(),
      };
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
    return res.sublist(0, res.length - 1);
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
    final response = await http.get(Uri.parse('/get_entries/$login'));
    var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes))
        as List<Map<String, dynamic>>;
    _routines.clear();
    for (var routine_map in decodedResponse) {
      Routine routine = Routine.fromJson(routine_map);
      _routines.add(routine);
    }
    for (var i = 1; i < (8 - decodedResponse.length); i++) {
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

  Future<void> sendRoutine(Routine routine, String userid) async {
    var entry = DnDEntryWithUser(userid, routine);
    final response = await http.post(Uri.parse("/add_entry"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(entry.toJson()));
    if ((response.statusCode >= 200) && (response.statusCode < 300)) {
      routine._routineStatus = RoutineStatus.routineUploaded;
    } else {
      routine._routineStatus = RoutineStatus.routineError;
    }
    notifyListeners();
  }

  void update() {
    notifyListeners();
  }
}
