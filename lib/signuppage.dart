import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';
import 'package:tmdbmovies/Databasemethods.dart';
import 'package:tmdbmovies/appdesign.dart';
import 'package:tmdbmovies/signinpage.dart';
import 'package:overlay_loader_with_app_icon/overlay_loader_with_app_icon.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  late String id;
  bool _isloading = false;
  final _globalkey = GlobalKey<FormState>();
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.of(context).size.height;
    var w = MediaQuery.of(context).size.width;

    return OverlayLoaderWithAppIcon(
      borderRadius: 8,
      appIcon: Icon(Icons.add_chart_sharp,color: Colors.black),
      circularProgressColor: Colors.black,
      appIconSize: 30,
      overlayBackgroundColor: Colors.black,
      overlayOpacity: 0.5,
      isLoading: _isloading,
      child: Scaffold(
        body: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppDesign().bgColor
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 150,left: 12,bottom: 12,right: 12),
              child: Form(
                key: _globalkey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Create Your Account?",style: TextStyle(color: AppDesign().textColor,fontSize: 26,fontWeight: FontWeight.bold,fontFamily: 'Roboto')),
                    Text("Create your account to explore exciting \n       movies,Tv Serials and Cinemas.",style: TextStyle(color: AppDesign().textColor,fontSize: 16,fontStyle: FontStyle.normal,fontFamily: 'Roboto')),

                    SizedBox(
                      height: 30,
                    ),

                     Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _returnText("Full Name*",Colors.white,FontStyle.normal),
                          TextFormField(
                            controller: name,
                            style: TextStyle(color: Colors.white),
                            validator: (value) {
                              if(value==null || value==''){
                                return 'Please provide your name';
                              }else{
                                return null;
                              }
                            },
                            onSaved: (newValue) {
                              name.text = newValue!;
                            },
                            decoration: InputDecoration(
                                hintText: 'Enter your name',
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                        color : Colors.white
                                    )
                                ),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: Colors.white,
                                    )
                                ),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                        color : Colors.black
                                    )
                                )
                            ),
                          )
                        ],
                      ),

                    SizedBox(
                      height: 4.5,
                    ),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _returnText("Email*",Colors.white,FontStyle.normal),
                        TextFormField(
                          controller: email,
                          style: TextStyle(color: Colors.white),
                          validator: (value) {
                            if(!(value!.contains('@'))){
                              return 'Invalid email format';
                            }else{
                              return null;
                            }
                          },
                          onSaved: (newValue) {
                            email.text = newValue!;
                          },
                          decoration: InputDecoration(
                            hintText: 'Enter your email',
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                      color : Colors.white
                                  )
                              ),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.white,
                                  )
                              ),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                      color : Colors.black
                                  )
                              )
                          ),
                        )
                      ],
                    ),

                    SizedBox(
                      height: 4.5,
                    ),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _returnText("Password*",Colors.white,FontStyle.normal),
                        TextFormField(
                          controller: password,
                          style: TextStyle(color: Colors.white),
                          validator: (value) {
                            if(value!.length<8 || value.isEmpty){
                              return 'Password should be of minimum eight digit';
                            }else{
                              return null;
                            }
                          },
                          onSaved: (newValue) {
                            password.text = newValue!;
                          },
                          decoration: InputDecoration(
                            hintText: 'Enter your password',
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                      color : Colors.white
                                  )
                              ),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.white,
                                  )
                              ),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                      color : Colors.black
                                  )
                              )
                          ),
                        )
                      ],
                    ),

                    SizedBox(
                      height: 4.5,
                    ),

                    Container(
                      margin: EdgeInsets.only(top: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: AppDesign().primaryAccent
                      ),
                      width: w,
                      child: ElevatedButton(onPressed: () async{
                        if(_globalkey.currentState!.validate()){
                          setState(() {
                            _isloading = true;
                          });

                          var nameValue = name.text;
                          var emailValue = email.text;
                          var passValue = password.text;
                          var result = await DatabaseOptions().createUser(emailValue, passValue);
                          if(result == 0){
                            id = '$nameValue${randomAlphaNumeric(5)}';
                            await DatabaseOptions().addUserDetails(id, nameValue, emailValue, passValue);
                          }

                          setState(() {
                            _isloading = false;
                          });

                          if(result == 0){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => SignIn()));
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User registration successful please login')));
                          }else if(result == 1){
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid email format')));
                          }else if(result == 2){
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Email already in use please login')));
                          }else if(result == 3){
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Password is too weak')));
                          }else{
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Unknown network exception caught')));
                          }
                        }
                      },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 10,
                            children: [
                              Image.asset("assets/usedIcons/pencil.png",color: Colors.white,height: 20,width: 20),
                              Text(
                                "Sign Up",
                                style: TextStyle(color: AppDesign().textColor,fontSize: 20,fontFamily: 'Roboto'),
                              ),
                            ],
                          )),
                    ),

                    SizedBox(
                      height: 20,
                    ),

                    Divider(
                      color: Colors.white,
                    ),

                    TextButton(onPressed: (){

                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignIn()));
                    }, child: Text("Already have an account?Sign In",
                        style: TextStyle(color: AppDesign().primaryAccent,fontSize: 18,fontFamily: 'Roboto')))
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _returnText(String text,Color color,FontStyle fontStyle){
  return Text(text,style: TextStyle(color: color,fontFamily: 'Roboto'));
}
