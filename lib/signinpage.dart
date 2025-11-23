import 'package:flutter/material.dart';
import 'package:overlay_loader_with_app_icon/overlay_loader_with_app_icon.dart';
import 'package:tmdbmovies/Databasemethods.dart';
import 'package:tmdbmovies/appdesign.dart';
import 'package:tmdbmovies/forgetpassword.dart';
import 'package:tmdbmovies/maintohandlebottomnav.dart';
import 'package:tmdbmovies/sharedprefs.dart';
import 'package:tmdbmovies/signuppage.dart';

class SignIn extends StatefulWidget {
  SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  bool _isloading = false;
  final _globalkey = GlobalKey<FormState>();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.of(context).size.height;
    var w = MediaQuery.of(context).size.width;

    return OverlayLoaderWithAppIcon(
      appIcon: Icon(Icons.add_chart_sharp,color: Colors.black),
      isLoading: _isloading,
      overlayOpacity: 0.5,
      overlayBackgroundColor: Colors.black,
      appIconSize: 30,
      circularProgressColor: Colors.black,
      borderRadius: 8,
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
                    Text("Welcome Back!",style: TextStyle(color: AppDesign().textColor,fontSize: 26,fontWeight: FontWeight.bold,fontFamily: 'Roboto')),
                    Text("Sign in to access trending shows \n  movies,Tv Serials and Cinemas.",style: TextStyle(color: AppDesign().textColor,fontSize: 14,fontStyle: FontStyle.normal,fontFamily: 'Roboto')),

                    SizedBox(
                      height: 30,
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
                            validator: (value){
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
                              hintText: 'Enter registered email',
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
                            if(value!.length<8){
                              return 'Password should be minimum of 8 digit';
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

                    GestureDetector(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ForgetPasswordPage()));
                      },
                      child: Container(
                        alignment: Alignment.centerRight,
                        child: Text("Forgot Password?",style: TextStyle(color: AppDesign().textColor,fontSize: 18,fontFamily: 'Roboto',decoration: TextDecoration.underline,decorationColor: Colors.white)),
                      ),
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

                          var emailValue = email.text;
                          var passValue = password.text;
                          var result = await DatabaseOptions().checkUser(emailValue, passValue);

                          if(result == 0){
                            var id = await DatabaseOptions().fetchUserId(email.text);
                            var userDetails = await DatabaseOptions().fetchUserDetails(id!);
                            var fetchedId = userDetails['id'];
                            var fetchedUsr = userDetails['username'];
                            var fetchedEml = userDetails['email'];
                            var fetchedPss = userDetails['password'];
                            var fetchedUserProfile = userDetails['profilePath'] ?? "";
                            print('Id is $fetchedId');
                            print('Username is $fetchedUsr');
                            print('Email is $fetchedEml');
                            print('Password is $fetchedPss');
                            print('User profile is $fetchedUserProfile');
                            await SharedPreferenceHelper().setUserId(fetchedId);
                            await SharedPreferenceHelper().setUsername(fetchedUsr);
                            await SharedPreferenceHelper().setEmail(fetchedEml);
                            await SharedPreferenceHelper().setPassword(fetchedPss);
                            await SharedPreferenceHelper().setUserProfile(fetchedUserProfile);
                            var test = await SharedPreferenceHelper().getUsername();
                            print('Username after login $test');

                            setState(() {
                              _isloading = false;
                            });

                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User Login successful')));
                            Navigator.pushAndRemoveUntil(context,
                                MaterialPageRoute(builder: (context) => MainContainerScreen()),
                                    (route) => false);

                          }else if(result == 1){
                            setState(() {
                              _isloading = false;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid email provided')));
                          }else if(result == 2){
                            setState(() {
                              _isloading = false;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User not found please login')));
                          }else if(result == 3){
                            setState(() {
                              _isloading = false;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid password provided')));
                          }else{
                            setState(() {
                              _isloading = false;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Some unknown exception')));
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
                                "Sign In",
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
                      Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => SignUp()));
                    }, child: Text("Don't have an account? Sign Up",
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

Widget _returnTextField(TextEditingController controller){
  return TextFormField(
    controller: controller,
    decoration: InputDecoration(
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
  );
}
