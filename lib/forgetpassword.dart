import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:tmdbmovies/appdesign.dart';

class ForgetPasswordPage extends StatefulWidget {
  const ForgetPasswordPage({super.key});

  @override
  State<ForgetPasswordPage> createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  bool _isloading = false;
  final _globalkey = GlobalKey<FormState>();
  TextEditingController email = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.of(context).size.height;
    var w = MediaQuery.of(context).size.width;

    return Scaffold(
      body: LoadingOverlay(
        isLoading: _isloading,
        color: Colors.transparent,
        progressIndicator: Center(child: CircularProgressIndicator(color: Colors.white)),
        child: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
              image: DecorationImage(image: AssetImage("assets/usedIcons/appbg.jpg"),
                  fit: BoxFit.cover
                  ,opacity: 0.4)
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 50,left: 12,bottom: 12,right: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: (){
                          Navigator.pop(context);
                        },
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: Icon(Icons.arrow_back_rounded,color: Colors.black),
                        ),
                      )
                    ],
                  ),

                  Form(
                    key: _globalkey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Forgot Password?",style: TextStyle(color: AppDesign().bgColor,fontSize: 26,fontWeight: FontWeight.bold,fontFamily: 'Roboto')),
                        Text("Enter your email and we will\n send a change password link.",style: TextStyle(color: AppDesign().bgColor,fontSize: 14,fontWeight: FontWeight.bold,fontFamily: 'Roboto')),

                        SizedBox(
                          height: 30,
                        ),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _returnText("Email*",Colors.black),
                            _returnTextField(email),
                          ],
                        ),


                        Container(
                          margin: EdgeInsets.only(top: 20),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.transparent
                          ),
                          width: w,
                          child: ElevatedButton(onPressed: () async{
                            if(_globalkey.currentState!.validate()){
                              setState(() {
                                _isloading = true;
                              });

                              await FirebaseAuth.instance.sendPasswordResetEmail(email: email.text);

                              setState(() {
                                _isloading = false;
                              });

                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Check spam folder for reset link")));
                            }

                          },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppDesign().primaryAccent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                spacing: 10,
                                children: [
                                  Image.asset("assets/usedIcons/pencil.png",color: Colors.black,height: 20,width: 20),
                                  Text(
                                    "Send Link",
                                    style: TextStyle(color: AppDesign().bgColor,fontSize: 20,fontFamily: 'Roboto'),
                                  ),
                                ],
                              )),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _returnText(String text,Color color){
  return Text(text,style: TextStyle(color: color,fontFamily: 'Roboto',fontWeight: FontWeight.bold));
}

Widget _returnTextField(TextEditingController controller){
  return TextFormField(
    controller: controller,
    decoration: InputDecoration(
      hintText: 'Enter the registered email',
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
                color : Colors.black
            )
        ),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.black,
            )
        ),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
                color : Colors.black
            )
        )
    ),
    validator: (value) {
      if((value!.contains("@"))){
        return 'InValid email provided';
      }else if(value.isEmpty){
        return 'Please enter the email';
      }else{
        return null;
      }
    },
  );
}
