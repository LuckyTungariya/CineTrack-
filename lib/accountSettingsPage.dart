import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:tmdbmovies/Databasemethods.dart';
import 'package:tmdbmovies/appdesign.dart';
import 'package:tmdbmovies/sharedprefs.dart';
import 'package:tmdbmovies/signuppage.dart';

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  bool _isloading = false;
  String? confirmPass;
  GoogleSignInAccount? account;
  final _globalKey = GlobalKey<FormState>();
  final _deleteglobalKey = GlobalKey<FormState>();
  String? userName,email,pass,userId;
  TextEditingController usr = TextEditingController();
  TextEditingController eml = TextEditingController();
  TextEditingController confirm = TextEditingController();

  @override
  void initState() {
    super.initState();
    getUserDetails();
  }

  void getUserDetails() async{
    userId = await SharedPreferenceHelper().getUserId();
    userName = await SharedPreferenceHelper().getUsername();
    email  = await SharedPreferenceHelper().getEmail();
    pass = await SharedPreferenceHelper().getPassword();

    usr.text = userName!.trim();
    eml.text = email!.trim();
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesign().bgColor,
      appBar: AppBar(
        titleSpacing: 35,
        backgroundColor: AppDesign().bgColor,
        title: Text('Account Settings',style: TextStyle(color: AppDesign().textColor,
            fontWeight: FontWeight.bold,fontFamily: 'Roboto',fontSize: 20)),
        iconTheme: IconThemeData(
          color: AppDesign().textColor
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: LoadingOverlay(
          isLoading: _isloading,
          color: Colors.transparent,
          progressIndicator: Center(child: CircularProgressIndicator(color: Colors.white)),
          child: SingleChildScrollView(
            child: Column(
              children: [
                ExpansionTile(title: Text('Personal Information',
                    style: TextStyle(color: AppDesign().textColor,fontFamily: 'Roboto',fontWeight: FontWeight.bold)),
                backgroundColor: Colors.grey.shade800,
                childrenPadding: EdgeInsets.all(10),
                iconColor: Colors.white,
                collapsedIconColor: Colors.white,
                textColor: AppDesign().textColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)
                ),
                children: [
                  Form(
                    key: _globalKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Username',style: TextStyle(color: AppDesign().textColor)),
                        TextFormField(
                          controller: usr,
                          validator: (value){
                            if(value==null || value.isEmpty){
                              return 'Username cannot be blank';
                            }else{
                              return null;
                            }
                          },
                          onSaved: (value) {
                            usr.text = value!;
                          },
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            )
                          ),
                        ),

                        SizedBox(height: 5),

                        (pass!="") ? Text('Email Address',style: TextStyle(color: AppDesign().textColor)) : SizedBox(height: 0),
                        (pass!="") ? TextFormField(
                          controller: eml,
                          validator: (value) {
                            if(!(value!.contains("@"))){
                              return 'Invalid email format';
                            }else{
                              return null;
                            }
                          },
                          onSaved: (value){
                            eml.text = value!;
                          },
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              )
                          ),
                        ) : SizedBox(height: 0),

                        SizedBox(height: 5),

                        Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10)
                          ),
                          child: ElevatedButton(onPressed: () async{
                            if(_globalKey.currentState!.validate()){
                              if((userName == usr.text && email == eml.text)){
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Nothing to update")));
                              }else{
                                var checkUsr = usr.text;
                                var checkEmail = eml.text;

                                setState(() {
                                  _isloading = true;
                                });

                                await DatabaseOptions().updateUserName(userId!, checkUsr);
                                await DatabaseOptions().updateEmail(userId!, checkEmail);

                                await SharedPreferenceHelper().removeUsername();
                                await SharedPreferenceHelper().removePassword();
                                await SharedPreferenceHelper().setUsername(checkUsr);
                                await SharedPreferenceHelper().setEmail(checkEmail);

                                setState(() {
                                  _isloading = false;
                                });

                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Changes saved successfully')));

                              }
                            }
                          },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppDesign().primaryAccent,
                              ),
                              child: Text('Save Changes',style: TextStyle(color: AppDesign().textColor,
                                  fontFamily: 'Roboto',fontWeight: FontWeight.bold,fontSize: 18))),
                        ),
                      ],
                    ),
                  )
                ]),

                SizedBox(
                  height: 20,
                ),

               Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5)
                    ),
                    child: ElevatedButton(onPressed: (){
                      showDialog(context: context, builder: (context) {
                        return AlertDialog(
                          title: Text("Are you sure you want to delete account?",style: TextStyle(color: Colors.red)),
                          content: Text("Once deleted account cannot be restored.",style: TextStyle(color: Colors.white)),
                          elevation: 5,
                          backgroundColor: Colors.grey.shade900,
                          shape: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)
                          ),
                          icon: Icon(Icons.warning),
                          iconColor: Colors.red,
                          actions: [
                            Container(
                              height : 40,
                              decoration : BoxDecoration(
                                  color: AppDesign().primaryAccent,
                                  borderRadius: BorderRadius.circular(10)
                              ),
                              child: TextButton(onPressed: () async{
                                Navigator.pop(context);
                                confirm.clear();

                                (pass!="") ? showDialog(context: context,
                                    builder: (context) {
                                      return SimpleDialog(
                                        elevation: 5,
                                        insetPadding: EdgeInsets.all(5),
                                        title: Center(child: Text("Confirm your identity?",style: TextStyle(color: Colors.red))),
                                        backgroundColor: Colors.grey.shade900,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10)
                                        ),
                                        children: [
                                          Center(child: Text("Re-enter your password to confirm identity",style: TextStyle(color: Colors.red))),
                                          Form(
                                            key : _deleteglobalKey,
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: TextFormField(
                                                controller : confirm,
                                                style: TextStyle(color: Colors.black),
                                                cursorColor : Colors.black,
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(5)
                                                  ),
                                                  focusedBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(5),
                                                    borderSide: BorderSide(
                                                      color: Colors.black
                                                    )
                                                  )
                                                ),
                                                validator: (value) {
                                                  if(pass!=value){
                                                    return 'Please enter your correct password';
                                                  }else{
                                                    confirmPass = value;
                                                    print(confirmPass);
                                                    return null;
                                                  }
                                                },
                                              ),
                                            ),
                                          ),
                                          Container(
                                            height : 40,
                                            decoration : BoxDecoration(
                                                color: AppDesign().primaryAccent,
                                                borderRadius: BorderRadius.circular(10)
                                            ),
                                            child: TextButton(onPressed: () async{
                                              if(_deleteglobalKey.currentState!.validate()){
                                                Navigator.pop(context);

                                                setState(() {
                                                  _isloading = true;
                                                });

                                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("User account deleted successfully")));
                                                Navigator.of(context,rootNavigator: true).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => SignUp()), (route) => false);

                                                setState(() {
                                                  _isloading = false;
                                                });

                                                var result = await DatabaseOptions().deleteUserAccountWithEmail(userId!,confirmPass!);
                                                print('The returned result $result');

                                              }
                                            }, child: Text('OK',style: TextStyle(color : AppDesign().textColor))),
                                          )
                                        ],
                                      );
                                    }) : setState(() {
                                      _isloading = true;
                                    });

                                account = await DatabaseOptions().authenticateUser(context);

                                // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("User chosen account is $account")));
                                // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("User account deleted successfully")));
                                Navigator.of(context,rootNavigator: true).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => SignUp()), (route) => false);

                                setState(() {
                                  _isloading = false;
                                });

                                var result = await DatabaseOptions().deleteUserAccountWithGoogle(context,account!);

                              }, child: Text('Yes',style: TextStyle(color : AppDesign().textColor))),
                            ),
                            Container(
                              height : 40,
                              decoration : BoxDecoration(
                                  color: AppDesign().primaryAccent,
                                  borderRadius: BorderRadius.circular(10)
                              ),
                              child: TextButton(onPressed: (){
                                Navigator.pop(context);
                              }, child: Text('No',style: TextStyle(color : AppDesign().textColor))),
                            )
                          ],
                        );
                      });
                    },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade800,
                        ),
                        child: Text('Delete Account',style: TextStyle(color: Colors.redAccent,
                            fontFamily: 'Roboto',fontWeight: FontWeight.bold,fontSize: 18))),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
