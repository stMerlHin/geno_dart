
import 'dart:convert';

import '../constants.dart';

class Result {
  final List<dynamic> data;
  final bool errorHappened;
  final String error;

  Result({this.data = const [], this.errorHappened = false, this.error = ''});

  static Result fromJson(String json) {
    var map = jsonDecode(json);
    return Result(
        data: map[gData],
        errorHappened: map[gErrorHappened],
        error: map[gError]);
  }

  String toJson() {
    return jsonEncode({
      gData: data,
      gErrorHappened: errorHappened,
      gError: error
    });
  }
}

class AuthResult {
  final Map<String, dynamic> data;
  final bool errorHappened;
  final String error;

  AuthResult({this.data = const {}, this.errorHappened = false, this.error = ''});

  static AuthResult fromJson(String json) {
    var map = jsonDecode(json);
    return AuthResult(
        data: map[gData],
        errorHappened: map[gErrorHappened],
        error: map[gError]);
  }


  String toJson() {
    return jsonEncode({
      gData: data,
      gErrorHappened: errorHappened,
      gError: error
    });
  }

}