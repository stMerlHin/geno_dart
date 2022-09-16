

import 'dart:convert';

import 'package:geno_dart/geno_dart.dart';

void main() async {
  var awesome = Awesome();
  print('awesome: ${awesome.isAwesome}');
  await Geno.instance.initialize(
      appSignature: '91a2dbf0-292d-11ed-91f1-4f98460f463c',
      appWsSignature: '91a2dbf0-292d-11ed-91f1-4f98460f464c',
      appPrivateDirectory: '.',
      host: 'localhost',
      port: '8080',
      unsecurePort: '80',
      onInitialization: (g) async {
        Auth auth = await Auth.instance;
        auth.changePassword(
          secure: false,
            email: 'tgrecycleinc@gmail.com',
            password: 'passoir]',
            newPassword: 'passoir',
            onSuccess: (){
              print('success');
            },
            onError: (e) {
              print(e);
            }
        );
        // auth.recoverPassword(
        //   secure: false,
        //     email: 'tgrecycleinc@gmail.com',
        //     onSuccess: () {
        //       print('success');
        //     },
        //     onError: (e) {
        //       print(e);
        //     }
        // );
        // auth.signingWithEmailAndPassword(
        //   secure: false,
        //   email: 'stevenalandou@gmail.com',
        //   password: 'password',
        //   onListenerDisconnected: (e) {
        //     print(e);
        //   },
        //   onEmailConfirmed: (User u) {
        //     print('CONFIRMED');
        //   },
        //   onEmailSent: () {
        //     print('EMAIL SENT');
        //   },
        //   onError: (e) {
        //     print('ERROR');
        //     print(e);
        //   },
        // );
        // auth.changeEmail(
        //   secure: false,
        //   newEmail: 'stevenalandou@gmail.com',
        //   oldEmail: 'stmerlhin@gmail.com',
        //   password: 'password',
        //   onListenerDisconnected: (e) {
        //     print(e);
        //   },
        //   onEmailConfirmed: () {
        //     print('CONFIRMED');
        //   },
        //   onEmailSent: () {
        //     print('EMAIL SENT');
        //   },
        //   onError: (e) {
        //     print('ERROR');
        //     print(e);
        //   },
        // );
      }
  );


}
