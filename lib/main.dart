import 'package:agconnect_crash/agconnect_crash.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:huawei_analytics/huawei_analytics.dart';
import 'package:huawei_push/huawei_push.dart';
import 'package:flutter_hms_example/ScanPage.dart';
import 'package:permission_handler/permission_handler.dart';

import 'LocationPage.dart';
import 'MapPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromRGBO(199, 0, 10, 1)),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const MyHomePage(),
        '/MapPage': (context) => const MapPage(),
        '/LocationPage': (context) => const LocationPage(),
        '/ScanPage': (context) => const ScanPage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _token = '';

  void _onTokenEvent(String event) {
    // Requested tokens can be obtained here
    setState(() {
      _token = event;
    });
    print("HMSMSGG TokenEvent: " + _token);
  }

  void _onTokenError(Object error) {
    //PlatformException e = error;
    print("HMSMSGG TokenErrorEvent: " + error.toString());
  }

  void _onMessageReceived(RemoteMessage remoteMessage) {
    // Called when a data message is received
    String? data = remoteMessage.data;
    print("HMSMSGG DATA RECIEVED:: " + data.toString());
  }

  void _onMessageReceiveError(Object error) {
    // Called when an error occurs while receiving the data message
    print("HMSMSGG DATA ERRO:: " + error.toString());
  }

  void _onNewIntent(String intentString) {
    // For navigating to the custom intent page (deep link)
    // The custom intent that sent from the push kit console is:
    // app://open.my.app/CustomIntentPage
    if (intentString != null) {
      print('HMSMSGG CustomIntentEvent: ' + intentString);
      // List parsedString = intentString.split("://open.my.app/");
      // if (parsedString[1] == "CustomIntentPage") {
      //   // Schedule the navigation after the widget is builded.
      //   SchedulerBinding.instance.addPostFrameCallback((_) {
      //     Navigator.of(context).push(MaterialPageRoute(builder: (context) => CustomIntentPage()));
      //   });
      // }
    }
  }

  void _onIntentError(Object err) {
    PlatformException? e = err as PlatformException?;
    print("Error on intent stream: " + e.toString());
  }

  @override
  void initState() {
    super.initState();

    // Init HMS Push
    initTokenStream();
    getToken();
    initMessageStream();
    initMessageStreamForBackground();
    initIntentStream();

    // Init HMS Analytics
    initHmsAnalytics();
  }

  Future<void> initHmsAnalytics() async {
    final HMSAnalytics hmsAnalytics = await HMSAnalytics.getInstance();
    await hmsAnalytics.enableLog();
  }

  Future<void> initTokenStream() async {
    print("HMSMSGG START TWO:: ");

    if (!mounted) return;
    Push.getTokenStream.listen(_onTokenEvent, onError: _onTokenError);
    print("HMSMSGG END:: ");
  }

  Future<void> initMessageStream() async {
    if (!mounted) return;
    Push.onMessageReceivedStream
        .listen(_onMessageReceived, onError: _onMessageReceiveError);
  }

  Future<void> initMessageStreamForBackground() async {
    print("HMSMSGG BACKGROUND START");
    bool backgroundMessageHandler =
        await Push.registerBackgroundMessageHandler(backgroundMessageCallback);
    print("HMSMSGG BACKGROUND OK: $backgroundMessageHandler");
  }

  static void backgroundMessageCallback(RemoteMessage remoteMessage) async {
    String? data = remoteMessage.data;
    print("HMSMSGG BACKGROUND: $data");

    Push.localNotification({
      HMSLocalNotificationAttr.TITLE: '[Headless] DataMessage Received',
      HMSLocalNotificationAttr.MESSAGE: data
    });
  }

  Future<void> initIntentStream() async {
    if (!mounted) return;
    Push.getIntentStream.listen(_onNewIntent, onError: _onIntentError);
    String? intent = await Push.getInitialIntent();
    _onNewIntent(intent!);
  }

  void getToken() async {
    // Call this method to request for a token
    print("___Request for a token !!!!!!!!!");
    Push.getToken("");
  }

  // void subscribe() async {
  //   String topic = "testTopic";
  //   String result = await Push.subscribe(topic);
  // }

  @override
  Widget build(BuildContext context) {
    void requestPerms(type) async {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.locationWhenInUse,
        Permission.locationAlways,
      ].request();

      if (await Permission.location.status.isGranted) {
        if (type == "Map")
          Navigator.pushNamed(context, '/MapPage');
        else
          Navigator.pushNamed(context, '/LocationPage');
      } else {
        openAppSettings();
      }
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('Home Page'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                child: const Text('Open Map Page'),
                onPressed: () {
                  requestPerms("Map");
                },
              ),
              ElevatedButton(
                child: const Text('Open Location Page'),
                onPressed: () {
                  requestPerms("Location");
                },
              ),
              ElevatedButton(
                child: const Text('Open Scan Page'),
                onPressed: () {
                  Navigator.pushNamed(context, '/ScanPage');
                },
              ),
              ElevatedButton(
                child: const Text('Test Crash'),
                onPressed: () {
                  AGCCrash.instance.testIt();
                },
              )
            ],
          ),
        ));
  }
}
