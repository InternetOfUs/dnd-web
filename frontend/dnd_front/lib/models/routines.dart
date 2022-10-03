import 'dart:convert';
import 'dart:html';
import 'package:dnd_front/routines.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

enum DnDError {
  TokenNotFound,

  OperationNotPermitted,

  ProfileManagerTimeout,

  ProfileManagerUserNotFound,

  ProfileManagerUnableToCreateNorm,

  ProfileManagerUnableToEdit,

  ProfileManagerUnableToDeleteNorm,

  ProfileManager500,

  UnknownError,
}

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
  routineEdited,
  routineError,
}

class Routine implements Comparable<Routine> {
  int _weekday;
  String _timeFrom;
  String _timeTo;
  String? _label;
  Routine? _old;
  RoutineStatus _routineStatus = RoutineStatus.routineNew;

  int get weekeday => _weekday;
  String get timeFrom => _timeFrom;
  String get timeTo => _timeTo;
  String get label => _label ?? "";
  Routine? get old => _old;
  RoutineStatus get routineStatus => _routineStatus;
  set routineStatus(RoutineStatus status) {
    _routineStatus = status;
  }

  set old(Routine? routine) {
    _old = routine;
  }

  set label(String newLabel) {
    if ((routineStatus == RoutineStatus.routineDownloaded ||
            routineStatus == RoutineStatus.routineUploaded) &&
        hasChanged()) {
      routineStatus = RoutineStatus.routineEdited;
    }
    _label = newLabel;
  }

  set timeFrom(String time) {
    if ((routineStatus == RoutineStatus.routineDownloaded ||
            routineStatus == RoutineStatus.routineUploaded) &&
        hasChanged()) {
      routineStatus = RoutineStatus.routineEdited;
    }
    _timeFrom = time;
  }

  set timeTo(String time) {
    if ((routineStatus == RoutineStatus.routineDownloaded ||
            routineStatus == RoutineStatus.routineUploaded) &&
        hasChanged()) {
      routineStatus = RoutineStatus.routineEdited;
    }
    _timeTo = time;
  }

  bool hasChanged() {
    if (_old != null) {
      if (_timeFrom != _old!._timeFrom) {
        return true;
      }
      if (_timeTo != _old!._timeTo) {
        return true;
      }
      if (_weekday != _old!._weekday) {
        return true;
      }
      if (_label != _old!._label) {
        return true;
      }
    }
    return false;
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
        "label": _label,
        "old": _old
      };
  Routine.fromJson(Map<String, dynamic> json)
      : _weekday = json["weekday"],
        _timeFrom = json["time_from"],
        _timeTo = json["time_to"],
        _label = json["label"] ?? "";

  @override
  int compareTo(Routine other) {
    if (_weekday < other._weekday) {
      return -1;
    } else if (_weekday == other._weekday) {
      return _timeFrom.compareTo(other._timeFrom);
    } else {
      return 1;
    }
  }

  Routine.from(Routine routine)
      : _weekday = routine.weekeday,
        _timeFrom = routine.timeFrom,
        _timeTo = routine.timeTo,
        _label = routine.label,
        _old = routine.old;
}

class DnDEntryWithToken {
  final String _token;
  final Routine _routine;

  DnDEntryWithToken(this._token, this._routine);

  Map<String, dynamic> toJson() => {
        "token": _token,
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

  Future<void> fillFromProfileManager(
      String login, BuildContext? context) async {
    final Map<String, String> headers = {"token": login};
    final response =
        await http.get(Uri.parse('${Uri.base}get_entries'), headers: headers);
    var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
    if (decodedResponse.containsKey("error") &&
        decodedResponse["error"] != null) {
      window.localStorage.clear();
      return;
      // TODO manager error
    } else if (decodedResponse.containsKey("content") &&
        decodedResponse["content"] != null) {
      _routines.clear();
      for (var routine_map in decodedResponse["content"]["Entries"] as List) {
        Routine routine = Routine.fromJson(routine_map);
        routine.routineStatus = RoutineStatus.routineDownloaded;
        routine.old = Routine.from(routine);
        _routines.add(routine);
      }
      for (var i = 1; i < (8 - decodedResponse.length); i++) {
        Routine routine = Routine(i, "", "", "");
        _routines.add(routine);
      }
      _routines.sort();
      retreiveLabels();
      if (context != null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RoutinePage()),
        );
      }
    }
  }

  Future<void> retreiveLabels() async {
    final response =
        await http.get(Uri.parse('${Uri.base}wenet_regions_mapping.json'));
    var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
    _labels.clear();
    _labels.add("");
    _labels.add("prefer not to share");
    for (var k in decodedResponse.keys) {
      _labels.add(k);
    }
    notifyListeners();
  }

  Future<void> sendRoutine(Routine routine, String token) async {
    var entry = DnDEntryWithToken(token, routine);
    final response = await http.post(Uri.parse("${Uri.base}add_entry"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(entry.toJson()));
    var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
    if (decodedResponse.containsKey("error") &&
        decodedResponse["error"] != null) {
      routine._routineStatus = RoutineStatus.routineError;
    } else {
      routine._routineStatus = RoutineStatus.routineUploaded;
      routine.old = Routine.from(routine);
    }
    notifyListeners();
  }

  Future<void> deleteRoutine(Routine routine, String token) async {
    var entry = DnDEntryWithToken(token, routine);
    final response = await http.post(Uri.parse("${Uri.base}delete_entry"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(entry.toJson()));
    var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
    if (decodedResponse.containsKey("error") &&
        decodedResponse["error"] != null) {
      routine._routineStatus = RoutineStatus.routineError;
    } else {
      routine._routineStatus = RoutineStatus.routineUploaded;
    }
    await fillFromProfileManager(token, null);
  }

  void update() {
    notifyListeners();
  }
}
