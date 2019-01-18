import 'package:shared_preferences/shared_preferences.dart';

// Singleton That is used as a Service Locator. For this app, it only stores a reference to
// SharedPreferences, a key value pair local disk data store. In addition it stores the
// current user's ID.
class Inject {
  static final Inject _injector = new Inject._internal();

  factory Inject() {
    return _injector;
  }

  Inject._internal();

  SharedPreferences preferences;
  String userID;
}