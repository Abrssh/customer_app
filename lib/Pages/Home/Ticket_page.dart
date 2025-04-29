import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_app/Model/ticket.dart';
import 'package:customer_app/Model/user.dart';
import 'package:customer_app/Services/Database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:random_string/random_string.dart';

class TicketPage extends StatefulWidget {
  @override
  _TicketPageState createState() => _TicketPageState();
}

class _TicketPageState extends State<TicketPage> {
  final List<String> _places = {
    "Menelik2",
    "Atkilt Tera",
    "Gojam Berenda",
    "Autobus Tera",
    "Sebetegna",
    "Abnet",
    "Darmar",
    "Meshalquia",
    "Riche",
    "Temenja yaze",
    "Lancha",
    "Nifas Silk 1",
    "Nifas Silk 2",
    "Adey Abeba",
    "Saris",
    "Abo Junction",
    "Kalty"
  }.toList();

  final List<String> _places2 = {
    "Tor Hailoch",
    "Coca-Cola",
    "St.Lideta",
    "Tegbareled",
    "Mexico",
    "Leghar",
    "Stadium",
    "St.Estifanoas",
    "Bambis",
    "St.Urael",
    "Haya huluet 2",
    "Haya huluet 1",
    "Lem Hotel",
    "Megenagna",
    "Gurd Shola 2",
    "Gurd Shola 1",
    "Mgmt Institute",
    "CSU",
    "St.Michael",
    "CMC",
    "Meri",
    "Ayat"
  }.toList();

  String _selectedPlace1, _selectedPlace2;

  List<DropdownMenuItem<String>> _dropDownItem;

  // used for UI
  TextEditingController _passengerTextEditing = TextEditingController();
  String price = "4";
  DateFormat _dateFormat = DateFormat("yMd");
  String currentDate;
  String tripIDforTrainIncoming = "123456";
  // icon and data for status in ticket UIS
  List<IconData> iconArr = {Icons.check, Icons.clear}.toList();
  int iconIndex = 0;
  List<MaterialColor> colorArr = {Colors.green, Colors.red}.toList();
  bool notifyAllowed = true;

  // used for server
  bool currentDirectionOfCustomers = false;
  // true means west-east and false north-south
  // should be identified by looking at the current
  // location of the customer
  String fullLengthTripID = "";
  int ticketNumberOfPassenger = 1;
  int finalPrice = 4;

  bool tripDirection = true;
  // true for W/E means W-E false means E-W
  // true for N/S means N-S false means S-N

  List<DropdownMenuItem<String>> buildDropDownItem(List places) {
    List<DropdownMenuItem<String>> items = [];
    for (var place in places) {
      items.add(DropdownMenuItem(
        value: place,
        child: Text(
          place,
          style: TextStyle(fontSize: 13),
        ),
      ));
    }
    return items;
  }

  QuerySnapshot querySnapshot;

  @override
  void initState() {
    _passengerTextEditing.text = "1";
    super.initState();
  }

  // used to identify which direction
  // the customer is going on this path
  bool customerTripDirecIdentifier(bool currentDirectionofCustomer) {
    int index1 = 0, index2 = 0;
    if (currentDirectionofCustomer) {
      for (var i = 0; i < _places.length; i++) {
        if (_places[i] == _selectedPlace1) {
          index1 = i;
        }
        if (_places[i] == _selectedPlace2) {
          index2 = i;
        }
      }
    } else {
      for (var i = 0; i < _places2.length; i++) {
        if (_places2[i] == _selectedPlace1) {
          index1 = i;
        }
        if (_places2[i] == _selectedPlace2) {
          index2 = i;
        }
      }
    }
    if (index1 < index2) {
      return true;
    } else {
      return false;
    }
  }

  onDropdownChange(String selectedPlace) {
    setState(() {
      _selectedPlace1 = selectedPlace;
      tripDirection = customerTripDirecIdentifier(currentDirectionOfCustomers);
    });
  }

  onDropdownChange2(String selectedPlace) {
    setState(() {
      _selectedPlace2 = selectedPlace;
      tripDirection = customerTripDirecIdentifier(currentDirectionOfCustomers);
    });
  }

  // used to make sure line of code gets executed once only
  // even though its in a build method which is called constanatly
  bool runOnce = true;
  // --
  var userID;
  Stream ticketsStream;
  // get lists of ticket from a stream in real time
  List<Ticket> tickets;
  // points to a particular ticket from the list
  int ticketIndex;
  // max is determined by the number of tickets in the list
  int maxIndex = 0, minIndex = 0;
  // to make sure tickets is populated by data from server
  bool dataServed = false;
  // used to control progress bar in pay button
  bool progressBarController = false;
  @override
  Widget build(BuildContext context) {
    DateTime dateTime = DateTime.now();
    currentDate = _dateFormat.format(dateTime);

    if (runOnce == true) {
      if (currentDirectionOfCustomers == true) {
        _dropDownItem = buildDropDownItem(_places);
      } else {
        _dropDownItem = buildDropDownItem(_places2);
      }
      userID = Provider.of<User>(context).uid;
      ticketsStream = DatabaseService(customerUserID: userID).tickets;
      ticketsStream.listen((value) {
        tickets = value;
        // to avoid setting - index to maxIndex
        // which will cause an error
        if (tickets.length > 0) {
          maxIndex = tickets.length - 1;
          setState(() {
            ticketIndex = maxIndex;
          });
        }
        if (dataServed == false) {
          setState(() {
            if (tickets.length > 0) {
              dataServed = true;
              int notifyTemp = tickets[ticketIndex].status;
              if (notifyTemp == 0) {
                notifyAllowed = true;
              } else {
                notifyAllowed = false;
              }
              print("notifyAllow : " + notifyAllowed.toString());
            }
          });
        }

        if (tickets.length > 0) {
          int notifyTemp = tickets[ticketIndex].status;
          setState(() {
            if (notifyTemp == 0) {
              notifyAllowed = true;
            } else {
              notifyAllowed = false;
            }
          });
        }
      });
      runOnce = false;
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Card(
              elevation: 10,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Payment Form",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Container(
                      width: 310,
                      height: 40,
                      child: Row(
                        children: [
                          Text(
                            "From:",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          DropdownButton(
                            items: _dropDownItem,
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                            onChanged: onDropdownChange,
                            value: _selectedPlace1,
                          ),
                          Text(
                            "To:",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          DropdownButton(
                            items: _dropDownItem,
                            onChanged: onDropdownChange2,
                            value: _selectedPlace2,
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      width: 310,
                      height: 100,
                      child: Row(
                        children: [
                          Flexible(
                            flex: 2,
                            fit: FlexFit.tight,
                            child: TextFormField(
                              readOnly: true,
                              style: TextStyle(
                                fontSize: 30,
                              ),
                              controller: _passengerTextEditing,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                  hintText: "Passengers",
                                  hintStyle: TextStyle(
                                    fontSize: 20,
                                  )),
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            fit: FlexFit.tight,
                            child: Column(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.arrow_upward),
                                  onPressed: () {
                                    int temp =
                                        int.parse(_passengerTextEditing.text);
                                    temp++;
                                    ticketNumberOfPassenger = temp;
                                    int tempPrice = temp * 4;
                                    setState(() {
                                      price = tempPrice.toString();
                                      finalPrice = tempPrice;
                                    });
                                    _passengerTextEditing.text =
                                        temp.toString();
                                  },
                                  iconSize: 20,
                                ),
                                IconButton(
                                  icon: Icon(Icons.arrow_downward),
                                  onPressed: () {
                                    int temp =
                                        int.parse(_passengerTextEditing.text);
                                    if (temp > 1) {
                                      temp--;
                                      ticketNumberOfPassenger = temp;
                                      int tempPrice = temp * 4;
                                      setState(() {
                                        price = tempPrice.toString();
                                        finalPrice = tempPrice;
                                      });
                                    }
                                    _passengerTextEditing.text =
                                        temp.toString();
                                  },
                                  iconSize: 20,
                                )
                              ],
                            ),
                          ),
                          Flexible(
                            flex: 4,
                            fit: FlexFit.tight,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  "Trip Id:",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w400),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  tripIDforTrainIncoming,
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w300),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                "Date: ",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              Text(
                                currentDate,
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w300),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                "Price: ",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              Text(
                                price,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              SizedBox(
                                width: 5.0,
                              ),
                              Text(
                                "Birr",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w300,
                                  color: Colors.brown,
                                ),
                              )
                            ],
                          ),
                        ]),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        progressBarController
                            ? Container(
                                child: CircularProgressIndicator(),
                                width: 30,
                                height: 30,
                              )
                            : Container(
                                width: 315,
                                height: 30,
                                child: RaisedButton(
                                  child: Text(
                                    "Pay",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.white,
                                    ),
                                  ),
                                  color: Colors.green,
                                  onPressed: () {
                                    setState(() {
                                      progressBarController = true;
                                    });
                                    if (_selectedPlace1 == _selectedPlace2) {
                                      setState(() {
                                        progressBarController = false;
                                      });
                                      Scaffold.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              "You can't have the Same Destination"),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    } else {
                                      if (_selectedPlace1 != "" &&
                                          _selectedPlace2 != "") {
                                        DatabaseService(
                                                assignedDirection:
                                                    currentDirectionOfCustomers,
                                                tripDirection: tripDirection)
                                            .getTripID()
                                            .then((value) {
                                          print("val : " +
                                              value.documents.length
                                                  .toString());
                                          if (value != null) {
                                            if (value.documents.length > 0) {
                                              print("Somaa");
                                              () {
                                                setState(() {
                                                  fullLengthTripID = value
                                                      .documentChanges[0]
                                                      .document
                                                      .documentID;
                                                  tripIDforTrainIncoming =
                                                      fullLengthTripID
                                                          .substring(
                                                              fullLengthTripID
                                                                      .length -
                                                                  6);
                                                });
                                                String notifyNumber;
                                                // TODO make sure no collison happens
                                                // between tickets
                                                notifyNumber = randomNumeric(6);
                                                bool checkForPay;
                                                DatabaseService()
                                                    .atomicPay(
                                                        fullLengthTripID,
                                                        _selectedPlace1,
                                                        _selectedPlace2,
                                                        userID,
                                                        finalPrice,
                                                        notifyNumber,
                                                        ticketNumberOfPassenger)
                                                    .then((value) {
                                                  // has to be in the then function because
                                                  // data will take time to reach to the client
                                                  checkForPay = value;
                                                  if (checkForPay == false) {
                                                    setState(() {
                                                      progressBarController =
                                                          false;
                                                    });
                                                    Scaffold.of(context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        backgroundColor:
                                                            Colors.red,
                                                        content: Text(
                                                          "Don't have enough balance in your account",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                        duration: Duration(
                                                            seconds: 2),
                                                      ),
                                                    );
                                                  } else {
                                                    setState(() {
                                                      progressBarController =
                                                          false;
                                                    });
                                                    Scaffold.of(context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        backgroundColor:
                                                            Colors.green,
                                                        content: Text(
                                                          "Payed Successfully",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                        duration: Duration(
                                                            seconds: 2),
                                                      ),
                                                    );
                                                  }
                                                });
                                              }();
                                            } else {
                                              setState(() {
                                                progressBarController = false;
                                              });
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content:
                                                      Text("No trip incoming"),
                                                  duration:
                                                      Duration(seconds: 2),
                                                ),
                                              );
                                            }
                                          } else {
                                            setState(() {
                                              progressBarController = false;
                                            });
                                            Scaffold.of(context).showSnackBar(
                                              SnackBar(
                                                content:
                                                    Text("No trip incoming"),
                                                duration: Duration(seconds: 2),
                                              ),
                                            );
                                          }
                                        });
                                      }
                                    }
                                  },
                                ),
                              ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Card(
              elevation: 10,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Ticket",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 25),
                    child: Row(
                      children: [
                        Text(
                          "Notify Number: ",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          dataServed
                              ? tickets[ticketIndex].notifyNumber
                              : "123456",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 25),
                    child: Row(
                      children: [
                        Row(
                          children: [
                            Text(
                              "From : ",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Text(
                              dataServed
                                  ? tickets[ticketIndex].boardingLocation
                                  : "Lancha",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Row(
                          children: [
                            Text(
                              "To : ",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Text(
                              dataServed
                                  ? tickets[ticketIndex].destination
                                  : "Megneagna",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 25),
                    child: Row(
                      children: [
                        Text(
                          "Number of  passenger : ",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          dataServed
                              ? tickets[ticketIndex].numberOfPassenger
                              : "2",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w300,
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 25),
                    child: Row(
                      children: [
                        Row(
                          children: [
                            Text(
                              "Date: ",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Text(
                              dataServed
                                  ? tickets[ticketIndex].date
                                  : "8/25/2020",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 25,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              "Active: ",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(
                              dataServed
                                  ? iconArr[tickets[ticketIndex].status]
                                  : iconArr[iconIndex],
                              color: colorArr[dataServed
                                  ? tickets[ticketIndex].status
                                  : iconIndex],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                        height: 60,
                        child: Row(
                          children: [
                            Flexible(
                              flex: 3,
                              fit: FlexFit.tight,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  height: 40,
                                  child: RaisedButton(
                                    onPressed: () {
                                      if (ticketIndex != null) {
                                        if (ticketIndex > minIndex) {
                                          setState(() {
                                            ticketIndex--;
                                            if (tickets[ticketIndex].status ==
                                                0) {
                                              notifyAllowed = true;
                                            } else {
                                              notifyAllowed = false;
                                            }
                                          });
                                          print("tick Index : " +
                                              ticketIndex.toString());
                                        }
                                      }
                                    },
                                    color: Colors.green,
                                    child: Icon(
                                      Icons.arrow_back,
                                      size: 30,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Flexible(
                              flex: 4,
                              fit: FlexFit.tight,
                              child: Container(
                                height: 40,
                                child: RaisedButton(
                                  onPressed: dataServed
                                      ? notifyAllowed &&
                                              !tickets[ticketIndex].notified
                                          ? () {
                                              // DatabaseService().deleteTickets();
                                              DatabaseService().notifyTicket(
                                                  tickets[ticketIndex]
                                                      .ticketID);
                                            }
                                          : null
                                      : null,
                                  color: Colors.green,
                                  child: Text(
                                    "NOTIFY",
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                            Flexible(
                              flex: 3,
                              fit: FlexFit.tight,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  height: 40,
                                  child: RaisedButton(
                                    onPressed: () {
                                      if (ticketIndex != null) {
                                        if (ticketIndex < maxIndex) {
                                          setState(() {
                                            ticketIndex++;
                                            if (tickets[ticketIndex].status ==
                                                0) {
                                              notifyAllowed = true;
                                            } else {
                                              notifyAllowed = false;
                                            }
                                          });
                                          print("tick Index : " +
                                              ticketIndex.toString());
                                        }
                                      }
                                    },
                                    color: Colors.green,
                                    child: Icon(
                                      Icons.arrow_forward,
                                      size: 30,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
