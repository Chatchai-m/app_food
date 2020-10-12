import 'package:flutter/material.dart';
import 'package:qbmatic/screens/home.dart';

main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.green),
      title: "Qbmatic", 
      home: Home()
    );
  }
}

