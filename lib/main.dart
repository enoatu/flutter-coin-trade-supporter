import 'package:flutter/material.dart';
import 'dart:async';
// ref
// https://zenn.dev/tomon9086/articles/d2624f6ab37c4c
// https://take424.dev/2021/05/22/flutter%E3%81%A7%E3%83%AD%E3%83%BC%E3%82%AB%E3%83%AB%E9%80%9A%E7%9F%A5%E3%81%AE%E5%8B%95%E4%BD%9C%E3%82%92%E7%A2%BA%E8%AA%8D%E3%81%99%E3%82%8B%EF%BC%8Fflutter_local_notifications/
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// ref
// https://pub.dev/packages/flutter_background_service
// https://smt-create.com/?p=346
import 'package:flutter_background_service/flutter_background_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeService();
  runApp(const MyApp());
}

final service = FlutterBackgroundService();

// loop
Future<void> onStart(ServiceInstance service) async {
  //service.on('stopService').listen((event) {
  //  service.stopSelf();
  //});
  service.on('startService').listen((event) {
    Timer.periodic(const Duration(seconds: 15), (timer) async {
      await showNotification();
    });
  });
}

Future<void> initializeService() async {
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will be executed when app is in foreground or background in separated isolate
      onStart: onStart,

      // auto start service
      autoStart: true,
      isForegroundMode: true,
    ),
    iosConfiguration: IosConfiguration(
      // this will be executed when app is in foreground or background in separated isolate
      // onStart: onStart,
    ),
  );
}
// Notice
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
Future<void> showNotification() async {
  var androidChannelSpecifics = const AndroidNotificationDetails(
    'CHANNEL_ID',
    'CHANNEL_NAME',
    channelDescription: "CHANNEL_DESCRIPTION",
    largeIcon: DrawableResourceAndroidBitmap('ic_stat_name'),
    icon: 'ic_stat_name',
    importance: Importance.max,
    priority: Priority.high,
    playSound: false,
    timeoutAfter: 5000,
    styleInformation: DefaultStyleInformation(
      true,
      true,
    ),
  );

  var iosChannelSpecifics = const DarwinNotificationDetails();

  var platformChannelSpecifics = NotificationDetails(
    android: androidChannelSpecifics,
    iOS: iosChannelSpecifics,
  );

  await flutterLocalNotificationsPlugin.show(
    1, // Notification ID
    'Test Title', // Notification Title
    'Test Body', // Notification Body, set as null to remove the body
    platformChannelSpecifics,
    payload: 'New Payload', // Notification Payload
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                showNotification(); // 通知をすぐに表示
              },
              child: const Text('すぐに通知を表示'),
            ),
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
            ElevatedButton(
                child: const Text("Start Notication"),
                onPressed: () {
                  service.invoke('startService');
                }),
            ElevatedButton(
                child: const Text("Stop Notication"),
                onPressed: () {
                  service.invoke("stopService");
                }),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
