import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmdbmovies/Apiservice.dart';
import 'package:tmdbmovies/Databasemethods.dart';
import 'package:tmdbmovies/accountSettingsPage.dart';
import 'package:tmdbmovies/appdesign.dart';
import 'package:tmdbmovies/sharedprefs.dart';
import 'package:tmdbmovies/signinpage.dart';
import 'package:tmdbmovies/watchlist.dart';
import 'package:image_picker/image_picker.dart';
import 'homepage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final defaultImageUrl = 'https://upload.wikimedia.org/wikipedia/commons/9/99/Sample_User_Icon.png';
  String? name,email,userId,cid,profileUrl;
  final publicGateway = 'https://gateway.pinata.cloud/ipfs/';
  bool _isloading = false;
  final ImagePicker _picker = ImagePicker();
  XFile? photo;

  @override
  void initState(){
    super.initState();
    getUserProfile();
  }

  void getUserProfile() async{
    userId = await SharedPreferenceHelper().getUserId();
    name = await SharedPreferenceHelper().getUsername();
    email = await SharedPreferenceHelper().getEmail();
    profileUrl = await SharedPreferenceHelper().getUserProfile();
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesign().bgColor,
      appBar: AppBar(
        backgroundColor: AppDesign().bgColor,
        title: Center(child: Text('Profile',style: TextStyle(color: AppDesign().textColor))),
        iconTheme: IconThemeData(
          color: AppDesign().textColor
        ),
      ),
      body: userId==null ? Center(child: CircularProgressIndicator()) : Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children : [
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                ),

                  CircleAvatar(
                    radius: 60,
                    backgroundColor: AppDesign().textColor,
                    child: _isloading ? Center(child: CircularProgressIndicator(color: Colors.black)) : (profileUrl!.isNotEmpty) ? ClipOval(
                      child: SizedBox(height: 120,width: 120,
                          child: Image.network('$publicGateway$profileUrl',fit: BoxFit.fill)),
                    ) : Image.network(defaultImageUrl,fit: BoxFit.cover),
                  ),

              Positioned(
                  top : 60,
                  left: 200,
                  child: IconButton(onPressed: () async{
                    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
                    if(pickedFile!=null){
                      showDialog(context: context,
                          builder: (context) {
                            return AlertDialog(
                              backgroundColor: AppDesign().textColor,
                              elevation: 5,
                              title: Text('Confirm Photo?',style: TextStyle(color: Colors.black)),
                              content: Text('Note : Image processing can take minutes keep patience',style: TextStyle(color: Colors.red)),
                              alignment: Alignment.center,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5)
                              ),
                              icon: Icon(Icons.question_mark_outlined,color: Colors.black),
                              iconColor: Colors.black,
                              actions: [
                                TextButton(onPressed: () async{
                                  photo = pickedFile;
                                  setState(() {});

                                  Navigator.pop(context);

                                  setState(() {
                                    _isloading = true;
                                  });

                                  cid = await ApiService().uploadImage(photo!.path);
                                  print('cid $cid');
                                  setState(() {});


                                  if(cid!=null){
                                    await FirebaseFirestore.instance.collection('users')
                                          .doc(userId)
                                          .update({
                                      'profilePath' : cid
                                    });
                                    await SharedPreferenceHelper().setUserProfile(cid!);
                                    profileUrl = await SharedPreferenceHelper().getUserProfile();
                                    setState(() {});

                                    print('photo uploaded');
                                  }

                                  setState(() {
                                    _isloading = false;
                                  });

                                }, child: Text('Yes')),
                                TextButton(onPressed: (){
                                  Navigator.pop(context);
                                }, child: Text('No')),
                              ],
                            );
                          });
                    }
                  }, icon: CircleAvatar(backgroundColor: AppDesign().primaryAccent,child: Icon(Icons.edit,color: Colors.white)))),
            ]),

          SizedBox(height: 20),
          Text(name!,style: TextStyle(color: AppDesign().textColor,
              fontWeight: FontWeight.bold,fontFamily: 'Roboto',fontSize: 20)),

          SizedBox(height: 20),
          Text(email!,style: TextStyle(color: AppDesign().secondaryTextColor,
              fontWeight: FontWeight.bold,fontFamily: 'Roboto')),

          SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(10)
              ),
              child: ListTile(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AccountSettingsPage()));
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)
                ),
                leading: Icon(Icons.settings,color: AppDesign().textColor),
                title: Text('Account Settings',style: TextStyle(color: AppDesign().textColor,fontFamily: 'Roboto',fontSize: 18)),
                trailing: Icon(Icons.arrow_forward_ios_outlined,color: AppDesign().textColor,)
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(10)
              ),
              child: ListTile(
                  onTap: (){

                  },
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)
                  ),
                  leading: Icon(Icons.share,color: AppDesign().textColor),
                  title: Text('Share App',style: TextStyle(color: AppDesign().textColor,fontFamily: 'Roboto',fontSize: 18)),
                  trailing: Icon(Icons.arrow_forward_ios_outlined,color: AppDesign().textColor,)
              ),
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: ElevatedButton(onPressed: () async{
                    showDialog(context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Are you sure you want to logout?',style: TextStyle(color: Colors.black)),
                            icon: Icon(Icons.warning,color: Colors.black),
                            elevation: 5,
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)
                            ),
                            actions: [
                              TextButton(onPressed: () async{
                                setState(() {
                                  _isloading = true;
                                });

                                final prefs = await SharedPreferences.getInstance();
                                var usr = await SharedPreferenceHelper().getUsername();
                                print("Before Removal $usr");
                                prefs.clear();
                                var usr1 = await SharedPreferenceHelper().getUsername();
                                print("After Removal $usr1");
                                await FirebaseAuth.instance.signOut();

                                setState(() {
                                  _isloading = false;
                                });

                                Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) => SignIn()),(route) => false);
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User Logged out from session')));
                              }, child: Text('Yes')),

                              TextButton(onPressed: (){
                                Navigator.pop(context);
                              }, child: Text('No'))
                            ],
                          );
                        });
                  },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppDesign().primaryAccent,
                      ),
                      child: Row(
                        spacing: 5,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.logout,color: AppDesign().textColor,size: 20),
                          Text('Logout',style: TextStyle(color: AppDesign().textColor,
                              fontFamily: 'Roboto',fontWeight: FontWeight.bold,fontSize: 20))
                        ],
                      )),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
