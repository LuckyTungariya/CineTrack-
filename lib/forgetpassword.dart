import 'package:flutter/material.dart';
import 'package:tmdbmovies/appdesign.dart';
import 'package:tmdbmovies/signuppage.dart';

class ForgetPasswordPage extends StatefulWidget {
  const ForgetPasswordPage({super.key});

  @override
  State<ForgetPasswordPage> createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  TextEditingController email = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.of(context).size.height;
    var w = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
            color: AppDesign().bgColor
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
                        child: Icon(Icons.arrow_back_rounded,color: Colors.white),
                      ),
                    )
                  ],
                ),

                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Forgot Password?",style: TextStyle(color: AppDesign().textColor,fontSize: 26,fontWeight: FontWeight.bold,fontFamily: 'Roboto')),
                    Text("Enter your email and we will\n send a change password link.",style: TextStyle(color: AppDesign().textColor,fontSize: 14,fontStyle: FontStyle.normal,fontFamily: 'Roboto')),

                    SizedBox(
                      height: 30,
                    ),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _returnText("Email*",Colors.white,FontStyle.normal),
                        _returnTextField(email),
                      ],
                    ),


                    Container(
                      margin: EdgeInsets.only(top: 20),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.black54
                      ),
                      width: w,
                      child: ElevatedButton(onPressed: (){},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppDesign().primaryAccent,
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
                                "Send Link",
                                style: TextStyle(color: AppDesign().textColor,fontSize: 20,fontFamily: 'Roboto'),
                              ),
                            ],
                          )),
                    )
                  ],
                ),
              ],
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
