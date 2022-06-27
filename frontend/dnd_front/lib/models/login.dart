import 'package:flutter/foundation.dart';

class LoginModel extends ChangeNotifier {
  String _login = "";

  set login(String login) {
    _login = login;
    notifyListeners();
  }

  String get login => _login;
}
