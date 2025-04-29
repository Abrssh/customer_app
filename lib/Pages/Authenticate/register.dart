import 'package:customer_app/Services/Database.dart';
import 'package:customer_app/Services/authServ.dart';
import 'package:customer_app/Shared/constant.dart';
import 'package:customer_app/Shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';

class Register extends StatefulWidget {
  final Function toggleView;
  Register({this.toggleView});
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  // initialize connection with firebase authentication
  final AuthService _authService = AuthService();
  String email = "", password = "", error = "";
  String firstName = "", lastName = "", phoneNumber = "", neighborhood = "";
  int balance = 0;

  // 1 means men 2 means women
  int sex = 1; // for radio button
  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : Scaffold(
            backgroundColor: Colors.green[100],
            appBar: AppBar(
              backgroundColor: Colors.green[400],
              elevation: 0.0,
              title: Text("Sign Up to Train Ticket app"),
              actions: [
                FlatButton.icon(
                    onPressed: () {
                      widget.toggleView();
                    },
                    icon: Icon(Icons.person),
                    label: Text("Sign In"))
              ],
            ),
            body: SingleChildScrollView(
              child: Container(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          decoration:
                              textInputDecoration.copyWith(hintText: "Email"),
                          validator: (value) =>
                              value.isEmpty ? "Enter an Email" : null,
                          onChanged: (value) {
                            setState(() {
                              email = value;
                            });
                          },
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          decoration: textInputDecoration.copyWith(
                              hintText: "Password"),
                          obscureText: true,
                          validator: (value) => value.length < 6
                              ? "Enter a password of 6+ character"
                              : null,
                          onChanged: (value) {
                            setState(() {
                              password = value;
                            });
                          },
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          decoration: textInputDecoration.copyWith(
                              hintText: "First Name"),
                          validator: (value) =>
                              value.isEmpty ? "Enter a Name Please" : null,
                          onChanged: (value) {
                            setState(() {
                              firstName = value;
                            });
                          },
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          decoration: textInputDecoration.copyWith(
                              hintText: "Last Name"),
                          validator: (value) =>
                              value.isEmpty ? "Enter a Name Please" : null,
                          onChanged: (value) {
                            setState(() {
                              lastName = value;
                            });
                          },
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          width: 300,
                          height: 50,
                          child: Row(
                            children: [
                              Text("Sex : "),
                              Radio(
                                value: 1,
                                groupValue: sex,
                                onChanged: (value) {
                                  setState(() {
                                    sex = value;
                                  });
                                },
                              ),
                              Text("Male"),
                              Radio(
                                value: 2,
                                groupValue: sex,
                                onChanged: (value) {
                                  setState(() {
                                    sex = value;
                                  });
                                },
                              ),
                              Text("Female")
                            ],
                          ),
                        ),
                        TextFormField(
                          decoration: textInputDecoration.copyWith(
                              hintText: "Neighborhood"),
                          validator: (value) =>
                              value.isEmpty ? "Enter Your Neighborhood" : null,
                          onChanged: (value) {
                            setState(() {
                              neighborhood = value;
                            });
                          },
                          keyboardType: TextInputType.text,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          decoration: textInputDecoration.copyWith(
                              hintText: "Phone Number"),
                          validator: (value) =>
                              value.length < 10 || value.length > 10
                                  ? "Enter a 10 digit PhoneNumber Please"
                                  : null,
                          onChanged: (value) {
                            setState(() {
                              phoneNumber = value;
                            });
                          },
                          keyboardType: TextInputType.phone,
                        ),
                        RaisedButton(
                          onPressed: () async {
                            if (_formKey.currentState.validate()) {
                              setState(() {
                                loading = true;
                              });
                              // gives customer unique id for payment processing
                              // which the portal can use to deposit or withdraw
                              // to customer Balance
                              String paymentID = randomNumeric(7);
                              // make sure no collison happens
                              // between payment Id of customers
                              DatabaseService()
                                  .checkPaymentID(paymentID)
                                  .then((value) async {
                                if (value == true) {
                                  dynamic result = await _authService
                                      .registerWithEmailPassword(
                                          email, password);
                                  if (result == null) {
                                    setState(() {
                                      loading = false;
                                      error =
                                          "Something wrong with email or password";
                                    });
                                  } else {
                                    Future accountStat = DatabaseService()
                                        .createCustomerAccount(
                                            firstName,
                                            lastName,
                                            sex,
                                            phoneNumber,
                                            neighborhood,
                                            balance,
                                            result.uid,
                                            paymentID);
                                    if (accountStat != null) {
                                      print("Success");
                                    }
                                  }
                                } else {
                                  setState(() {
                                    loading = false;
                                    error = "Try one more time.";
                                  });
                                }
                              });
                            }
                          },
                          color: Colors.pink[400],
                          child: Text(
                            "Register",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        SizedBox(
                          height: 12.0,
                        ),
                        Text(
                          error,
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  )),
            ),
          );
  }
}
