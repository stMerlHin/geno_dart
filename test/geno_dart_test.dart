import 'package:geno_dart/geno_dart.dart';
import 'package:test/test.dart';

void main() {
  group('A group of tests', () {
    final Geno geno = Geno.instance;

    setUp(() {
      // Additional setup goes here.
    });

    test('Connexion error test while doing request', () async {
      await geno.initialize(
          appSignature: '91a2dbf0-292d-11ed-91f1-4f98460f463c',
          onInitialization: (_) async {
            await GDirectRequest.select(
                sql: '',
                table: 'table')
                .exec(
                secure: false,
                onSuccess: (_) {
                  print('h');
                },
                onError: (err) {
                  expect(err, 'Connection refused');
                });
          });

    });
  });
}
