import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hiremi/HomePage.dart';
import 'package:hiremi/api_services/base_services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';

class Mentorship extends StatefulWidget {
  const Mentorship({super.key});

  @override
  State<Mentorship> createState() => _MentorshipState();
}

class _MentorshipState extends State<Mentorship> {
  @override
  void initState() {
    super.initState();
    AlreadyApplied();
    _loadUserEmail();
    checkInternetConnection();
  }

  String loginEmail = "";
  int Uid = 0;
  bool _isConnected = false;
  // or whatever default value you want to assign
  bool hasAlreadyApplied = false;
  Future<void> _loadUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedUsername = prefs.getString('username');

    if (savedUsername != null && savedUsername.isNotEmpty) {
      setState(() {
        loginEmail = savedUsername;
      });
    }
  }
  Future<void> checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        _isConnected = false;
      });
    } else {
      setState(() {
        _isConnected = true;
      });
    }
  }

  Future<void> AlreadyApplied() async {
    try {
      final response =
          await http.get(Uri.parse('${ApiUrls.baseurl}api/mentorship/'));

      if (response.statusCode == 200) {
        final List<dynamic> dataList = json.decode(response.body);

        for (int index = 0; index < dataList.length; index++) {
          final Map<String, dynamic> data = dataList[index];

          final String userEmail = data['email'];

          if (userEmail == loginEmail) {
            setState(() {
              print("User has already applied. Email: $loginEmail");
              hasAlreadyApplied = true;
            });
            break;
          }
        }
      } else {
        print('Status code: ${response.statusCode}');
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print("Error in alreadyApplied: $e");
    }
  }

  Future<void> loadUserUid() async {
    await _loadUserEmail();

    try {
      final response =
          await http.get(Uri.parse('${ApiUrls.baseurl}verified-emails/'));

      if (response.statusCode == 200) {
        final List<dynamic> dataList = json.decode(response.body);

        // Counter for verified records

        for (int index = 0; index < dataList.length; index++) {
          final Map<String, dynamic> data = dataList[index];

          final String userEmail = data['email'];
          final int UID = data['id'];

          if (userEmail == loginEmail) {
            print(userEmail);
            print(UID);
            // await postVerifiedEmail();
            // await VerificationID2();
            Uid = UID;
            print(Uid);
            await applyNow();

            // Increment the counter for the next verified record
          }
        }
      } else {
        print('Status code: ${response.statusCode}');
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error in fetchData in UID: $e');
    }
  }

  Future<void> applyNow() async {
    final apiUrl = '${ApiUrls.baseurl}api/mentorship/';

    try {
      // Make a PATCH request to update the "Applied" field
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'applied': true,
          'email': loginEmail,
          'uid': Uid,
          "candidate_status": "Pending",
        }),
      );

      if (response.statusCode == 201) {
        await ShowDialog();
        print('Applied successfully!');
        print('ApplyNow Response Code: ${response.statusCode}');
        print('ApplyNow Response Body: ${response.body}');
        // Add any additional logic or UI changes here
      } else {
        // Failed to update the "Applied" field
        print('Failed to apply: ${response.statusCode}');
        print("${response.body}");
        // Add error handling or show an error message
      }
    } catch (e) {
      // Handle exceptions
      print('Exception while applying: $e');
      if (e is http.ClientException) {
        // Print the response body if available
        print('Response body: ${e.message}');
      }
      // Add error handling or show an error message
    }
  }

  Future<void> ShowDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Stack(
          children: [
            // Blurred background
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("your_background_image_path"),
                  fit: BoxFit.cover,
                ),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(
                  color:
                      Colors.black.withOpacity(0.5), // Adjust opacity as needed
                ),
              ),
            ),
            // Your dialog
            AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              content: WillPopScope(
                onWillPop: () async {
                  // Handle back button press here
                  // Returning true allows the dialog to be popped
                  // Returning false prevents the dialog from being popped
                  return true;
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Thank you for applying to the Hiremi Mentorship Program. Check your email for interview details and further instructions. Best of luck on your journey to career excellence with Hiremi!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: "FontMain",
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Thank you for applying to Hiremi", // Your leading text
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: "FontMain",
                          fontSize: 20,
                          color: Color(0xFFBD232B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showConformationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Stack(
          children: [
            // Blurred background
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: Colors.black
                    .withOpacity(0.5), // Adjust the opacity as needed
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
              ),
            ),
            // AlertDialog on top of the blurred background
            WillPopScope(
              onWillPop: () async {
                // Handle back button press here
                // Returning true allows the dialog to be popped
                // Returning false prevents the dialog from being popped
                return true;
              },
              child: AlertDialog(
                backgroundColor: Colors.white,
                surfaceTintColor: Colors
                    .transparent, // Set the background color to transparent
                actions: [
                  Column(
                    children: [
                      const SizedBox(
                        height: 30,
                      ),
                      const Center(
                        child: Text(
                          "Ready to begin your mentorship journey", // Your leading text
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: "FontMain",
                            fontSize: 20,
                            color: Color(0xFFBD232B),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              await loadUserUid();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF13640),
                              minimumSize: const Size(50, 5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              "Yes",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 22,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              minimumSize: const Size(50, 5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              "No",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFFF13640),
                                fontWeight: FontWeight.w700,
                                fontSize: 22,
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  )
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  List<String> imagePaths = [
    'images/certificate.png', // Adjust the image paths as needed
    'images/certificate.png',
    'images/certificate.png',
  ];
  String getTextForIndex(int index) {
    if (index == 0) {
      return 'Only for college \nstudents!';
    } else if (index == 1) {
      return 'Become Job Ready';
    } else if (index == 2) {
      return 'Industry-Recognised \nInternship-Certificate';
    } else {
      return ''; // Default value or handle additional indices if needed
    }
  }

  String getAnotherTextForIndex(int index) {
    if (index == 0) {
      return 'All Candidate will be Provided with\na course completition & internship\ncertificate upon Succesfull\ncompletition of the mentorship.';
    } else if (index == 1) {
      return 'Build an attractive resume/profile\n along with soft skills,training and\nmock interview.';
    } else if (index == 2) {
      return 'Post membership completion,\ncandidates will be given course\ncompletion and internship\ncertificates.';
    } else {
      return ''; // Default value or handle additional indices if needed
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    print("Width is $screenWidth");
    print("Height is $screenHeight");
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  Align(
                      alignment: Alignment.topLeft,
                      child: InkWell(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return const HomePage(
                                    sourceScreen: '',
                                    uid: '',
                                    username: '',
                                    verificationId: '',
                                  );
                                },
                              ),
                            );
                          },
                          child: Image.asset('images/Back_Button.png'))),
                  SizedBox(
                    height: screenHeight * 0.02,
                  ),
                  Text(
                    "Why Hiremi Mentorship?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'FontMain',
                      fontSize: screenWidth < 411 ? 22 : 25,
                    ),
                  ),
                  SizedBox(
                    height: screenHeight * 0.027,
                  ),
                  //sliding starts
                  SizedBox(
                    height: screenHeight * 0.19,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: List.generate(
                        3,
                        (index) => Padding(
                          padding: const EdgeInsets.only(left: 28.0),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15.0),
                                child: Container(
                                  width: 350,
                                  height: 180,
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFFF13640),
                                        Color(0xFF8E3E42)
                                      ],
                                      stops: [0.1454, 1.0],
                                    ),
                                  ),
                                ),
                              ),
                              Column(
                                children: [
                                  SizedBox(height: screenHeight * 0.015),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        right: 170.0, left: 5),
                                    child: Text(
                                      getTextForIndex(index),
                                      textAlign: TextAlign.justify,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize:
                                            screenHeight < 700 ? 13.5 : 17,
                                        fontFamily: 'FontMain',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 7.5),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 70),
                                    child: Text(
                                      getAnotherTextForIndex(index),
                                      textAlign: TextAlign.justify,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize:
                                            screenHeight < 700 ? 12.5 : 14.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 270, top: 30),
                                child: Image.asset(imagePaths[index]),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  //sliding ending

                  SizedBox(
                    height: screenHeight * 0.033,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 190.0),
                    child: Text(
                      "Mentorship",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'FontMain',
                        fontSize: screenWidth < 411 ? 22 : 25,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: screenHeight * 0.026,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15, right: 15),
                    child: Text(
                      "Mentorship at Hiremi is a dynamic partnership designed to promote professional and academic growth. It's a collaborative relationship between experienced mentors and college students seeking guidance in their career or academic pursuits.",
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: screenWidth < 411 ? 12.5 : 16,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: screenHeight * 0.033,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 38.0),
                    child: Stack(
                      children: [
                        Container(
                          width:
                              screenWidth * 0.69, // Adjust the width as needed
                          height: screenHeight *
                              0.28, // Adjust the height as needed
                          child: Card(
                              elevation: 9.0,
                              surfaceTintColor:
                                  Colors.transparent, // rgba(0, 0, 0, 0.25)
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 40, left: 13),
                                    child: Text(
                                      "Standard",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'FontMain',
                                        fontSize: screenWidth < 411 ? 19 : 22,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 24.0,
                                    ),
                                    child: RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                        style: TextStyle(
                                          fontFamily: 'FontMain',
                                          fontSize: screenWidth < 411 ? 19 : 22,
                                          color: Colors
                                              .black, // You can change the color if needed
                                        ),
                                        children: const [
                                          TextSpan(
                                            text: "Rs 10000",
                                          ),
                                          TextSpan(
                                            text: "/25000",
                                            style: TextStyle(
                                              decoration:
                                                  TextDecoration.lineThrough,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: screenHeight * 0.02,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 30.0),
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          child: Container(
                                            height: screenHeight * 0.0308,
                                            width: screenWidth * 0.063,
                                            color: Colors.redAccent,
                                            child: Center(
                                              child: Container(
                                                height: screenHeight * 0.0154,
                                                width: screenWidth * 0.0315,
                                                decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: screenWidth * 0.048,
                                        ),
                                        Text(
                                          "Entire Academic\nSession+ one extra year",
                                          textAlign: TextAlign.justify,
                                          style: TextStyle(
                                            fontFamily: 'FontMain',
                                            fontSize:
                                                screenWidth < 411 ? 11 : 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: screenHeight * 0.02,
                                  ),
                                ],
                              )),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 200.0),
                          child: Card(
                              elevation: 15.0,
                              surfaceTintColor:
                                  Colors.transparent, // rgba(0, 0, 0, 0.25)
                              child: Column(
                                children: [
                                  Text(
                                    "60% OFF",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'FontMain',
                                      fontSize: screenWidth < 411 ? 18 : 21,
                                      color: const Color(0xFFF13640),
                                    ),
                                  ),
                                ],
                              )),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: screenHeight * 0.071,
                  ),
                  Text(
                    "Why Choose Hiremi Mentorship?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'FontMain',
                      fontSize: screenWidth < 411 ? 16.65 : 20,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: screenWidth * 0.033,
                      ),
                      Image.asset('images/partnerpana.png'),
                      //SizedBox(width: screenWidth*0.011,),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "1.Personalised Guidance :",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'FontMain',
                              color: Colors.redAccent,
                              fontSize: screenWidth < 411 ? 10 : 13.5,
                            ),
                          ),
                          SizedBox(
                            height: screenHeight * 0.010,
                          ),
                          Text(
                            "Navigate your career with\npersonalized mentorship\ntailored to your goals \nand aspirations.",
                            textAlign: TextAlign.justify,
                            style: TextStyle(
                              fontFamily: "FontMain",
                              fontSize: screenWidth < 411 ? 10 : 13,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  SizedBox(
                    height: screenHeight * 0.041,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: screenWidth * 0.018,
                      ),
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 15),
                            child: Text(
                              "2.Industry Insights :",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'FontMain',
                                color: Colors.redAccent,
                                fontSize: screenWidth < 411 ? 10 : 13.5,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: screenHeight * 0.010,
                          ),
                          Text(
                            "Gain valuable insights\ninto your chosen\nfield from experienced\nprofessionals.",
                            textAlign: TextAlign.justify,
                            style: TextStyle(
                              fontFamily: "FontMain",
                              fontSize: screenWidth < 411 ? 10 : 12,
                            ),
                          ),
                        ],
                      ),
                      Image.asset('images/Cpana.png'),
                    ],
                  ),
                  SizedBox(
                    height: screenHeight * 0.035,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: screenWidth * 0.033,
                      ),
                      Image.asset('images/Helping.png'),
                      SizedBox(
                        width: screenWidth * 0.024,
                      ),
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 55),
                            child: Text(
                              "3.Skill Development :",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'FontMain',
                                color: Colors.redAccent,
                                fontSize: screenWidth < 411 ? 10 : 13.5,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            "Elevate your skill set with \ncurated programs designed to \nenhance your capabilities\nand make you job-ready.",
                            textAlign: TextAlign.justify,
                            style: TextStyle(
                              fontFamily: "FontMain",
                              fontSize: screenWidth < 411 ? 10 : 11,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  SizedBox(
                    height: screenHeight * 0.041,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: screenWidth * 0.048,
                      ),
                      Column(
                        children: [
                          Text(
                            "4.Network Opportunities:",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'FontMain',
                              color: Colors.redAccent,
                              fontSize: screenWidth < 411 ? 10 : 13,
                            ),
                          ),
                          SizedBox(
                            height: screenHeight * 0.010,
                          ),
                          Text(
                            "Expand your professional\nnetwork with connections\nthat can influence\nyour career trajectory.",
                            textAlign: TextAlign.justify,
                            style: TextStyle(
                              fontFamily: "FontMain",
                              fontSize: screenWidth < 411 ? 10 : 12,
                            ),
                          ),
                        ],
                      ),
                      Image.asset('images/pana.png'),
                    ],
                  ),
                  SizedBox(
                    height: screenHeight * 0.041,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: screenWidth * 0.09,
                      ),
                      Image.asset('images/Confidence.png'),
                      SizedBox(
                        width: screenHeight * 0.011,
                      ),
                      Column(
                        children: [
                          Text(
                            "5.Confidence building:",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'FontMain',
                              color: Colors.redAccent,
                              fontSize: screenWidth < 411 ? 10 : 13,
                            ),
                          ),
                          SizedBox(
                            height: screenHeight * 0.010,
                          ),
                          Text(
                            "Develop confidence in\nyour abilities with\nongoing support and\nconstructive feedback.",
                            textAlign: TextAlign.justify,
                            style: TextStyle(
                              fontFamily: "FontMain",
                              fontSize: screenWidth < 411 ? 10 : 12,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  SizedBox(
                    height: screenHeight * 0.0415,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 48.0),
                    child: Text(
                      "Who does it help?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'FontMain',
                        fontSize: screenWidth < 411 ? 24 : 28,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: screenHeight * 0.0415,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset("images/JobSeeker.png"),
                      SizedBox(
                        width: screenWidth * 0.020,
                      ),
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 180.0),
                            child: Text(
                              "Job Seekers:",
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontFamily: 'FontMain',
                                fontSize: screenWidth < 411 ? 11 : 12,
                              ),
                            ),
                          ),
                          Text(
                            "Individuals looking to enter the jobmarket \nbenefit from mentorship by gaining a\ncompetitive edge and understanding\nindustry expectations.",
                            textAlign: TextAlign.justify,
                            style: TextStyle(
                              fontFamily: "FontMain",
                              fontSize: screenWidth < 411 ? 10 : 12,
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: screenHeight * 0.0415,
                  ),
                  SizedBox(
                    height: screenHeight * 0.03,
                  ),
                  Text(
                    "How to Apply for Mentorship?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'FontMain',
                      fontSize: screenWidth < 411 ? 19 : 23,
                    ),
                  ),
                  SizedBox(
                    height: screenHeight * 0.041,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Image.asset("images/Rocket.png"),
                        ],
                      ),
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 170.0),
                            child: Text(
                              "Step 1:",
                              style: TextStyle(
                                  color: Colors.redAccent,
                                  fontFamily: "FontMain",
                                  fontSize: screenWidth < 411 ? 11 : 11.5),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(right: 135),
                            child: Text(
                              "Tap to apply",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: "FontMain",
                                  fontSize: 11),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Text(
                              "1.Launch the Hiremi appand\nhead to the Mentorship section.",
                              textAlign: TextAlign.justify,
                              style: TextStyle(
                                fontFamily: "FontMain",
                                fontSize: screenWidth < 411 ? 9.4 : 11,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 3.5,
                          ),
                          Text(
                            "2.Look for the apply now option \n and tap on it to begin your\n application process.",
                            textAlign: TextAlign.justify,
                            style: TextStyle(
                              fontFamily: "FontMain",
                              fontSize: screenWidth < 411 ? 9.4 : 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 80.0),
                    child: Image.asset("images/Line.png"),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: screenWidth * 0.024,
                      ),
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 140),
                            child: Text(
                              "Step 2:",
                              style: TextStyle(
                                  color: Colors.redAccent,
                                  fontFamily: "FontMain",
                                  fontSize: screenWidth < 411 ? 11 : 11.5),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(right: 104),
                            child: Text(
                              "Q&A Session:",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: "FontMain",
                                  fontSize: 11),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Text(
                              "1.Once your session is\nscheduled,you will receive a\n notification.",
                              textAlign: TextAlign.justify,
                              style: TextStyle(
                                fontFamily: "FontMain",
                                fontSize: screenWidth < 411 ? 9 : 11,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 3.5,
                          ),
                          Text(
                            "2.During the session ,you'll\nhave to opportunity to\ndiscuss your queires and\ncareer aspiration with our\nexperienced mentors.",
                            textAlign: TextAlign.justify,
                            style: TextStyle(
                              fontFamily: "FontMain",
                              fontSize: screenWidth < 411 ? 9 : 11,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: screenWidth * 0.036,
                      ),
                      Column(
                        children: [
                          Image.asset("images/Meeting.png"),
                        ],
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 20.0),
                    child: Image.asset("images/Line2.png"),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Image.asset("images/Flag.png"),
                        ],
                      ),
                      SizedBox(
                        width: screenWidth * 0.060,
                      ),
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 149),
                            child: Text(
                              "Step 3:",
                              style: TextStyle(
                                  color: Colors.redAccent,
                                  fontFamily: "FontMain",
                                  fontSize: screenWidth < 411 ? 11 : 11.5),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(right: 60),
                            child: Text(
                              "Enroll in the program:",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: "FontMain",
                                  fontSize: 11),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 23, top: 5),
                            child: Text(
                              "1.After selection, gain exclusive\naccess to enroll in our mentor-\nship program via the app by\ncompleting payment process.",
                              textAlign: TextAlign.justify,
                              style: TextStyle(
                                fontFamily: "FontMain",
                                fontSize: screenWidth < 411 ? 9 : 11,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 3.5,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 18),
                            child: Text(
                              "2.Get ready for a transformative\nexperience in skill development,\nreal-time project exposure, and\ncareer growth.",
                              textAlign: TextAlign.justify,
                              style: TextStyle(
                                fontFamily: "FontMain",
                                fontSize: screenWidth < 411 ? 9 : 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: screenHeight * 0.100,
                  )
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SizedBox(
                height: screenHeight * 0.0711, // Adjust the height as needed
                // Adjust the color as needed
                child: Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      await checkInternetConnection();
                      await AlreadyApplied();
                      if(_isConnected){
                        if (hasAlreadyApplied) {
                          // User has already applied, disable the button
                          return;
                        } else {
                          await _showConformationDialog();
                          // await ShowDialog();
                        }
                      }else{
                        print("No internet connection");
                        showDialog(
                          context: context,
                          builder: (context) => Theme(
                            data: ThemeData(
                              dialogBackgroundColor: Colors.redAccent, // Change the color here
                            ),
                            child: AlertDialog(
                              title: const Text('No Internet Connection', style: TextStyle(color: Colors.white,fontFamily: "FontMain")), // Change title color here
                              content: const Text('Please check your internet connection.', style: TextStyle(color: Colors.white)), // Change content color here
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('OK', style: TextStyle(color: Colors.white)), // Change button text color here
                                ),
                              ],
                            ),
                          ),
                        );

                      }

                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: hasAlreadyApplied
                          ? Colors.grey
                          : const Color(0xFFF13640),
                      minimumSize: const Size(250, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      hasAlreadyApplied ? "Already Applied" : "Apply Now",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: hasAlreadyApplied ? Colors.white : Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
