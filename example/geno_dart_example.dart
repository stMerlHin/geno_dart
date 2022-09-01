

import 'package:geno_dart/geno_dart.dart';
import 'package:uuid/uuid.dart';

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

}
