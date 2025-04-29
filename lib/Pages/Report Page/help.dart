import 'package:flutter/material.dart';

class Help extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Card(
                margin: EdgeInsets.all(8),
                color: Colors.grey[50],
                elevation: 10,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Register",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Before we start I will like to show you how to register into our system which is the first step of a lot of apps out there. When you first open the app you will be greeted by the sign in page with the register button up there in the top right corner. Then you have to click on register button which will take you to the register page in which you will fill in your information then hit register button to be registered into the system.",
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w300,
                            wordSpacing: 10),
                      )
                    ],
                  ),
                ),
              ),
              Card(
                margin: EdgeInsets.all(8),
                color: Colors.grey[50],
                elevation: 10,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Sign IN",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "As I have mentioned above the first page of our app is the sign in page which if you already have an account you can go in and sign in to the system. Once you have signed in our system will store a refresh token which will be used to let the user enter into the system without writing the email and password every time they get into the app. This will be disabled if the account gets deleted, modified or the user sign out of the app. ",
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w300,
                            wordSpacing: 10),
                      )
                    ],
                  ),
                ),
              ),
              Card(
                margin: EdgeInsets.all(8),
                color: Colors.grey[50],
                elevation: 10,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Pay for Ticket",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Once you have signed in you will be shown the ticket page which will be used to pay for tickets. On the top of the app you will see your balance with the drawer button and the sign out button on your left and right respectively. Then below it you will find a card that will be used to pay for tickets. You will choose your boarding and destination location, adjust the number of passenger you want to use this ticket for and press the pay button to pay for the ticket. If there is a problem the app will notify you accordingly. But before you do any payment you should deposit some money into the system. To deposit money into the system you go the porter and tell him your payment id which you will find in your drawer above your email address. Then you tell the porter your id, give them the amount of money you deposit and then they will update your balance which you will see in real time in your ticket page.",
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w300,
                            wordSpacing: 10),
                      )
                    ],
                  ),
                ),
              ),
              Card(
                margin: EdgeInsets.all(8),
                color: Colors.grey[50],
                elevation: 10,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Map",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "In the ticket page you will find a bottom navigation bar at the bottom of the app containing two buttons one which is highlighted is the ticket page your currently in and the other one is the map page button which has a train sign in it. If you click that button it will take you to the map page which you will see the position of the train relative to you as it gets closer to your location. System will detect your location and identify the nearest train that is coming to your position or choose the train station you want.",
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w300,
                            wordSpacing: 10),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
