import 'dart:convert';
import 'package:hiremi/CongratulationScreen.dart';
import 'package:hiremi/api_services/base_services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:hiremi/signin.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadUserEmail();
    _loadUserDetail();
  }

  String loginEmail = "";
  String FullName = "";
  String Gender = "";
  String College = "";
  String Branch = "";
  String imagePath = ""; // Declare imagePath with 'late'

  Future<void> _loadUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedUsername = prefs.getString('username');

    if (savedUsername != null && savedUsername.isNotEmpty) {
      setState(() {
        loginEmail = savedUsername;
      });
      print(loginEmail);
    }
  }

  Future<void> _loadUserDetail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedUsername = prefs.getString('username');

    if (savedUsername != null && savedUsername.isNotEmpty) {
      setState(() {
        loginEmail = savedUsername;
      });

      // Replace the API URL with your actual API endpoint
      final apiUrl = '${ApiUrls.baseurl}api/registers/';

      try {
        final response = await http.get(Uri.parse(apiUrl));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);

          if (data is List && data.isNotEmpty) {
            for (final user in data) {
              final email = user['email'];
              final name = user['full_name'];
              final gender = user['gender'];
              final branch = user['branch_name'];
              final college = user['college_name'];
              if (email == loginEmail) {
                setState(() {
                  FullName = name;
                  Gender = gender;
                  Branch = branch;
                  College = college;
                  imagePath = (Gender == 'Male')
                      ? 'images/TheFace.png'
                      : 'images/female.png';
                });
                print("Gender is $Gender");
                print('Full Name: $name');

                //   print(data);
                // You can store or use the name as needed
                break; // Exit the loop once a match is found
              }
            }

            if (FullName.isEmpty) {
              print('Full Name not found for Email: $loginEmail');
            }
          } else {
            print('Email not found on the server.');
          }
        }
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            child: Column(
              children: [
                const SizedBox(
                  height: 10,
                ),

                const SizedBox(
                  height: 40,
                ),
                // Container(
                //   width: MediaQuery.of(context).size.width,
                //   height: MediaQuery.of(context).size.height * 0.10,
                //   child: Center(
                //     child: CircleAvatar(
                //       radius: 46,
                //       backgroundImage: AssetImage(imagePath.isNotEmpty ? imagePath : 'images/TheFace.png' ),
                //     ),
                //   ),
                // ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.10,
                  child: Center(
                    child: CircleAvatar(
                      radius: 46,
                      backgroundImage: (Gender == 'Male')
                          ? const AssetImage('images/TheFace.png')
                          : (Gender == 'Female')
                              ? const AssetImage('images/female.png')
                              : null, // Set to null when gender is neither male nor female
                      child: (Gender != 'Male' && Gender != 'Female')
                          ? const Center(
                              child:
                                  CircularProgressIndicator()) // Show CircularProgressIndicator when gender is neither male nor female
                          : null, // Set to null when gender is male or female
                    ),
                  ),
                ),

                Text(
                  FullName,
                  style: const TextStyle(
                      fontSize: 25, fontWeight: FontWeight.w700),
                ),
                Text(
                  loginEmail,
                  style: const TextStyle(
                    fontFamily: 'FontMain',
                  ),
                ),
                const SizedBox(height: 35),

                ExpansionTile(
                  leading: const Icon(
                    Icons.person_2_outlined,
                    color: Colors.red,
                  ),
                  title: const Text(
                    'Personal Info',
                    style: TextStyle(
                      color: Color(0xFFBD232B),
                      fontSize: 25,
                      fontFamily: 'FontMain',
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 160),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Father's Name",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontFamily: 'FontMain',
                            ),
                          ),

                            //   decoration: const InputDecoration(
                            //     //errorText: errorTextVal.isEmpty ? null : errorTextVal,
                            //     enabledBorder: UnderlineInputBorder(
                            //       borderSide: BorderSide(
                            //         color: Color(0xFFCACACA),
                            //       ),
                            //     ),
                            //     focusedBorder: UnderlineInputBorder(
                            //       borderSide: BorderSide(
                            //         color: Color(0xFFCACACA),
                            //       ),
                            //     ),
                            //     //hintText: 'email@gmail.com',
                            //     hintStyle: TextStyle(
                            //       color:Color(0xFF9B9B9B),
                            //       fontSize: 14.5,
                            //       fontWeight: FontWeight.w500,
                            //     ),
                            //   ),
                            // ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                "Rahul Sharma",
                                style: TextStyle(
                                  color: Color(0xFF9B9B9B),
                                  fontSize: 20,
                                ),
                              ),
                            ),


                          // Text("$FullName",
                          //   textAlign: TextAlign.center,
                          //   style: TextStyle(
                          //   color: Colors.black,
                          //   fontSize: 20,
                          //   fontFamily: 'FontMain',
                          // ),),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text(
                            "Gender",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontFamily: 'FontMain',
                            ),
                          ),

                            // child: TextFormField(
                            //   readOnly: true,
                            //   decoration: const InputDecoration(
                            //     //errorText: errorTextVal.isEmpty ? null : errorTextVal,
                            //     enabledBorder: UnderlineInputBorder(
                            //       borderSide: BorderSide(
                            //         color: Color(0xFFCACACA),
                            //       ),
                            //     ),
                            //     focusedBorder: UnderlineInputBorder(
                            //       borderSide: BorderSide(
                            //         color: Color(0xFFCACACA),
                            //       ),
                            //     ),
                            //     //hintText: 'email@gmail.com',
                            //     hintStyle: TextStyle(
                            //       color: Color(0xFF9B9B9B),
                            //       fontSize: 14.5,
                            //       fontWeight: FontWeight.w500,
                            //     ),
                            //   ),
                            // ),
                              Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                "Male",
                                style: TextStyle(
                                  color: Color(0xFF9B9B9B),
                                  fontSize: 20,
                                ),
                              ),
                            ),

                          const SizedBox(
                            height: 10,
                          ),
                          // Text("$loginEmail",
                          //   textAlign: TextAlign.center,
                          //   style: TextStyle(
                          //     color: Colors.black,
                          //     fontSize: 20,
                          //     fontFamily: 'FontMain',
                          //   ),),
                          const Text(
                            "Date of Birth",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontFamily: 'FontMain',
                            ),
                          ),
                            // child: TextFormField(
                            //   decoration: const InputDecoration(
                            //     //errorText: errorTextVal.isEmpty ? null : errorTextVal,
                            //     enabledBorder: UnderlineInputBorder(
                            //       borderSide: BorderSide(
                            //         color: Color(0xFFCACACA),
                            //       ),
                            //     ),
                            //     focusedBorder: UnderlineInputBorder(
                            //       borderSide: BorderSide(
                            //         color: Color(0xFFCACACA),
                            //       ),
                            //     ),
                            //     //hintText: 'email@gmail.com',
                            //     hintStyle: TextStyle(
                            //       color: Color(0xFF9B9B9B),
                            //       fontSize: 14.5,
                            //       fontWeight: FontWeight.w500,
                            //     ),
                            //   ),
                            // ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                "6th May,2000",
                                style: TextStyle(
                                  color: Color(0xFF9B9B9B),
                                  fontSize: 20,
                                ),
                              ),
                            ),

                          const SizedBox(
                            height: 10,
                          ),
                          // Text("$Branch",
                          //   textAlign: TextAlign.center,
                          //   style: TextStyle(
                          //     color: Colors.black,
                          //     fontSize: 20,
                          //     fontFamily: 'FontMain',
                          //   ),),
                          const Text(
                            "Contact Number",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontFamily: 'FontMain',
                            ),
                          ),
                            // child: TextFormField(
                            //   decoration: const InputDecoration(
                            //     //errorText: errorTextVal.isEmpty ? null : errorTextVal,
                            //     enabledBorder: UnderlineInputBorder(
                            //       borderSide: BorderSide(
                            //         color: Color(0xFFCACACA),
                            //       ),
                            //     ),
                            //     focusedBorder: UnderlineInputBorder(
                            //       borderSide: BorderSide(
                            //         color: Color(0xFFCACACA),
                            //       ),
                            //     ),
                            //     hintText: '8102262****',
                            //     hintStyle: TextStyle(
                            //       color: Color(0xFF9B9B9B),
                            //       fontSize: 18,
                            //       fontWeight: FontWeight.w500,
                            //     ),
                            //   ),
                            // ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                "9898153789",
                                style: TextStyle(
                                  color: Color(0xFF9B9B9B),
                                  fontSize: 20,
                                ),
                              ),
                            ),

                          const SizedBox(
                            height: 10,
                          ),
                          // Text("$College",
                          //   textAlign: TextAlign.center,
                          //   style: TextStyle(
                          //     color:  Colors.black,
                          //     fontSize: 20,
                          //     fontFamily: 'FontMain',
                          //   ),),
                          const Text(
                            "College",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontFamily: 'FontMain',
                            ),
                          ),

                            // child: TextFormField(
                            //   decoration: const InputDecoration(
                            //     //errorText: errorTextVal.isEmpty ? null : errorTextVal,
                            //     enabledBorder: UnderlineInputBorder(
                            //       borderSide: BorderSide(
                            //         color: Color(0xFFCACACA),
                            //       ),
                            //     ),
                            //     focusedBorder: UnderlineInputBorder(
                            //       borderSide: BorderSide(
                            //         color: Color(0xFFCACACA),
                            //       ),
                            //     ),
                            //     hintText: 'TIT College',
                            //     hintStyle: TextStyle(
                            //       color: Color(0xFF9B9B9B),
                            //       fontSize: 18,
                            //       fontWeight: FontWeight.w500,
                            //     ),
                            //   ),
                            // ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                "ITI College",
                                style: TextStyle(
                                  color: Color(0xFF9B9B9B),
                                  fontSize: 20,
                                ),

                            ),
                          ),
                          // Text("$Gender",
                          //   textAlign: TextAlign.center,
                          //   style: TextStyle(
                          //     color:  Colors.black,
                          //     fontSize: 20,
                          //     fontFamily: 'FontMain',
                          //   ),),
                          // if (_isExpanded)
                          //   Icon(
                          //     Icons.keyboard_arrow_down_outlined,
                          //     color: Colors.black,
                          //   )
                          // else
                          //   Icon(
                          //     Icons.access_time,
                          //     color: Colors.black,
                          //   ),
                        ],
                      ),
                    ),
                  ],
                  //trailing:Icon(Icons.arrow_forward_ios),
                ),

                const SizedBox(height: 30),
                ListTile(
                  leading: const Icon(
                    Icons.security,
                    color: Colors.red,
                  ),
                  title: const Text('Security',
                      style: TextStyle(
                        color: Color(0xFFBD232B),
                        fontSize: 25,
                        fontFamily: 'FontMain',
                      )),
                  trailing: const Icon(Icons.keyboard_arrow_right_outlined),
                  onTap: () {
                    // Handle onTap
                  },
                ),

                const SizedBox(height: 30),
                ListTile(
                  leading: const Icon(
                    Icons.info_outline,
                    color: Colors.red,
                  ),
                  title: const Text(
                    'Privacy Policy',
                    style: TextStyle(
                      color: Color(0xFFBD232B),
                      fontSize: 25,
                      fontFamily: 'FontMain',
                    ),
                  ),
                  trailing: const Icon(Icons.keyboard_arrow_right_outlined),
                  onTap: () {
                    // Handle onTap
                  },
                ),

                const SizedBox(height: 30),
                // InkWell(
                //
                //   onTap: ()async{
                //     var sharedPref=await SharedPreferences.getInstance();
                //     sharedPref.setBool(CongratulationScreenState.KEYLOGIN, false);
                //     Navigator.pushReplacement(
                //       context,
                //       MaterialPageRoute(
                //         builder: (context) =>  SignIn(),
                //       ),
                //     );
                //   },
                //   child: ListTile(
                //
                //     title: Text('Sign out',style: TextStyle(color: Color(0xFFBD232B),fontSize: 25, fontFamily: 'FontMain',),),
                //
                //     trailing: Icon(Icons.arrow_forward),
                //
                //   ),
                // )
                InkWell(
                  onTap: () async {
                    // Handle onTap
                    var sharedPref = await SharedPreferences.getInstance();
                    sharedPref.setBool(
                        CongratulationScreenState.KEYLOGIN, false);
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const SignIn()),
                      (Route<dynamic> route) =>
                          false, // This line removes all routes from the stack
                    );
                  },
                  child: const ListTile(
                    leading: Icon(
                      Icons.exit_to_app_outlined,
                      color: Colors.red,
                    ),
                    title: Text(
                      'Sign out',
                      style: TextStyle(
                        color: Color(0xFFBD232B),
                        fontSize: 25,
                        fontFamily: 'FontMain',
                      ),
                    ),
                    //trailing: Icon(Icons.keyboard_arrow_right_outlined),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
