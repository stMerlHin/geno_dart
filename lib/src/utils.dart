
import 'dart:convert';
import 'dart:io';

import 'package:geno_dart/src/geno_dart_base.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';

class Preferences {

  static final Preferences _instance = Preferences._();
  static String _preferenceFilePath = '';
  static bool _initialized = false;
  static late Map<String, dynamic> _preferences;
  static bool _locked = false;

  Preferences._();

  static Future<Preferences> getInstance() async {
    if(!_initialized) {
      //await Directory(Geno.appPrivateDirectory).create(recursive: true);
      _preferenceFilePath = join(Geno.appPrivateDirectory, preferenceFile);
      File gP = File(_preferenceFilePath);
      bool exist = await gP.exists();
      if (exist) {
        String str = await gP.readAsString();
        _preferences = jsonDecode(str);
      } else {
        _preferences = {};
      }
      _initialized = true;
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
      File f = File(_preferenceFilePath);
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

class Cache {

  final String cacheFilePath;
  static final Map<String, Cache>_instances = {};
  Map<String, dynamic> data;
  bool _locked = false;

  Cache._({
    required this.cacheFilePath,
    required this.data,
  });

  Map<String, dynamic>? get(String key) {
    return data[key];
  }

  Future<bool> put({
    String? uid,
    required Map<String, dynamic> map,
    bool save = true
  }) async {
    data[uid ?? Uuid().v1()] = map;
    if(save) {
      return await _cacheData();
    }
    return false;
  }

  Future<bool> putAll(Map<String, Map<String, dynamic>> map) async {
    data.addAll(map);
    return await _cacheData();
  }

  List<Map<String, dynamic>> getAll() {
    List<Map<String, dynamic>> list = [];
    data.forEach((key, value) {
      list.add(value);
    });
    return list;
  }
  
  Future<bool> remove(String key) async {
    data.remove(key);
    return await _cacheData();
  }

  Future<bool> _cacheData() async {
    if(!_locked) {
      _locked = true;
      File file = File(cacheFilePath);
      await file.writeAsString(jsonEncode(data));
      _locked = false;
      return true;
    }
    return false;
  }

  static Future<Cache> getInstance({
    required String cacheFilePath,
    bool publicDirectory = false
  }) async {
    String cacheAbsolutePath = cacheFilePath;

    if(!publicDirectory) {
      await Directory(Geno.appPrivateDirectory).create(recursive: true);
      cacheAbsolutePath = join(Geno.appPrivateDirectory, cacheFilePath);
    }

    ///Check if an instance of the same cache is not already launched
    if(Cache._instances[cacheAbsolutePath] != null) {
      return Cache._instances[cacheAbsolutePath]!;
    }

    File file = File(cacheAbsolutePath);
    Map<String, dynamic> d = {};
    if(await file.exists()) {
      String str = await file.readAsString();
      d = jsonDecode(str);
    }
    return Cache._(cacheFilePath: cacheAbsolutePath, data: d);
  }

  void dispose() {
    Cache._instances.remove(cacheFilePath);
  }
}

const String preferenceFile = '.gp';
