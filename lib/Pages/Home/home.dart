import 'package:customer_app/Model/user.dart';
import 'package:customer_app/Pages/Home/Ticket_page.dart';
import 'package:customer_app/Pages/Home/map_Page.dart';
import 'package:customer_app/Services/Database.dart';
import 'package:customer_app/Services/authServ.dart';
import 'package:customer_app/Widgets/drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AuthService _authService = AuthService();

  int _currentIndex = 0;

  final tabs = [
    TicketPage(),
    MapPage(),
  ];
  // below are all the variables used in the proccess
  // of fetching balance data from the server in this
  // class
  Stream balanceStream;
  // serves as a place holder for balance of the customer
  // when it comes from the server assigned -1 initally
  // to check if data has arrived or not
  int balance = -1;
  // make sure the listen stream is called once
  bool runOnce = false;

  String email = "", paymentID = "";

  @override
  Widget build(BuildContext context) {
    if (runOnce == false) {
      var userID = Provider.of<User>(context).uid;
      balanceStream = DatabaseService(customerUserID: userID).balance;
      balanceStream.listen((event) {
        setState(() {
          balance = event;
        });
      });
      email = Provider.of<User>(context).email;
      DatabaseService(customerUserID: userID).getCustomerDoc().then((value) {
        paymentID = value.data["paymentID"];
      });
      runOnce = true;
    }
    return Scaffold(
      appBar: AppBar(
        title: balance != -1
            ? Text("Balance : " + balance.toString())
            : Text("Waiting for data..."),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              _authService.signOut();
            },
          )
        ],
        centerTitle: true,
      ),
      body: tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 40,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text("Home"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.train),
            title: Text("Map"),
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      drawer: MyDrawer(email, paymentID),
    );
  }
}
