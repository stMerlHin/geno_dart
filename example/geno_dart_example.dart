

import 'dart:convert';

import 'package:geno_dart/geno_dart.dart';
import 'package:uuid/uuid.dart';

void main() async {

  await Geno.instance.initialize(
      appSignature: '91a2dbf0-292d-11ed-91f1-4f98460f463c',
      appWsSignature: '91a2dbf0-292d-11ed-91f1-4f98460f464c',
      appPrivateDirectory: '.',
      encryptionKey: '91a2dbf0-292d-11ed-91f1-4f98460d',
      host: 'localhost',
      port: '8080',
      unsecurePort: '80',
      onInitialization: (g) async {
        // Auth auth = await Auth.instance;
        // if(auth.user != null) {
        //   print(auth.user!.toString());
        // } else {
        //   print('unauthenticated user');
        // }
        DataListener l = DataListener(table: 'company');
        l.listen(() {
          print('changed');
        },
            onError: (e) {
              print('On ERROR 1');
            },
            secure: false
        );

        DataListener(table: 'company').listen(() {
          print('changed');
        },
            onError: (e) {
          print('On ERROR 2');
        },
          secure: false
        );

        DataListener(table: 'company', tag: 'wi').listen(() {
          print('changed');
        },
            onError: (e) {
          print('On ERROR 3');
            },
            secure: false
        );
        //print(auth.user.toString());
        // auth.loginWithEmailAndPassword(
        //   secure: false,
        //     email: 'stevenalandou@gmail.com',
        //     password: '4fd4d',
        //     onSuccess: (User user) {
        //       print("SUCCESS");
        //       print(user.uid);
        //     },
        //     onError: (e) {
        //   print(e);
        // });

        // auth.loginWithPhoneNumber(
        //   secure: false,
        //     phoneNumber: '+228 98882061',
        //     onSuccess: (u) {
        //       print('SUCCESS');
        //     },
        //     onError: (e) {
        //       print(e.toString());
        //     });
        // auth.changePhoneNumber(
        //   secure: false,
        //     phoneNumber: '98882061',
        //     newPhoneNumber: '93359228',
        //     onSuccess: () {
        //       print('SUCCESS');
        //     },
        //     onError: (e) {
        //       print('ERROR $e');
        //     });
        // auth.changePassword(
        //   secure: false,
        //     email: 'tgrecycleinc@gmail.com',
        //     password: 'passoir]',
        //     newPassword: 'passoir',
        //     onSuccess: (){
        //       print('success');
        //     },
        //     onError: (e) {
        //       print(e);
        //     }
        // );
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
        //   email: 'serge@miaplenou.com',
        //   password: '12413',
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
