import 'package:customer_app/Model/user.dart';
import 'package:customer_app/Pages/Authenticate/authenticate.dart';
import 'package:customer_app/Pages/Home/home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // gets value from above widget in realtime
    // when it gets a user it goes to home automatically
    final user = Provider.of<User>(context);
    // authenticate if there is a corresponding
    // customerUser with this user uid
    // if not delete this user account because
    // account creation has failed and needs to be
    // done again
    return user == null ? Authenticate() : Home();
  }
}
