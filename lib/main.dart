import 'dart:convert';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:myid/enums.dart';
import 'package:myid/myid.dart';
import 'package:myid/myid_config.dart';
import 'package:myidsdkdemoapp/passportserialnumber_formatter.dart';
import 'package:myidsdkdemoapp/universal_formatter.dart';

import 'birthday_formatter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController passSNPnflController = TextEditingController();
  final TextEditingController birthdayController = TextEditingController();
  final TextEditingController pnflController = TextEditingController();
  final TextEditingController passportSerialNumber = TextEditingController();
  final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  bool isResidentBoolean = true;
  bool _isLoading = false;

  double _threshold = 0.8;

  // 1. Validatorlar ishlashi uchun FORM KEY yaratamiz
  String? _error;
  MyIdResult? _result;
  String base_url = "https://api.devmyid.uz";
  String? _accessToken;
  String? _sessionId;

  // 1. FAQAT API TEST QILISH UCHUN FUNKSIYA

  Future<void> _getAccessToken() async {
    print("========== START: func _getAccessToken() ==========");

    const client_id = 'test_sdk-QYMePVnmZrKtQpUtlpP4NmjAjeyK5tFiAdgd0MeK';
    const client_secret =
        '5bwO8pkeGsd9n1EdREh4QJnfMR5YkhCfTzZqTH0xuD9Sa3lWZXUVtG0MdYRsGqcR7NEppVyG09fCqIgCv21JbqRqmBQyQCzfbVAO';

    String endPointAT = "/api/v1/auth/clients/access-token";

    var headers = {'Content-Type': 'application/json'};

    var request = http.Request('POST', Uri.parse(base_url + endPointAT));

    request.body = json.encode({
      "client_id": client_id,
      "client_secret": client_secret,
    });

    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        String resBody = await response.stream.bytesToString();
        print("API Success: $resBody");

        // JSON responseni parse qilish
        final Map<String, dynamic> responseData = json.decode(resBody);

        setState(() {
          // We store the token in a variable
          _accessToken = responseData['access_token'];
        });

        print("API Success saved _accessToken: $_accessToken");

        // Token olinishi bilan getSessionId() ishga tushuriladi
        // _getSessionId();

        // AGAR TOKEN KELISHI BILAN AVTOMATIK SDK BOSHLANISHINI XOXLASANGIZ:
        // Keyingi qatordagi izohni olib tashlang:
        // _startSdkWithToken();
      } else {
        print("API Error Reason (_getAccessToken): ${response.reasonPhrase}");
      }
    } catch (e) {
      print("Network Error in _getAccessToken: $e");
    }
  }

  Future<void> init2(
    String? phoneNumber,
    String? birthday,
    bool isResident,
    String? pass_data_pnfl,
    double? threshold,
  ) async {
    String? error;
    MyIdResult? result;

    await _getAccessToken();

    await _getSessionId(
      phoneNumber,
      birthday,
      isResident,
      pass_data_pnfl,
      threshold,
    );

    try {
      final sessionId = _sessionId;
      const clientHash =
          'MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAwGuhAUsVc3ZgxJRvENzSuwhcvCsQmbSLrYMEBU3azky380HqpmpdrNnW69nu0ODx6mdnQfYaManoYfaUh0G/lUCPVyQ3IRha+x1A+Cp/5pZsQuPoGSeXUusHki49b2m78gvYY0OJJp8LTpcHI6aC5vtzBBmz+yJg8o2rSdP9z/L42ICOrPU2hQ9OlsyB4jM70Prg+/Stqq4IAtSm3E6OouGu7pYbN4KL4BMBWIzzjKLJdsBqEiDE9mMPe1P9XQR/jyJ+DUk4I7afEll2JVYn2qjQFPyHXnNbXzS6YQiuF6IUdsPM+E9sK38kzOGzoLzQjnBWa5mt+/tr02eoqfqTBQIDAQAB';
      const clientHashId = '257fbf27-1c40-4c4d-a7e0-83f09eace896';

      final myIdResult = await MyIdClient.start(
        config: MyIdConfig(
          // PROVIDE CLIENT_ID, CLIENT_HASH and CLIENT_HASH_ID. YOU'VE GOT FROM YOUR BACKEND
          sessionId: sessionId,
          clientHash: clientHash,
          clientHashId: clientHashId,
          environment: MyIdEnvironment.DEBUG,
          entryType: MyIdEntryType.IDENTIFICATION,
        ),
        iosAppearance: const MyIdIOSAppearance(),
      );

      error = null;
      result = myIdResult;
      print("Result: $result");
    } catch (e) {
      error = e.toString();
      print("Error: $error");
      result = null;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _error = error;
      _result = result;
    });
  }

  Future<void> _getSessionId(
    String? phoneNumber,
    String? birthday,
    bool is_resident,
    String? pass_data_pnfl,
    double? threshold,
  ) async {
    print("========== START: func getSessionId() ==========");

    var requestBody;

    if (pass_data_pnfl != null) {
      String? firstChar = pass_data_pnfl[0];
      bool isLetter = RegExp(r'[a-zA-Z]').hasMatch(firstChar);
      bool isDigit = RegExp(r'[0-9]').hasMatch(firstChar);
      if (isLetter) {
        requestBody = {
          'birth_date': birthday,
          'pass_data': pass_data_pnfl,
          'is_resident': is_resident,
        };
      } else if (isDigit) {
        requestBody = {
          'birth_date': birthday,
          'pinfl': pass_data_pnfl,
          'is_resident': is_resident,
        };
      }
    } else {
      requestBody = {
        'birth_date': birthday,
        'pass_data': pass_data_pnfl,
        'is_resident': is_resident,
      };
    }

    String endPointgetSessionId = "/api/v2/sdk/sessions";

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_accessToken',
    };

    var request = http.Request(
      'POST',
      Uri.parse(base_url + endPointgetSessionId),
    );

    request.body = json.encode(requestBody);
    print("requestBody: $requestBody");

    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();
      String resBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("API Success (Session): $resBody");

        // JSON response'ni parse qilish
        final Map<String, dynamic> responseData = json.decode(resBody);

        setState(() {
          // We store the sessionId in a variable
          _sessionId = responseData['session_id'];
        });

        print("API Success saved _sessionId: $_sessionId");
      } else {
        print(
          "API Session Error Body (_getAccessToken): ${response.statusCode} | $resBody",
        );
      }
    } catch (e) {
      print("Network Error in getSessionId: $e");
    }
  }

  Future<void> init() async {
    String? error;
    MyIdResult? result;

    try {
      final sessionId = _sessionId;
      const clientHash =
          'MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAwGuhAUsVc3ZgxJRvENzSuwhcvCsQmbSLrYMEBU3azky380HqpmpdrNnW69nu0ODx6mdnQfYaManoYfaUh0G/lUCPVyQ3IRha+x1A+Cp/5pZsQuPoGSeXUusHki49b2m78gvYY0OJJp8LTpcHI6aC5vtzBBmz+yJg8o2rSdP9z/L42ICOrPU2hQ9OlsyB4jM70Prg+/Stqq4IAtSm3E6OouGu7pYbN4KL4BMBWIzzjKLJdsBqEiDE9mMPe1P9XQR/jyJ+DUk4I7afEll2JVYn2qjQFPyHXnNbXzS6YQiuF6IUdsPM+E9sK38kzOGzoLzQjnBWa5mt+/tr02eoqfqTBQIDAQAB';
      const clientHashId = '257fbf27-1c40-4c4d-a7e0-83f09eace896';

      final myIdResult = await MyIdClient.start(
        config: MyIdConfig(
          // PROVIDE CLIENT_ID, CLIENT_HASH and CLIENT_HASH_ID. YOU'VE GOT FROM YOUR BACKEND
          sessionId: sessionId,
          clientHash: clientHash,
          clientHashId: clientHashId,
          environment: MyIdEnvironment.PRODUCTION,
          entryType: MyIdEntryType.IDENTIFICATION,
        ),
        iosAppearance: const MyIdIOSAppearance(),
      );

      error = null;
      result = myIdResult;
      print("Result: $result");
    } catch (e) {
      error = e.toString();
      print("Error: $error");
      result = null;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _error = error;
      _result = result;
    });
  }

  Future<void> startSdk() async {
    print("========== START: func startSdk() ==========");
    String? phoneNumber = phoneNumberController.text.trim().isEmpty
        ? null
        : phoneNumberController.text.trim();
    String? birthday = birthdayController.text.trim().isEmpty
        ? null
        : birthdayController.text.trim();
    // String? passportSerial = passportSerialNumber.text.trim().isEmpty ? null : passportSerialNumber.text.trim();
    // String? pnfl = null;
    // String? passData = null;

    String? passDataPnfl = passSNPnflController.text.trim().isEmpty
        ? null
        : passSNPnflController.text.trim();
    bool isResidentStatus = isResidentBoolean;
    double? threshold = 0.8;
    print("isResidentStatus: $isResidentStatus");

    // if (birthday.isEmpty || passportSerial.isEmpty) {
    //   scaffoldMessengerKey.currentState!.showSnackBar(
    //     const SnackBar(content: Text("Barcha maydonlarni to'ldiring")),
    //   );
    //   return;
    // }

    init2(phoneNumber, birthday, isResidentStatus, passDataPnfl, threshold);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
      home: Scaffold(
        appBar: AppBar(title: const Text("MyId Sample")),
        body: Center(
          child: Column(
            children: [
              SizedBox(height: 10),
              TextField(
                controller: birthdayController,
                decoration: const InputDecoration(
                  labelText: "BirthDay",
                  hintText: "1996-03-04",
                  border: OutlineInputBorder(),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9-]')),
                  BirthdayInputFormatter(),
                ],
              ),
              SizedBox(height: 10),

              TextField(
                controller: passSNPnflController,
                decoration: const InputDecoration(
                  labelText: "SerialNumber | PNFL",
                  hintText: "AD1234567 | 12345678901234",
                  border: OutlineInputBorder(),
                ),
                inputFormatters: [UniversalPassSNPnflInputFormatter()],
              ),

              SizedBox(height: 10),
              TextField(
                controller: phoneNumberController,
                decoration: const InputDecoration(
                  labelText: "PhoneNumber",
                  hintText: "998901234567",
                  border: OutlineInputBorder(),
                ),
              ),

              if (false)
                TextField(
                  controller: pnflController,
                  decoration: const InputDecoration(
                    labelText: "PNFL",
                    hintText: "12345678901234",
                    border: OutlineInputBorder(),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    LengthLimitingTextInputFormatter(14),
                  ],
                ),

              Row(
                // 1. Elementlarni gorizontal (chapdan-o'ngga) o'rtaga tekislaydi
                mainAxisAlignment: MainAxisAlignment.center,
                // 2. Elementlarni vertikal (tepadan-pastga) bir xil o'rtada ushlaydi
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("IsResident"),
                  Switch(
                    value: isResidentBoolean,
                    onChanged: (bool value) {
                      setState(() {
                        isResidentBoolean = value;
                      });
                    },
                  ),
                ],
              ),

              Column(
                children: [
                  Text("Threshold: ${_threshold.toStringAsFixed(2)}"),
                  Slider(
                    value: _threshold,
                    min: 0.6,
                    max: 0.99,
                    divisions: 30,
                    onChanged: (double value) {
                      setState(() {
                        _threshold = value;
                      });
                    },
                  ),
                ],
              ),

              MaterialButton(
                onPressed: startSdk,
                color: Colors.blue,
                textColor: Colors.white,
                child: const Text("Start SDK"),
              ),
              const SizedBox(height: 10),
              // Result or Error
              Text(_result?.code ?? _error ?? 'Status'),

              const SizedBox(height: 20),

              if (false)
                Column(
                  children: [
                    TextField(
                      controller: passportSerialNumber,
                      decoration: InputDecoration(
                        labelText: "Passport Serial",
                        hintText: "AA1234567",
                        border: OutlineInputBorder(),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[A-Za-z0-9]'),
                        ),
                        LengthLimitingTextInputFormatter(9),
                        PassportserialnumberFormatter(),
                      ],
                    ),
                    MaterialButton(
                      onPressed: _getAccessToken,
                      color: Colors.green,
                      textColor: Colors.white,
                      child: const Text("Test API"),
                    ),
                    SizedBox(height: 10),
                    Text("Result uchun joy"),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

//============================================================================
//============================================================================

class MyApp1 extends StatelessWidget {
  const MyApp1({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'MyIdFlutterSDK'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: .center,
          children: [
            const Text('Iye sen nega click qilayapsan, uje shuncha bosding :'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
