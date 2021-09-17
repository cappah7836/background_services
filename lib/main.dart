import 'dart:convert';

import 'package:background_services/post_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:workmanager/workmanager.dart';

import 'dart:convert' as convert;
import 'package:http/http.dart' as http;

import 'Service.dart';




const myTask = "syncWithTheBackEnd";
final HttpService httpService = HttpService();
// flutter local notification setup
void showNotification(v, flp) async {
  var android = AndroidNotificationDetails(
      'channel id', 'channel NAME', 'Background Services');
  var iOS = IOSNotificationDetails();
  var platform = NotificationDetails(android: android, iOS: iOS);
  await flp.show(0, 'Back Services', '$v', platform,
      payload: 'VIS \n $v');
}


void callbackDispatcher() {
// this method will be called every 2 minutes
  Workmanager().executeTask((task, inputdata) async {
    FlutterLocalNotificationsPlugin flp = FlutterLocalNotificationsPlugin();
    var android = AndroidInitializationSettings('ic_launcher');
    var iOS = IOSInitializationSettings();
    var initSetttings = InitializationSettings(android: android, iOS: iOS);
    flp.initialize(initSetttings);
    httpService.getPosts();
    showNotification('Background Services Running', flp);
        print("This method was called from native!");
        Fluttertoast.showToast(msg: "This method was called from native!");


    //Return true when the task executed successfully or not
    return Future.value(true);
  });
}

Future<void> main() async{
  // needs to be initialized before using workmanager package
  WidgetsFlutterBinding.ensureInitialized();
  // initialize Workmanager with the function which you want to invoke after any periodic time
  Workmanager().initialize(callbackDispatcher);

  // Periodic task registration
  // Periodic task registration
  Workmanager().registerPeriodicTask(
    "2",
    myTask,
    // When no frequency is provided the default 15 minutes is set.
    // Minimum frequency is 15 min. Android will automatically change your frequency to 15 min if you have configured a lower frequency.
    frequency: Duration(minutes: 2),

  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Background Services'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

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

        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: FutureBuilder(
        future: httpService.getPosts(),
    builder: (BuildContext context, AsyncSnapshot<List<Post>> snapshot) {
    if (snapshot.hasData) {
    List<Post>? posts = snapshot.data;
    return ListView(
    children: posts!
        .map(
    (Post post) => ListTile(
    title: Text(post.title),
    subtitle: Text(post.body),
      trailing: Text("${post.userId}"),
    ),
    )
        .toList(),
    );
    } else {
    return Center(child: CircularProgressIndicator());
    }
    },
    ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
