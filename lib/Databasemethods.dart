import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';

class DatabaseOptions{
  Future<int> createUser(String email,String password) async{
    try{
      UserCredential user = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      print(user.credential);
      return 0;
    }on FirebaseAuthException catch (e){
      if(e.code == 'invalid-email'){
        return 1;
      }else if(e.code == 'email-already-in-use'){
        return 2;
      }else if(e.code == 'weak-password'){
        return 3;
      }else{
        return 4;
      }
    }
  }

  Future<int> checkUser(String email,String password) async{
    try{
      UserCredential user = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      print(user.credential);
      return 0;
    }on FirebaseAuthException catch (e){
      if(e.code == 'invalid-email'){
        return 1;
      }else if(e.code == 'user-not-found'){
        return 2;
      }else if(e.code == 'wrong-password'){
        return 3;
      }else if(e.code == 'invalid-credential'){
        return 3;
      }
      else{
        return 4;
      }
    }
  }

  Future<void> addUserDetails(String id,String usr,String email,String pss) async{
    await FirebaseFirestore.instance.collection('users').doc(id).set(
      {
        'id' : id,
        'username' : usr,
        'email' : email,
        'password' : pss,
        'profilePath' : null,
        'watchlist' : []
      }
    );
  }

  Future<String?> fetchUserId(String email) async{
    var snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email',isEqualTo: email)
        .get();

    if(snapshot.docs.isNotEmpty){
      return snapshot.docs.first.id;
    }else{
      return null;
    }

  }

  Future<DocumentSnapshot<Map<String,dynamic>>> fetchUserDetails(String id) async{
    final data = await FirebaseFirestore.instance.collection('users').doc(id).get();
    return data;
  }

  Future<void> addToWatchlist(String userId,String mediaId,String mediaNm,String media,String imgPath) async{
    final snapshot = await FirebaseFirestore.instance.collection('users')
                           .doc(userId)
                           .get();
    print('The data is ${snapshot.data()}');
    List currentWatchlist = snapshot.data()?['watchlist'] ?? [];
    currentWatchlist.add({
      'mediaId' : mediaId,
      'mediaNm' : mediaNm,
      'mediaType' : media,
      'imgPath' : imgPath
    });

    print(currentWatchlist);

    await FirebaseFirestore.instance.collection('users')
          .doc(userId)
          .update({
      'watchlist' : currentWatchlist
    });
  }

  Future<void> removeFromWatchlist(String userId,String mediaId,String media) async{
    final snapshot = await FirebaseFirestore.instance.collection('users')
        .doc(userId)
        .get();
    print('The data is ${snapshot.data()}');
    List currentWatchlist = snapshot.data()?['watchlist'] ?? [];
    currentWatchlist.removeWhere((element) => element['mediaId'] == mediaId && element['mediaType'] == media);
    print(currentWatchlist);

    await FirebaseFirestore.instance.collection('users')
        .doc(userId)
        .update({
      'watchlist' : currentWatchlist
    });
  }

  Future<List<dynamic>> searchMedia(List result,String query) async {
    if(result.isEmpty){
      return [];
    }

      List filtered = [];
      for (var item in result) {
        if (item['mediaNm'].toString().toLowerCase().contains(query.toLowerCase())){
          filtered.add(item);
        }
      }
      return filtered;
  }

  Future<void> updateUserName(String id,String name) async{
    await FirebaseFirestore.instance.collection('users')
          .doc(id)
          .update({
      "username" : name
    });
  }

  Future<void> updateEmail(String id,String email) async{
    await FirebaseFirestore.instance.collection('users')
        .doc(id)
        .update({
      "email" : email
    });
  }

  Future<void> updatePassword(String id,String password) async{
    await FirebaseFirestore.instance.collection('users')
        .doc(id)
        .update({
      "password" : password
    });
  }

  Future<int> deleteUserAccount(String id,String password) async{
    try{
      User? user = await FirebaseAuth.instance.currentUser;

      AuthCredential credential = EmailAuthProvider.credential(
          email: user!.email!,
          password: password);

      await user.reauthenticateWithCredential(credential);
      print('The user id is ${user.uid}');

      await FirebaseFirestore.instance.collection('users')
            .doc(id)
            .delete();

      await user.delete();
      return 1;

    }catch (e){
      print('Someting went wrong deleting user account');
      return 2;
    }
  }

}