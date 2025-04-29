import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_app/Services/Database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GeoPoint currentLocation = GeoPoint(9.0372602, 38.7831733);
  double distanceBetween = 0;
  var trainProgressValue = 0.1;
  int geoPointIndex = 0;

  List<String> location = {
    "Leghar",
    "Meskel Station",
    "Stadium",
    "Lideta",
    "Coca Mazoria",
    "Tor hailoch",
    "Urael",
    "Lem Hotel"
  }.toList();

  int currentNumberOfPassenger = 0, capacity = 0;

  final List<GeoPoint> _geoPoint = {
    GeoPoint(9.011912546468837, 38.75322796117599),
    GeoPoint(9.011017768510584, 38.76326521015842),
    GeoPoint(9.012017321442185, 38.757612402459976),
    GeoPoint(9.011286169512301, 38.7360903575664),
    GeoPoint(9.012070303399922, 38.729191715940345),
    GeoPoint(9.011434519305645, 38.7227758720262),
    GeoPoint(9.010353346394817, 38.7688021935986),
    GeoPoint(9.01489919174827, 38.7832432070444),
  }.toList();

  updateRealTimeLocation(GeoPoint geoPoint) {
    DatabaseService().getNearestTrainID(geoPoint).then((value) {
      DatabaseService().trainLocation(value).listen((event) {
        double distanceBetween1 = Geolocator.distanceBetween(geoPoint.latitude,
            geoPoint.longitude, event.latitude, event.longitude);
        if (distanceBetween1 <= 4200) {
          double relativeDist = distanceBetween1 * 0.00023809;
          setState(() {
            trainProgressValue = 1 - relativeDist;
          });
        } else {
          setState(() {
            trainProgressValue = 0.05;
          });
        }
        // print("Distance Betweend : " + distanceBetween1.toString());
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    DatabaseService().getNearestTrainID(currentLocation).then((value) {
      DatabaseService(trainID: value).train.listen((event) {
        setState(() {
          currentNumberOfPassenger = event.currentPassenger;
          capacity = event.capacity;
        });
        // print("Passengwer : " + currentNumberOfPassenger.toString());
      });
      DatabaseService().trainLocation(value).listen((event) {
        distanceBetween = Geolocator.distanceBetween(currentLocation.latitude,
            currentLocation.longitude, event.latitude, event.longitude);
        if (distanceBetween <= 4200) {
          double relativeDist = distanceBetween * 0.00023809;
          setState(() {
            trainProgressValue = 1 - relativeDist;
          });
        } else {
          setState(() {
            trainProgressValue = 0.05;
          });
        }
        // print("Distance Betweend : " + distanceBetween.toString());
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final device = MediaQuery.of(context).size;
    var deviceHeight = device.height * 0.77;
    var deviceWidth = device.width;
    var mapContainerHeight = deviceHeight * 0.5;

    return Container(
      height: deviceHeight,
      width: deviceWidth,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 6.0, right: 6.0),
            child: Container(
              height: mapContainerHeight,
              child: Column(
                children: [
                  Container(
                    // color: Colors.blueGrey,
                    height: mapContainerHeight * 0.2,
                    width: deviceWidth,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Passenger :",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            SizedBox(
                              width: 4,
                            ),
                            Text(
                              currentNumberOfPassenger.toString(),
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(
                              width: 3,
                            ),
                            Text(
                              "/" + capacity.toString(),
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: deviceWidth,
                    height: mapContainerHeight * 0.75,
                    // color: Colors.blueGrey[200],
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Train Location",
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.w300,
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: mapContainerHeight * 0.02,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              "4km",
                              style: TextStyle(fontSize: 18),
                            ),
                            Text(
                              "3km",
                              style: TextStyle(fontSize: 18),
                            ),
                            Text(
                              "2km",
                              style: TextStyle(fontSize: 18),
                            ),
                            Text(
                              "1.5km",
                              style: TextStyle(fontSize: 18),
                            ),
                            Text(
                              "0.5km",
                              style: TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          height: mapContainerHeight * 0.1,
                          child: LinearProgressIndicator(
                            value: trainProgressValue,
                            backgroundColor: Colors.red[300],
                          ),
                        ),
                        SizedBox(
                          height: mapContainerHeight * 0.12,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "Location :",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Text(
                                  location[geoPointIndex],
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  "Arrived: ",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Icon(
                                  Icons.timelapse,
                                  color: Colors.red,
                                ),
                              ],
                            ),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          Container(
            height: deviceHeight - mapContainerHeight,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30.0),
                topRight: Radius.circular(30.0),
              ),
            ),
            child: Column(
              children: [
                SizedBox(
                  height: mapContainerHeight * 0.08,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Choose Your Desired Station",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w300,
                      ),
                    )
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Card(
                          elevation: mapContainerHeight * 0.5,
                          child: RaisedButton(
                            color: Colors.grey[50],
                            child: Container(
                              height: mapContainerHeight * 0.68,
                              width: deviceWidth * 0.4,
                              child: Column(
                                children: [
                                  Image.asset(
                                    "assets/trainS.jpeg",
                                    height: mapContainerHeight * 0.4,
                                    width: deviceWidth * 0.4,
                                    fit: BoxFit.fill,
                                  ),
                                  SizedBox(
                                    height: mapContainerHeight * 0.03,
                                  ),
                                  Text(
                                    "Location",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                  SizedBox(
                                    height: mapContainerHeight * 0.015,
                                  ),
                                  Text(
                                    "Leghar",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            onPressed: () {
                              geoPointIndex = 0;
                              updateRealTimeLocation(_geoPoint[geoPointIndex]);
                            },
                          ),
                        ),
                        Card(
                          elevation: mapContainerHeight * 0.5,
                          child: RaisedButton(
                            color: Colors.grey[50],
                            child: Container(
                              height: mapContainerHeight * 0.68,
                              width: deviceWidth * 0.4,
                              child: Column(
                                children: [
                                  Image.asset(
                                    "assets/trainS.jpeg",
                                    height: mapContainerHeight * 0.4,
                                    width: deviceWidth * 0.4,
                                    fit: BoxFit.fill,
                                  ),
                                  SizedBox(
                                    height: mapContainerHeight * 0.03,
                                  ),
                                  Text(
                                    "Location",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                  SizedBox(
                                    height: mapContainerHeight * 0.015,
                                  ),
                                  Text(
                                    "Meskel Station",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            onPressed: () {
                              geoPointIndex = 1;
                              updateRealTimeLocation(_geoPoint[geoPointIndex]);
                            },
                          ),
                        ),
                        Card(
                          elevation: mapContainerHeight * 0.5,
                          child: RaisedButton(
                            color: Colors.grey[50],
                            child: Container(
                              height: mapContainerHeight * 0.68,
                              width: deviceWidth * 0.4,
                              child: Column(
                                children: [
                                  Image.asset(
                                    "assets/trainS.jpeg",
                                    height: mapContainerHeight * 0.4,
                                    width: deviceWidth * 0.4,
                                    fit: BoxFit.fill,
                                  ),
                                  SizedBox(
                                    height: mapContainerHeight * 0.03,
                                  ),
                                  Text(
                                    "Location",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                  SizedBox(
                                    height: mapContainerHeight * 0.015,
                                  ),
                                  Text(
                                    "Stadium",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            onPressed: () {
                              geoPointIndex = 2;
                              updateRealTimeLocation(_geoPoint[geoPointIndex]);
                            },
                          ),
                        ),
                        Card(
                          elevation: mapContainerHeight * 0.5,
                          child: RaisedButton(
                            color: Colors.grey[50],
                            child: Container(
                              height: mapContainerHeight * 0.68,
                              width: deviceWidth * 0.4,
                              child: Column(
                                children: [
                                  Image.asset(
                                    "assets/trainS.jpeg",
                                    height: mapContainerHeight * 0.4,
                                    width: deviceWidth * 0.4,
                                    fit: BoxFit.fill,
                                  ),
                                  SizedBox(
                                    height: mapContainerHeight * 0.03,
                                  ),
                                  Text(
                                    "Location",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                  SizedBox(
                                    height: mapContainerHeight * 0.015,
                                  ),
                                  Text(
                                    "Lideta",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            onPressed: () {
                              geoPointIndex = 3;
                              updateRealTimeLocation(_geoPoint[geoPointIndex]);
                            },
                          ),
                        ),
                        Card(
                          elevation: mapContainerHeight * 0.5,
                          child: RaisedButton(
                            color: Colors.grey[50],
                            child: Container(
                              height: mapContainerHeight * 0.68,
                              width: deviceWidth * 0.4,
                              child: Column(
                                children: [
                                  Image.asset(
                                    "assets/trainS.jpeg",
                                    height: mapContainerHeight * 0.4,
                                    width: deviceWidth * 0.4,
                                    fit: BoxFit.fill,
                                  ),
                                  SizedBox(
                                    height: mapContainerHeight * 0.03,
                                  ),
                                  Text(
                                    "Location",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                  SizedBox(
                                    height: mapContainerHeight * 0.015,
                                  ),
                                  Text(
                                    "Coca Mazoria",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            onPressed: () {
                              geoPointIndex = 4;
                              updateRealTimeLocation(_geoPoint[geoPointIndex]);
                            },
                          ),
                        ),
                        Card(
                          elevation: mapContainerHeight * 0.5,
                          child: RaisedButton(
                            color: Colors.grey[50],
                            child: Container(
                              height: mapContainerHeight * 0.68,
                              width: deviceWidth * 0.4,
                              child: Column(
                                children: [
                                  Image.asset(
                                    "assets/trainS.jpeg",
                                    height: mapContainerHeight * 0.4,
                                    width: deviceWidth * 0.4,
                                    fit: BoxFit.fill,
                                  ),
                                  SizedBox(
                                    height: mapContainerHeight * 0.03,
                                  ),
                                  Text(
                                    "Location",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                  SizedBox(
                                    height: mapContainerHeight * 0.015,
                                  ),
                                  Text(
                                    "Tor Hailoch",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            onPressed: () {
                              geoPointIndex = 5;
                              updateRealTimeLocation(_geoPoint[geoPointIndex]);
                            },
                          ),
                        ),
                        Card(
                          elevation: mapContainerHeight * 0.5,
                          child: RaisedButton(
                            color: Colors.grey[50],
                            child: Container(
                              height: mapContainerHeight * 0.68,
                              width: deviceWidth * 0.4,
                              child: Column(
                                children: [
                                  Image.asset(
                                    "assets/trainS.jpeg",
                                    height: mapContainerHeight * 0.4,
                                    width: deviceWidth * 0.4,
                                    fit: BoxFit.fill,
                                  ),
                                  SizedBox(
                                    height: mapContainerHeight * 0.03,
                                  ),
                                  Text(
                                    "Location",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                  SizedBox(
                                    height: mapContainerHeight * 0.015,
                                  ),
                                  Text(
                                    "Urael",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            onPressed: () {
                              geoPointIndex = 6;
                              updateRealTimeLocation(_geoPoint[geoPointIndex]);
                            },
                          ),
                        ),
                        Card(
                          elevation: mapContainerHeight * 0.5,
                          child: RaisedButton(
                            color: Colors.grey[50],
                            child: Container(
                              height: mapContainerHeight * 0.68,
                              width: deviceWidth * 0.4,
                              child: Column(
                                children: [
                                  Image.asset(
                                    "assets/trainS.jpeg",
                                    height: mapContainerHeight * 0.4,
                                    width: deviceWidth * 0.4,
                                    fit: BoxFit.fill,
                                  ),
                                  SizedBox(
                                    height: mapContainerHeight * 0.03,
                                  ),
                                  Text(
                                    "Location",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                  SizedBox(
                                    height: mapContainerHeight * 0.015,
                                  ),
                                  Text(
                                    "Lem Hotel",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            onPressed: () {
                              geoPointIndex = 7;
                              updateRealTimeLocation(_geoPoint[geoPointIndex]);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
