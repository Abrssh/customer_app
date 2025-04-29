import 'package:customer_app/Model/user.dart';
import 'package:customer_app/Pages/wrapper.dart';
import 'package:customer_app/Services/authServ.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider<User>.value(
      value: AuthService().user,
      child: MaterialApp(
        home: Wrapper(),
        theme: ThemeData(
          primarySwatch: Colors.green,
          backgroundColor: Colors.white,
        ),
      ),
    );
  }
}
