import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:qbmatic/screens/main_rider.dart';
import 'package:qbmatic/screens/main_shop.dart';
import 'package:qbmatic/screens/main_user.dart';
import 'package:qbmatic/screens/signUp.dart';
import 'package:qbmatic/screens/signin.dart';
import 'package:qbmatic/utility/my_style.dart';
import 'package:qbmatic/utility/normal_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkPreference();

    initFirebaseMessaging();
  }

  Future<Null> checkPreference() async {
    try {
      FirebaseMessaging firebaseMessaging = FirebaseMessaging();
      String token = await firebaseMessaging.getToken();
      print("token <====> $token");

      SharedPreferences preferences = await SharedPreferences.getInstance();
      String chooseType = preferences.getString('ChooseType');
      if (chooseType != null && chooseType.isNotEmpty) {
        if (chooseType == 'User') {
          routeToService(MainUser());
        } else if (chooseType == 'Shop') {
          routeToService(MainShop());
        } else if (chooseType == 'Rider') {
          routeToService(MainRider());
        } else {
          normalDialog(context, 'Error User Type');
        }
      }
    } catch (e) {
      print(e);
    }
  }

  void initFirebaseMessaging() {
    FirebaseMessaging firebaseMessaging = FirebaseMessaging();
    // String token = await firebaseMessaging.getToken();
    // print("token <====> $token");
    firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );

    firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });

    firebaseMessaging.getToken().then((String token) {
      assert(token != null);
      print("Token : $token");
    });
  }

  void routeToService(Widget myWidget) {
    MaterialPageRoute route = MaterialPageRoute(builder: (context) => myWidget);
    Navigator.pushAndRemoveUntil(context, route, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QBMATIC'),
      ),
      drawer: showDrawer(),
    );
  }

  Drawer showDrawer() => Drawer(
        child: ListView(
          children: <Widget>[showHeadDrawer(), signInMenu(), signUpMenu()],
        ),
      );

  ListTile signInMenu() => ListTile(
        leading: Icon(Icons.login),
        title: Text("Sign In"),
        onTap: () {
          Navigator.pop(context);
          MaterialPageRoute route =
              MaterialPageRoute(builder: (value) => SignIn());
          Navigator.push(context, route);
        },
      );

  ListTile signUpMenu() => ListTile(
        leading: Icon(Icons.android),
        title: Text("Sign Up"),
        onTap: () {
          Navigator.pop(context);
          MaterialPageRoute route =
              MaterialPageRoute(builder: (value) => SignUp());
          Navigator.push(context, route);
        },
      );

  UserAccountsDrawerHeader showHeadDrawer() {
    return UserAccountsDrawerHeader(
      decoration: MyStyle().myBoxDecoration('guest.jpg'),
      currentAccountPicture: MyStyle().showLogo(),
      accountName: Text("Guest"),
      accountEmail: Text('Please Login'),
    );
  }
}
