import 'package:safer/models/model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Application {
  static bool debug = false;
  static String version = '1.0.0';
  static late SharedPreferences preferences;
  static late UserModel user;
  static late String pushToken;

  // Singleton factory
  static final Application _instance = Application._internal();

  factory Application() {
    return _instance;
  }

  Application._internal();
}
