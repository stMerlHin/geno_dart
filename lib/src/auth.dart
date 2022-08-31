import 'dart:convert';
import 'dart:io';

import 'package:geno_dart/geno_dart.dart';
import 'package:geno_dart/src/tools.dart';

import 'model/user.dart';

class Auth {

  static late final GenoPreferences _preferences;
  static final Auth _instance = Auth._();
  static User? _user;

  Auth._();

  static Future _getAuthenticationData() async {

    String? uid = _preferences.getString(gUserUId);
    if(uid != null) {
      String? email = _preferences.getString(gUserEmail);
      String? phoneNumber = _preferences.getString(gUserPhoneNumber);
      String? authMode = _preferences.getString(gUserAuthMode);
      AuthenticationMode mode = AuthenticationMode.parse(authMode);
      if(mode != AuthenticationMode.none) {
        _user = User(
          uid: uid,
          email: email,
          phoneNumber: phoneNumber,
          mode: mode,
        );
      }
    }
  }

  static Future<Auth> get instance async {
    _preferences = await GenoPreferences.getInstance();
    await _getAuthenticationData();
    return _instance;
  }

  bool get isAuthenticated => _user != null;

  User? get user => _user;
}

const String gUser = 'g_user';
const String gUserUId = 'g_user_uid';
const String gUserEmail = 'g_user_email';
const String gUserPhoneNumber = 'g_user_phoneNumber';
const String gUserAuthMode = 'g_user_auth_mode';
