

import 'dart:convert';

import 'package:geno_dart/geno_dart.dart';

void main() async {
  var awesome = Awesome();
  print('awesome: ${awesome.isAwesome}');
  await Geno.instance.initialize(
      appSignature: '91a2dbf0-292d-11ed-91f1-4f98460f463c',
      host: 'localhost',
      port: '8080',
      unsecurePort: '80',
      onInitialization: (g) async {
        Auth auth = await Auth.instance;
        auth.loginWithEmailAndPassword(
          secure: false,
            email: 'stevenalandou@gmail.com',
            password: 'password',
            onSuccess: (r) {
              print('SUCCESS');
              print(r);
            },
            onError: (e) {
              print('ERROR');
              print(e);
            }
        );
      }
  );

  String s = jsonEncode({'es': {'h': 9}, 'fr': {'h': [{'es': {'h': {'zinc': 9, 'pw': 2.0},'k': {'zin': 10}}}]}});
  print(s);

  // var d = jsonDecode("["
  //     "suit: {"
  //     ""hd": 3"
  //     "}"
  //     "]");
  // print(d);

}
