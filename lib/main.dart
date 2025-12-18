import 'dart:async' ;
import 'package:path/path.dart' ;
import 'package:sqflite/sqflite.dart' ;
import 'package:flutter/material.dart' ;
import 'package:tasktracker/pages/login.dart';

import 'database/database.dart' ;
import 'models/task.dart' ;
import 'pages/home.dart' ;
import 'models/user.dart' ;
import './debug-db.dart' ;

void main() async {
  WidgetsFlutterBinding.ensureInitialized() ;
  DebugDB debug = DebugDB();
  await debug.run();

  runApp(MyApp()) ;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: false,
        fontFamily: 'Poppins'
        ), 
      home: const LoginPage(),
    );
  }
}