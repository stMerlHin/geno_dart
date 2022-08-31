
import 'dart:convert';
import 'dart:io';

class GenoPreferences {

  static final GenoPreferences _instance = GenoPreferences._();
  static late Map<String, dynamic> _preferences;
  static bool _locked = false;

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

  Future<void> put({required String key, dynamic value}) async {
    _preferences[key] = value;
    await _saveData();
  }

  Future<void> putAll(Map<String, dynamic> map) async {
    _preferences.addAll(map);
    await _saveData();
  }

  Future<void> _saveData() async {
    if(!_locked) {
      _locked = true;
      File f = File(preferenceFile);
      await f.writeAsString(jsonEncode(_preferences));
      _locked = false;
    }
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