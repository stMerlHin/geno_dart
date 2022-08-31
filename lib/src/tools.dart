
import 'dart:convert';
import 'dart:io';

class GenoPreferences {

  static final GenoPreferences _instance = GenoPreferences._();
  static late Map<String, dynamic> _preferences;

  GenoPreferences._();

  static Future<GenoPreferences> getInstance() async {
    File gP = File(preferenceFile);
    bool exist = await gP.exists();
    if(exist) {
      String str = await gP.readAsString();
      _preferences = jsonDecode(str);
    } else {
      _preferences = {};
    }
    return _instance;
  }

  void put({required String key, dynamic value}) {
    _preferences[key] = value;
    File f = File(preferenceFile);
    f.writeAsString(jsonEncode(_preferences));
  }

  void putAll(Map<String, dynamic> map) {
    _preferences.addAll(map);
  }

  String? getString(String key) {
    return _preferences[key];
  }

  int? getInt(String key) {
    return _preferences[key];
  }

  bool? getBool(String key) {
    return _preferences[key];
  }

  dynamic get(String key) {
    return _preferences[key];
  }
}

const String preferenceFile = '.gp';