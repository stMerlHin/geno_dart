

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
      print(Geno.connectionId);
      print(Uuid().v1());
      print(Uuid().v4());
      // print(Uuid().v5('high', 'geno_client'));
        GDirectRequest.select(sql: 'sql', table: 'table')
            .exec(
          secure: false,
            onSuccess: (result) {
              print('success');
            },
            onError: (err) {
            print(err);
        });
      }
  );

}
