// MyID SDK integratsiyasi testlari: konfiguratsiya JSON serializatsiyasi va
// MyIdClient.start ning 'myid_uz' metod kanali orqali ishlashi tekshiriladi.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myid/enums.dart';
import 'package:myid/myid.dart';
import 'package:myid/myid_config.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MyIdConfig', () {
    test('berilgan qiymatlar JSON ga to\'g\'ri o\'tadi', () {
      final config = MyIdConfig(
        sessionId: 'test-session-id',
        clientHash: 'test-client-hash',
        clientHashId: 'test-client-hash-id',
        environment: MyIdEnvironment.DEBUG,
        entryType: MyIdEntryType.IDENTIFICATION,
        locale: MyIdLocale.UZBEK,
      );

      final json = config.toJson();

      expect(json['sessionId'], 'test-session-id');
      expect(json['clientHash'], 'test-client-hash');
      expect(json['clientHashId'], 'test-client-hash-id');
      expect(json['environment'], 'DEBUG');
      expect(json['entryType'], 'IDENTIFICATION');
      expect(json['locale'], 'UZBEK');
    });

    test('null maydonlar JSON ga kiritilmaydi', () {
      final json = MyIdConfig(sessionId: 'faqat-session').toJson();

      expect(json.keys, ['sessionId']);
    });
  });

  group('MyIdClient.start', () {
    testWidgets('metod kanali orqali natijani qaytaradi', (tester) async {
      const channel = MethodChannel('myid_uz');
      Map<Object?, Object?>? sentArguments;

      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel,
          (call) async {
        expect(call.method, 'startSdk');
        sentArguments = call.arguments as Map<Object?, Object?>;
        return {'code': 'test-auth-code', 'base64': null};
      });
      addTearDown(() => tester.binding.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null));

      final result = await MyIdClient.start(
        config: MyIdConfig(
          sessionId: 'test-session-id',
          environment: MyIdEnvironment.DEBUG,
        ),
      );

      expect(result.code, 'test-auth-code');
      final sentConfig = sentArguments!['config'] as Map<Object?, Object?>;
      expect(sentConfig['sessionId'], 'test-session-id');
      expect(sentConfig['environment'], 'DEBUG');
    });
  });
}
