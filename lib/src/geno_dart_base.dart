import 'dart:async';
import 'dart:convert';

import 'package:geno_dart/geno_dart.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';


class Geno {
  static String _gHost = gLocalhost;
  static String _gPort = gPort;
  static late String _connectionId;
  static String _unsecureGPort = '80';
  static String _privateDirectory = '';
  static String _encryptionKey = '';
  static late final String _appSignature;
  static late final String _appWsSignature;
  static late final Auth auth;
  static bool _initialized = false;
  late Function(Geno) _onInitialization;
  late Function()? _onLoginOut;
  late Function(Map<String, String>) _onConfigChanged;

  static final Geno _instance = Geno._();

  Geno._();

  ///Initialize geno client
  ///[host] the remote host which run the http server
  ///[port] the ssl supported port on which the server is running
  ///[unsecurePort] the none ssl supported port on which the server is running,
  /// default to 80
  ///[appSignature] the signature to send to the server for authentication
  ///[appWsSignature] the ws signature to send to the server for authentication
  ///[appPrivateDirectory] is the directory where the app should store cache files
  ///[onInitialization] is called when geno components are all set up
  ///[onConfigChanged] is called when the [host], [port] or [unsecurePort] have
  ///changed
  ///[onUserLoggedOut] is called when the user logged out
  Future<void> initialize({
    String host = gLocalhost,
    String port = gPort,
    String unsecurePort = '80',
    required String encryptionKey,
    required String appSignature,
    required String appWsSignature,
    required String appPrivateDirectory,
    required Future Function(Geno) onInitialization,
    Function()? onUserLoggedOut,
    Function(Map<String, String>)? onConfigChanged,
  }) async {
    _onInitialization = onInitialization;
    if (!_initialized) {

      _connectionId = Uuid().v1();
      _privateDirectory = appPrivateDirectory;
      _encryptionKey = encryptionKey;
      _appSignature = appSignature;
      _appWsSignature = appWsSignature;
      _onLoginOut = onUserLoggedOut;
      auth = await Auth.instance;
      auth.addLoginListener(_onUserLoggedOut);

      _gHost = host;
      _gPort = port;
      _unsecureGPort = unsecurePort;

      _onConfigChanged = onConfigChanged ?? (d) {};
      _onInitialization(this);
      _initialized = true;
    }
  }
  
  void _onUserLoggedOut(bool value) {
    if(!value) {
      _onLoginOut?.call();
    }
  }

  ///Change the configurations relative to remote server
  Future changeConfig({String? host, String? port, String? unsecurePort}) async {
    bool configChanged = false;
    if (host != null && host != _gHost) {
      _gHost = host;
      configChanged = true;
    }
    if (port != null && port != _gPort) {
      _gPort = port;
      configChanged = true;
    }
    if (unsecurePort != null && unsecurePort != _unsecureGPort) {
      _unsecureGPort = unsecurePort;
      configChanged = true;
    }
    if (configChanged) {
      _onConfigChanged({
        'host': _gHost,
        'port': _gPort,
        'unsecurePort': _unsecureGPort });
    }
  }

  static Geno get instance => _instance;
  static String get encryptionKey => _encryptionKey;
  static String get appSignature => _appSignature;
  static String get appWsSignature => _appWsSignature;
  static String get appPrivateDirectory => _privateDirectory;
  static String get connectionId => _connectionId;
  static String get baseUrl => 'https://$_gHost:$_gPort/';
  static String get unsecureBaseUrl => 'http://$_gHost:$_unsecureGPort/';
  static String get wsBaseUrl => 'wss://$_gHost:$_gPort/ws/';
  static String get unSecureWsBaseUrl => 'ws://$_gHost:$_unsecureGPort/ws/';
  static String getEmailSigningUrl([bool secured = true]) {
    return secured ? '$baseUrl' 'auth/email/signing' :
    '$unsecureBaseUrl' 'auth/email/signing';
  }

  static String getEmailLoginUrl([bool secured = true]) {
    return secured ? '$baseUrl' 'auth/email/login' :
    '$unsecureBaseUrl' 'auth/email/login';
  }

  static String getEmailChangeUrl([bool secured = true]) {
    return secured ? '$baseUrl' 'auth/email/change' :
    '$unsecureBaseUrl' 'auth/email/change';
  }

  static String getPasswordRecoveryUrl([bool secured = true]) {
    return secured ? '$baseUrl' 'auth/email/password/recovering' :
    '$unsecureBaseUrl' 'auth/email/password/recovering';
  }

  static String getChangePasswordUrl([bool secured = true]) {
    return secured ? '$baseUrl' 'auth/email/password/change' :
    '$unsecureBaseUrl' 'auth/email/password/change';
  }

  static String getPhoneAuthUrl([bool secured = true]) {
    return secured ? '$baseUrl' 'auth/phone' :
    '$unsecureBaseUrl' 'auth/phone';
  }

  static String getPhoneChangeUrl([bool secured = true]) {
    return secured ? '$baseUrl' 'auth/phone/change' :
    '$unsecureBaseUrl' 'auth/phone/change';
  }

  ///The host which runs the http server
  String get host => _gHost;

  ///The port of the http server
  String get port => _gPort;

}

///  DataListener tableListener = TableListener(table: 'student');
///     tableListener.listen(() {
///       print('Change HAPPENED ON TABLE student');
///     });
///
///  DataListener rowListener = DataListener(table: 'student', rowId: "2");
///     tableListener.listen(() {
///       print('Change HAPPENED ON TABLE student');
///     });
///
class DataListener {
  late WebSocketChannel _webSocket;

  bool _closeByClient = false;
  String table;
  String? tag;
  late int _reconnectionDelay;

  DataListener({required this.table, this.tag});

  void listen(void Function() onChanged, {int reconnectionDelay = 1000,
    bool secure = true,
    void Function(String)? onError,
    void Function()? onDispose,
  }) {
    _reconnectionDelay = reconnectionDelay;
    _create(onChanged, secure, onError, onDispose);
  }

  void _create(void Function() onChanged, bool secure,
      void Function(String)? onError,
      void Function()? onDispose) {
    _webSocket = createChannel('db/listen', secure);
    _webSocket.sink.add(_toJson());
    _webSocket.stream.listen((event) {
      if(event == 'close') {
        dispose();
        onDispose?.call();
      } else {
        onChanged();
      }
    }, onError: (e) {
      onError?.call(e.toString());
    }).onDone(() {
      if (!_closeByClient) {
        Timer(Duration(milliseconds: _reconnectionDelay), () {
          _create(onChanged, secure, onError, onDispose);
        });
      }
    });
  }

  String _toJson() {
    return jsonEncode({
      gAppWsKey: Geno.appWsSignature,
      gConnectionId: Geno.connectionId,
      gTable: table,
      gRowId: tag,
    });
  }

  void dispose() {
    _closeByClient = true;
    _webSocket.sink.close();
  }
}

WebSocketChannel createChannel(String url, [bool secure = true]) {
  return WebSocketChannel.connect(Uri.parse('${secure ? Geno.wsBaseUrl :
  Geno.unSecureWsBaseUrl}' '$url'));
}

// an example of use.
// we want to get all user with 3 as id
//GDirectRequest.select(
//         sql: 'SELECT * FROM student WHERE id = ? ',
//         values: [3]
//    ).exec(
//         onSuccess: (results) {
//           results.data.forEach((element) {
//             print(element);
//
//           });
//         }, onError: (error) {
//           print(error);
//     });
class GDirectRequest {
  String? connectionId;
  String sql;
  GRequestType type;
  String table;
  List<dynamic>? values;

  GDirectRequest(
      {
        required this.sql,
        required this.type,
        required this.table,
        this.connectionId,
        this.values});

  factory GDirectRequest.select({
    required String sql,
    List<dynamic>? values,
  }) {
    return GDirectRequest(
        connectionId: Geno.connectionId,
        sql: sql,
        type: GRequestType.select,
        table: '',
        values: values);
  }

  factory GDirectRequest.insert({
    required String table,
    required String sql,
    List<dynamic>? values,
  }) {
    return GDirectRequest(
        connectionId: Geno.connectionId,
        sql: sql,
        type: GRequestType.insert,
        table: table,
        values: values);
  }

  factory GDirectRequest.update({
    required String table,
    required String sql,
    List<dynamic>? values,
  }) {
    return GDirectRequest(
        connectionId: Geno.connectionId,
        sql: sql,
        type: GRequestType.update,
        table: table,
        values: values);
  }

  factory GDirectRequest.delete({
    required String table,
    required String sql,
    List<dynamic>? values,
  }) {
    return GDirectRequest(
        connectionId: Geno.connectionId,
        sql: sql,
        type: GRequestType.delete,
        table: table,
        values: values);
  }

  factory GDirectRequest.create({
    required String table,
    required String sql,
    List<dynamic>? values,
  }) {
    return GDirectRequest(
        connectionId: Geno.connectionId,
        sql: sql,
        type: GRequestType.create,
        table: table,
        values: values);
  }

  factory GDirectRequest.drop({
    required String table,
    required String sql,
    List<dynamic>? values,
  }) {
    return GDirectRequest(
        connectionId: Geno.connectionId,
        sql: sql,
        type: GRequestType.drop,
        table: table,
        values: values);
  }

  String _toJson() {
    return jsonEncode({
      gAppSignature: Geno.appSignature,
      gConnectionId: connectionId,
      gTable: table,
      gType: type.toString(),
      gValues: values,
      gSql: sql,
    });
  }

  exec({
    required Function(Result) onSuccess,
    required Function(String) onError,
    bool secure = true,
  }) async {

      final url = Uri.parse('${secure ? Geno.baseUrl :
      Geno.unsecureBaseUrl}request');

      try {
        final response = await http.post(
            url,
            headers: {
              'Content-type': 'application/json',
              //'origin': 'http://localhost'
            },
            body: _toJson()
        );

        if (response.statusCode == 200) {
          Result result = Result.fromJson(response.body);
          if (result.errorHappened) {
            onError(result.error);
          } else {
            onSuccess(result);
          }
        } else {
          onError(response.body.toString());
        }
      } catch (e)  {
        onError(e.toString());
      }
  }
}

enum GRequestType {
  select,
  update,
  insert,
  create,
  drop,
  delete;

  @override
  String toString() {
    switch (this) {
      case GRequestType.select:
        return 'select';
      case GRequestType.update:
        return 'update';
      case GRequestType.insert:
        return 'insert';
      case GRequestType.delete:
        return 'delete';
      case GRequestType.create:
        return 'create';
      case GRequestType.drop:
        return 'drop';
    }
  }
}

const String gInterruptionError = 'Connection closed before full header was received';
const String unavailableHostError = 'Connection refused';
const String hostLookUpError = 'Failed host lookup';
