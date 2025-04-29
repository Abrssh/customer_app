import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_app/Model/ticket.dart';
import 'package:customer_app/Model/train.dart';
import 'package:customer_app/Model/transaction.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

class DatabaseService {
  final CollectionReference trainCollection =
      Firestore.instance.collection("Train");
  final CollectionReference tripCollection =
      Firestore.instance.collection("Trip");
  final CollectionReference ticketCollection =
      Firestore.instance.collection("Ticket");
  final CollectionReference customerCollection =
      Firestore.instance.collection("customerUser");
  final CollectionReference systemAccountCollection =
      Firestore.instance.collection("systemAccount");
  final CollectionReference transCollection =
      Firestore.instance.collection("transaction");

  final bool assignedDirection;
  final bool tripDirection;

  final String customerUserID;
  final String trainID;

  final String systemAccountID = "frGconRYwTO3gr3LAPs6";

  DatabaseService(
      {this.assignedDirection,
      this.tripDirection,
      this.customerUserID,
      this.trainID});

  // get trip of your desired path
  // and is the closest or the one that is
  // going to arrive earilier than other trips
  // (trip includes a train we are talking about train location)
  // TO-DO get Locations of trip

  // TO DOS
  // get ticket data from server, map to model and use in the UI
  // add notify functionality to the app
  // automatically determine your location and gives appropriate location
  // make sure the trip assigned to you is of the train which is the closest
  // to your locatio
  // add map functionality
  // add functionality of your drawer to your app

  // customers money in the system assigned
  // to their account
  Stream get balance {
    return customerCollection
        .document(customerUserID)
        .snapshots()
        .map((event) => event.data["balance"]);
  }

  DateFormat dateFormat = DateFormat("yMd");
  List<Ticket> _mapFromTicketSnapShot(QuerySnapshot snapshot) {
    return snapshot.documents.map((doc) {
      // get the date and time in proper format
      Timestamp timestamp = doc.data["timestamp"];
      DateTime dateTime = timestamp.toDate();
      String date = dateFormat.format(dateTime);
      bool status = doc.data["status"];
      int stat;
      String numberOfPassenger = doc.data["numberOfPassenger"].toString();
      if (status == true) {
        stat = 0;
      } else {
        stat = 1;
      }
      return Ticket(
          ticketID: doc.documentID,
          notifyNumber: doc.data["notifyNumber"],
          status: stat,
          boardingLocation: doc.data["boardingLocation"],
          destination: doc.data["destination"],
          numberOfPassenger: numberOfPassenger,
          notified: doc.data["notified"],
          date: date);
    }).toList();
  }

  DateFormat dateFormatTrans = DateFormat("Md");
  List<TransactionModel> _mapFromTransactionSnapshot(QuerySnapshot snapshot) {
    return snapshot.documents.map((e) {
      String type = "";
      if (e.data["sender"] == customerUserID) {
        type = "Deposit";
      } else {
        type = "Withdraw";
      }
      int amount = e.data["amount"];
      // get the date and time in proper format
      Timestamp timestamp = e.data["time"];
      DateTime dateTime = timestamp.toDate();
      String date = dateFormatTrans.format(dateTime);
      return TransactionModel(type, amount, date);
    }).toList();
  }

  Train _mapDocumentSnapshotToTrain(DocumentSnapshot documentSnapshot) {
    return Train(
        currentPassenger: documentSnapshot.data["currentPassenger"],
        capacity: documentSnapshot.data["capacity"]);
  }

  Stream<Train> get train {
    return trainCollection
        .document(trainID)
        .snapshots()
        .map(_mapDocumentSnapshotToTrain);
  }

  // get tickets of this customer
  Stream<List<Ticket>> get tickets {
    return ticketCollection
        .where("customerID", isEqualTo: customerUserID)
        .orderBy("timestamp", descending: false)
        .snapshots()
        .map(_mapFromTicketSnapShot);
  }

  Stream<List<TransactionModel>> get transactions {
    return transCollection
        .where("type", isEqualTo: false)
        .orderBy("time", descending: true)
        .limit(20)
        .snapshots()
        .map(_mapFromTransactionSnapshot);
  }

  // stream used to get location data of the nearest train
  // identify nearest train must be done
  Stream<GeoPoint> trainLocation(String nearestTrainID) {
    return trainCollection
        .document(nearestTrainID)
        .snapshots()
        .map((event) => event.data["location"]);
  }

  Future<String> getNearestTrainID(GeoPoint currentLocation) async {
    return await trainCollection.getDocuments().then((value) {
      double minDistance = 0;
      int minIndex = 0, index = 0;
      value.documents.forEach((element) {
        GeoPoint trainLocation = element.data["location"];
        double distance = Geolocator.distanceBetween(
            currentLocation.latitude,
            currentLocation.longitude,
            trainLocation.latitude,
            trainLocation.longitude);

        if (distance < minDistance || index == 0) {
          minDistance = distance;
          minIndex = index;
        }
        index++;
      });
      return value.documents[minIndex].documentID;
    });
  }

  // by using transaction this function make sure
  // all the read and write happens or it rolls back
  // every action done in this function
  Future<bool> atomicPay(
      String tripID,
      String boardingLocation,
      String destination,
      String customerID,
      int price,
      String notifyNumber,
      int numberOfPassenger) async {
    try {
      bool updated;
      Map<String, dynamic> a =
          await Firestore.instance.runTransaction((transaction) async {
        var balance, systemBalance;
        await transaction
            .get(customerCollection.document(customerID))
            .then((docRef) {
          // doc ref is actually document snapshot
          if (docRef != null) print("Doc does exist");
          balance = docRef.data["balance"];
        });
        await transaction
            .get(systemAccountCollection.document(systemAccountID))
            .then((docRef) {
          systemBalance = docRef.data["systemBalance"];
        });

        // although if/else is allowed in transaction
        // but not writing a read is not allowed so make
        // thats why there is some write in the else condition
        // even though it has no use
        if (balance >= price) {
          balance = balance - price;
          systemBalance = systemBalance + price;
          await transaction.update(
              customerCollection.document(customerID), {"balance": balance});
          await transaction.update(
              systemAccountCollection.document(systemAccountID),
              {"systemBalance": systemBalance});
          //create ticket document
          await transaction.set(ticketCollection.document(), {
            "tripID": tripID,
            "boardingLocation": boardingLocation,
            "destination": destination,
            "customerID": customerID,
            "price": price,
            "status": true,
            "notified": false,
            "notifyNumber": notifyNumber,
            "numberOfPassenger": numberOfPassenger,
            "timestamp": Timestamp.now()
          });
          // creates transaction document
          await transaction.set(transCollection.document(), {
            "sender": customerID,
            "reciever": systemAccountID,
            // true means internal false means external
            "type": true,
            "amount": price,
            "time": Timestamp.now()
          });
          return {"val": true};
        } else {
          await transaction.update(
              customerCollection.document(customerID), {"balance": balance});
          await transaction.update(
              systemAccountCollection.document(systemAccountID),
              {"systemBalance": systemBalance});
          return {"val": false};
        }
      });
      updated = a["val"];
      print("ae : " + a.toString());
      return updated;
    } catch (e) {
      print("Transaction Error : " + e.toString());
    }
  }

  Future<QuerySnapshot> getTripID() {
    return tripCollection
        .where("assignedDirection", isEqualTo: assignedDirection)
        .where("tripDirection", isEqualTo: tripDirection)
        .where("status", isEqualTo: true)
        .limit(1)
        .getDocuments();
  }

  // used to make sure notify number is unique when assigned
  Future<bool> checkNotifyNumber(String a, String tripID) async {
    // when you return a value in asynchronus method
    // make sure the procees that await(wait) for an
    // action to finish has a return statement as well
    // await only will return the value early
    return await ticketCollection
        .where("notifyNumber", isEqualTo: a)
        .where("tripID", isEqualTo: tripID)
        .getDocuments()
        .then((value) {
      bool valid;
      if (value.documents.length > 0) {
        valid = false;
      } else {
        valid = true;
      }
      return valid;
    });
  }

  // used to make sure PaymentID number is unique when assigned
  Future<bool> checkPaymentID(String a) async {
    // when you return a value in asynchronus method
    // make sure the procees that await(wait) for an
    // action to finish has a return statement as well
    // await only will return the value early
    return await customerCollection
        .where("paymentID", isEqualTo: a)
        .getDocuments()
        .then((value) {
      bool valid;
      if (value.documents.length > 0) {
        valid = false;
      } else {
        valid = true;
      }
      return valid;
    });
  }

  // deleteTickets() {
  //   var batch = Firestore.instance.batch();
  //   var docRef = ticketCollection.where("notified", isEqualTo: false);
  //   docRef.getDocuments().then((value) {
  //     for (var docRef in value.documents) {
  //       batch.delete(docRef.reference);
  //     }
  //     return batch.commit();
  //   });
  // }

  // should not allow customer to notify if the status of the ticket is false
  // by using the status of the ticket you should disable the notify button
  Future notifyTicket(String ticketID) {
    return ticketCollection
        .document(ticketID)
        .updateData({"timestamp": Timestamp.now(), "notified": true});
  }

  // create customer account
  Future createCustomerAccount(
      String firstName,
      String lastName,
      int sex,
      String phoneNumber,
      String neighborhood,
      int balance,
      String uid,
      String paymentID) {
    var docRef = customerCollection.document(uid);
    return docRef.setData({
      "firstName": firstName,
      "lastName": lastName,
      "sex": sex,
      "phoneNumber": phoneNumber,
      "neighborhood": neighborhood,
      "balance": balance,
      "paymentID": paymentID
    });
  }

  Future<DocumentSnapshot> getCustomerDoc() {
    return customerCollection.document(customerUserID).get();
  }
}
