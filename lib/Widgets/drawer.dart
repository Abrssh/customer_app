import 'package:customer_app/Pages/Report%20Page/help.dart';
import 'package:customer_app/Pages/Report%20Page/transactionHis.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  String email, paymentID;
  MyDrawer(this.email, this.paymentID);
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: const EdgeInsets.all(0),
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text("Payment ID: " + paymentID),
            accountEmail: Text(email),
            currentAccountPicture: CircleAvatar(
              // backgroundImage: NetworkImage(
              //     "https://images.unsplash.com/photo-1505925597504-8498e34adf27?ixlib=rb-1.2.1&auto=format&fit=crop&w=1053&q=80"),
              backgroundImage: AssetImage("assets/wide.jpg"),
            ),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text("Account"),
            subtitle: Text("Customer"),
            trailing: Icon(Icons.edit),
            onTap: () => {},
          ),
          ListTile(
            leading: Icon(Icons.email),
            title: Text("Transaction History"),
            onTap: () => {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => TransactionHistroy()))
            },
          ),
          ListTile(
            leading: Icon(Icons.map),
            title: Text("Trips"),
            onTap: () => {},
          ),
          ListTile(
            leading: Icon(Icons.help),
            title: Text("Help"),
            onTap: () => {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Help(),
                  ))
            },
          ),
          ListTile(
            leading: Icon(Icons.contact_phone),
            title: Text("About Us"),
            onTap: () => {},
          ),
        ],
      ),
    );
  }
}
