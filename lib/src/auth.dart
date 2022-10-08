import 'dart:async';
import 'dart:convert';

import 'package:geno_dart/src/utils.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

import 'constants.dart';
import 'geno_dart_base.dart';
import 'model/result.dart';
import 'model/user.dart';

class Auth {

  static late final Preferences _preferences;
  static final Auth _instance = Auth._();
  static final List<Function(bool)> _loginListeners = [];
  static User? _user;
  static bool _initialized = false;

  Auth._();

  static void _getAuthenticationData() {
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

  void addLoginListener(Function(bool) listener) {
    _loginListeners.add(listener);
  }

  void _notifyLoginListener(bool value) {
    for (var element in _loginListeners) {
      element(value);
    }
  }

  Future recoverPassword({
  required String email,
    required Function onSuccess,
    required Function(String) onError,
    bool secure = true,
    String appLocalisation = 'fr'
}) async {
    final url = Uri.parse(Geno.getPasswordRecoveryUrl(secure));
    try {
      final response = await http.post(
          url,
          headers: {
            'Content-type': 'application/json',
          },
          body: jsonEncode({
            gAppSignature: Geno.appSignature,
            gUserEmail: email,
            gAppLocalisation: appLocalisation
          })
      );

      if (response.statusCode == 200) {
        AuthResult result = AuthResult.fromJson(response.body);
        if (result.errorHappened) {
          onError(result.errorMessage);
        } else {
          onSuccess();
        }
      } else {
        onError(response.body.toString());
      }
    } catch (e) {
      onError(e.toString());
    }
}

  Future changePassword({
    required String email,
    required String password,
    required String newPassword,
    required Function onSuccess,
    required Function(String) onError,
    bool secure = true,
    String appLocalisation = 'fr'
  }) async {
    final url = Uri.parse(Geno.getChangePasswordUrl(secure));
    try {
      final response = await http.post(
          url,
          headers: {
            'Content-type': 'application/json',
          },
          body: jsonEncode({
            gAppSignature: Geno.appSignature,
            gUserEmail: email,
            gUserPassword: password,
            gUserNewPassword: newPassword,
            gAppLocalisation: appLocalisation
          })
      );

      if (response.statusCode == 200) {
        AuthResult result = AuthResult.fromJson(response.body);
        if (result.errorHappened) {
          onError(result.errorMessage);
        } else {
          onSuccess();
        }
      } else {
        onError(response.body.toString());
      }
    } catch (e) {
      onError(e.toString());
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
          _getAuthenticationData();
          _notifyLoginListener(true);
          onSuccess(result.data[gUserUId]);
        }
      } else {
        onError(response.body.toString());
      }
    } catch (e) {
      onError(e.toString());
    }
  }

  Future changePhoneNumber({
    required String phoneNumber,
    required String newPhoneNumber,
    required Function() onSuccess,
    required Function(String) onError,
    bool secure = true
  }) async {
    final url = Uri.parse(Geno.getPhoneChangeUrl(secure));
    try {
      final response = await http.post(
          url,
          headers: {
            'Content-type': 'application/json',
          },
          body: jsonEncode({
            gAppSignature: Geno.appSignature,
            gUserUId: user!.uid,
            gUserPhoneNumber: phoneNumber,
            gNewUserPhoneNumber: newPhoneNumber
          })
      );

      if (response.statusCode == 200) {
        AuthResult result = AuthResult.fromJson(response.body);
        if (result.errorHappened) {
          onError(result.errorMessage);
        } else {
          _preferences.put(key: gUserPhoneNumber, value: newPhoneNumber);
          onSuccess();
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
          _notifyLoginListener(true);
          _getAuthenticationData();
          onSuccess(user);
        }
      } else {
        onError(response.body.toString());
      }
    } catch (e) {
      onError(e.toString());
    }
  }

  Future changeEmail({
    required String newEmail,
    required String oldEmail,
    required String password,
    required Function onEmailSent,
    Function(String)? onListenerDisconnected,
    Function()? onEmailConfirmed,
    required Function(String) onError,
    bool secure = true
  }) async {
    final url = Uri.parse(Geno.getEmailChangeUrl(secure));

    WebSocketChannel channel;

    channel = createChannel('auth/email_confirmation/listen', secure);

    channel.sink.add(jsonEncode({
      recycleAppWsKey: Geno.appSignature,
      gUserEmail: newEmail
    }));
    channel.stream.listen((event) {

      User user = User.fromJson(event);
      //add user to preference
      _preferences.putAll(user.toMap());

      _getAuthenticationData();

      onEmailConfirmed?.call();
      channel.sink.close();

    }, onError: (e) {
      onError(e);

      onListenerDisconnected?.call(e.toString());
    }).onDone(() {
      onListenerDisconnected?.call('Done');
    });

    try {
      final response = await http.post(
          url,
          headers: {
            'Content-type': 'application/json',
          },
          body: jsonEncode({
            gAppSignature: Geno.appSignature,
            gUserEmail: oldEmail,
            gUserNewEmail: newEmail,
            gUserPassword: password
          })
      );

      if (response.statusCode == 200) {
        AuthResult result = AuthResult.fromJson(response.body);
        if (result.errorHappened) {
          channel.sink.close();
          onError(result.errorMessage);
        } else {
          onEmailSent();
        }
      } else {
        channel.sink.close();
        onError(response.body.toString());
      }
    } catch (e) {
      channel.sink.close();
      onError(e.toString());
    }
  }

  Future signingWithEmailAndPassword({
    required String email,
    required String password,
    required Function onEmailSent,
    Function(String)? onListenerDisconnected,
    Function(User)? onEmailConfirmed,
    required Function(String) onError,
    bool secure = true
  }) async {
    final url = Uri.parse(Geno.getEmailSigningUrl(secure));

    WebSocketChannel channel;

    channel = createChannel('auth/email_confirmation/listen', secure);

    channel.sink.add(jsonEncode({
      recycleAppWsKey: Geno.appWsSignature,
      gUserEmail: email
    }));
    channel.stream.listen((event) {

      User user = User.fromJson(event);
      //add user to preference
      _preferences.putAll(user.toMap());
      _getAuthenticationData();
      _notifyLoginListener(true);
      onEmailConfirmed?.call(user);
      channel.sink.close();

    }, onError: (e) {
      onListenerDisconnected?.call(e.toString());
    }).onDone(() {
    });

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
          channel.sink.close();
          onError(result.errorMessage);
        } else {
          onEmailSent();
        }
      } else {
        channel.sink.close();
        onError(response.body.toString());
      }
    } catch (e) {
      channel.sink.close();
      onError(e.toString());
    }
  }

  Future logOut() async {
    _user = null;
    await _preferences.putAll(User().toMap());
    _notifyLoginListener(false);
  }

  static Future<Auth> get instance async {
    if(!_initialized) {
      _preferences = await Preferences.getInstance();
      _getAuthenticationData();
      _initialized = true;
      return _instance;
    }
    return _instance;
  }

  bool get isAuthenticated => _user != null;

  User? get user => _user;


}
