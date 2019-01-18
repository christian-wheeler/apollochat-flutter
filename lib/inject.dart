import 'package:shared_preferences/shared_preferences.dart';

class Inject {
  static final Inject _injector = new Inject._internal();

  factory Inject() {
    return _injector;
  }

  Inject._internal();

  SharedPreferences preferences;
  String userID;
}