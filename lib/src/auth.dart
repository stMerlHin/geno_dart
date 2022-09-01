import 'dart:convert';

import 'package:geno_dart/geno_dart.dart';
import 'package:geno_dart/src/tools.dart';
import 'package:http/http.dart' as http;

import 'model/result.dart';

class Auth {

  static late final GenoPreferences _preferences;
  static final Auth _instance = Auth._();
  static User? _user;
  static bool _initialized = false;

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

  Future loginWithPhoneNumber({
    required String phoneNumber,
    required Function(String) onSuccess,
    required Function(String) onError,
    bool secure = true
}) async {
    final url = Uri.parse(Geno.getPhoneAuthUrl(secure));
    try {
      final response = await http.post(
          url,
          headers: {
            'Content-type': 'application/json',
          },
          body: jsonEncode({
            gAppSignature: Geno.appSignature,
            gUserPhoneNumber: phoneNumber,
          })
      );

      if (response.statusCode == 200) {
        AuthResult result = AuthResult.fromJson(response.body);
        if (result.errorHappened) {
          onError(result.errorMessage);
        } else {
          User user = User(
              uid: result.data[gUserUId],
              phoneNumber: phoneNumber,
              mode: AuthenticationMode.phoneNumber
          );
          _preferences.putAll(user.toMap());
          onSuccess(result.data[gUserUId]);
        }
      } else {
        onError(response.body.toString());
      }
    } catch (e) {
      onError(e.toString());
    }
  }

  Future loginWithEmailAndPassword({
    required String email,
    required String password,
    required Function(User) onSuccess,
    required Function(String) onError,
    bool secure = true
  }) async {
    final url = Uri.parse(Geno.getEmailLoginUrl(secure));
    try {
      final response = await http.post(
          url,
          headers: {
            'Content-type': 'application/json',
          },
          body: jsonEncode({
            gAppSignature: Geno.appSignature,
            gUserEmail: email,
            gUserPassword: password
          })
      );
      if (response.statusCode == 200) {
        AuthResult result = AuthResult.fromJson(response.body);
        if (result.errorHappened) {
          onError(result.errorMessage);
        } else {
          User user = User.fromMap(result.data);
          _preferences.putAll(user.toMap());
          onSuccess(user);
        }
      } else {
        onError(response.body.toString());
      }
    } catch (e) {
      onError(e.toString());
    }
  }

  Future signingWithEmailAndPassword({
    required String email,
    required String password,
    required Function onEmailSent,
    required Function(String) onError,
    bool secure = true
  }) async {
    final url = Uri.parse(Geno.getEmailSigningUrl(secure));

    try {
      final response = await http.post(
          url,
          headers: {
            'Content-type': 'application/json',
          },
          body: jsonEncode({
            gAppSignature: Geno.appSignature,
            gUserEmail: email,
            gUserPassword: password
          })
      );

      if (response.statusCode == 200) {
        AuthResult result = AuthResult.fromJson(response.body);
        if (result.errorHappened) {
          onError(result.errorMessage);
        } else {
          onEmailSent();
        }
      } else {
        onError(response.body.toString());
      }
    } catch (e) {
      onError(e.toString());
    }
  }

  Future logOut() async {
    _user = null;
    await _preferences.putAll(User().toMap());
  }

  static Future<Auth> get instance async {
    if(!_initialized) {
      _preferences = await GenoPreferences.getInstance();
      await _getAuthenticationData();
      _initialized = true;
      return _instance;
    }
    return _instance;
  }

  bool get isAuthenticated => _user != null;

  User? get user => _user;
}
