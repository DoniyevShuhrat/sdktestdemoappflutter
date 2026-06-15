import 'package:flutter/material.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:myid/enums.dart';
import 'package:myid/myid.dart';
import 'package:myid/myid_config.dart';

void main() {
    runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

    @override
    State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
    String? _error;
    MyIdResult? _result;

    Future<void> init() async {
        String? error;
        MyIdResult? result;

        try {
            const sessionId = 'your_session_id';
            const clientHash = 'MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAwGuhAUsVc3ZgxJRvENzSuwhcvCsQmbSLrYMEBU3azky380HqpmpdrNnW69nu0ODx6mdnQfYaManoYfaUh0G/lUCPVyQ3IRha+x1A+Cp/5pZsQuPoGSeXUusHki49b2m78gvYY0OJJp8LTpcHI6aC5vtzBBmz+yJg8o2rSdP9z/L42ICOrPU2hQ9OlsyB4jM70Prg+/Stqq4IAtSm3E6OouGu7pYbN4KL4BMBWIzzjKLJdsBqEiDE9mMPe1P9XQR/jyJ+DUk4I7afEll2JVYn2qjQFPyHXnNbXzS6YQiuF6IUdsPM+E9sK38kzOGzoLzQjnBWa5mt+/tr02eoqfqTBQIDAQAB';
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
                iosAppearance: const MyIdIOSAppearance());

            error = null;
            result = myIdResult;
        } catch (e) {
            error = e.toString();
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

    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            home: Scaffold(
                appBar: AppBar(
                    title: const Text("MyId Sample"),
                ),
                body: Center(
                    child: Column(
                        children: [
                            MaterialButton(
                                onPressed: init,
                                child: const Text("Start SDK"),
                            ),
                            Text(_result?.code ?? _error ?? 'Failure')
                        ],
                    ),
                ),
            )
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
