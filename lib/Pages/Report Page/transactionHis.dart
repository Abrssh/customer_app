import 'package:customer_app/Model/transaction.dart';
import 'package:customer_app/Model/user.dart';
import 'package:customer_app/Services/Database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TransactionHistroy extends StatefulWidget {
  @override
  _TransactionHistroyState createState() => _TransactionHistroyState();
}

class _TransactionHistroyState extends State<TransactionHistroy> {
  List<TransactionModel> trans;

  bool runOnce = false;

  @override
  Widget build(BuildContext context) {
    if (runOnce == false) {
      var userID = Provider.of<User>(context).uid;
      DatabaseService(customerUserID: userID).transactions.listen((event) {
        trans = event;
        print("lENG : " + trans.length.toString());
        if (runOnce == false) {
          if (trans.length > 0) runOnce = true;
        }
        setState(() {});
      });
    }
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Transaction History",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w400))
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                height: 600,
                width: 350,
                child: runOnce
                    ? ListView.builder(
                        itemBuilder: (context, index) {
                          return Card(
                            child: ListTile(
                              leading: Text("Date: " + trans[index].date),
                              title: Text("Type: " + trans[index].type),
                              trailing: Text(
                                  "Amount : " + trans[index].amount.toString()),
                            ),
                          );
                        },
                        itemCount: trans.length,
                      )
                    : Text("Loading...."),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
