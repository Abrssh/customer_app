import 'package:customer_app/Model/user.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  // creates a connection between firebase and this app
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // create user obj based on FirebaseUser
  User _mapFirebaseUserToModelUser(FirebaseUser user) {
    return user != null ? User(uid: user.uid, email: user.email) : null;
  }

  // get authentication data in real time
  // returns a FirebaseUser or null
  Stream<User> get user {
    return _auth.onAuthStateChanged.map(_mapFirebaseUserToModelUser);
  }

  // register with Email and Password
  Future registerWithEmailPassword(String email, String password) async {
    try {
      AuthResult result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      FirebaseUser user = result.user;
      return _mapFirebaseUserToModelUser(user);
      // create a new document for the user with uid
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // sign in with email and password
  Future signInWithEmailPassword(String email, String password) async {
    try {
      AuthResult result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      FirebaseUser user = result.user;
      return _mapFirebaseUserToModelUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //sign out
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
