import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hiremi/HomePage.dart';
import 'package:hiremi/InternDescription.dart';
import 'package:hiremi/api_services/base_services.dart';
import 'package:hiremi/models/intern_job_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class InternScreen extends StatefulWidget {
  const InternScreen({super.key});

  @override
  State<InternScreen> createState() => _InternScreenState();
}

class _InternScreenState extends State<InternScreen> {
  List<InternshipJobModel> internshipList = [];
  String loginEmail = "";

  @override
  void initState() {
    super.initState();
    fetchDataFromCacheOrApi();
  }

  Future<bool> checkIfApplied(
      String userEmail, String internshipProfile, String companyName) async {
    try {
      final response = await http
          .get(Uri.parse('${ApiUrls.baseurl}Internship-applications/'));

      if (response.statusCode == 200) {
        final List<dynamic> dataList = json.decode(response.body);

        for (int index = 0; index < dataList.length; index++) {
          final Map<String, dynamic> data = dataList[index];
          final String appliedUserEmail = data['email'];
          final String appliedInternshipProfile = data['Internship_profile'];
          final String appliedCompanyName = data['company_name'];

          if (appliedUserEmail == userEmail &&
              appliedInternshipProfile == internshipProfile &&
              appliedCompanyName == companyName) {
            return true; // User has already applied for this internship
          }
        }
        return false; // User hasn't applied for this internship
      } else {
        print('Status code: ${response.statusCode}');
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print("Error in checkIfApplied: $e");
      return false;
    }
  }

  // Future<void> _loadUserEmail() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? savedUsername = prefs.getString('username');
  //   //String? cacheddata = prefs.getString(cachekey);
  //
  //   if (savedUsername != null && savedUsername.isNotEmpty) {
  //     setState(() {
  //       loginEmail = savedUsername;
  //     });
  //     print("login mail is  $loginEmail");
  //   }
  // }

  Future<void> fetchDataFromCacheOrApi() async {
    // Check if data exists in cache
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? cachedData = prefs.getString('internship_data');

    if (cachedData != null && cachedData.isNotEmpty) {
      // If data exists in cache, parse and use it
      final List<dynamic> cachedList = json.decode(cachedData);
      setState(() {
        internshipList = cachedList
            .map((data) => InternshipJobModel.fromJson(data))
            .toList();
      });
    } else {
      // If data doesn't exist in cache, fetch from API
      fetchDataFromApi();
    }
  }

  Future<void> fetchDataFromApi() async {
    final response =
        await http.get(Uri.parse('${ApiUrls.baseurl}/api/internship/'));

    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);
      setState(() {
        internshipList = responseData
            .map((data) => InternshipJobModel.fromJson(data))
            .toList();
      });

      // Cache the fetched data
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('internship_data', json.encode(responseData));
    } else {
      throw Exception('Failed to load data from the API');
    }
  }

  // Other methods...

  @override
  Widget build(BuildContext context) {
    //print('Applied Job IDs: $AppliedJobIds');
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              await fetchDataFromApi();
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
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
                  child: Image.asset('images/Back_Button.png'),
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 15,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 80),
                      child: Text(
                        "Internships",
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: "FontMain",
                          fontSize: 23,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 25,
                    ),
                    Image.asset(
                      'images/Saly-1 (2).png',
                      width: 180,
                      height: 160,
                      fit: BoxFit.cover,
                    )
                  ],
                ),
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 380,
                        height: 620,
                        child: internshipList != null &&
                                internshipList.isNotEmpty
                            ? ListView.builder(
                                itemCount: internshipList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final internship = internshipList[index];
                                  return Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Card(
                                          color: const Color(0xFFF8F8F8),
                                          elevation: 10,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                          child: Column(
                                            children: [
                                              ListTile(
                                                title: Text(
                                                  'Company: ${internship.companyName}',
                                                  style: const TextStyle(
                                                    fontFamily: 'FontMain',
                                                  ),
                                                ),
                                              ),
                                              ListTile(
                                                title: Text(
                                                  'Location: ${internship.InternshipLocation}',
                                                  style: const TextStyle(
                                                    fontFamily: 'FontMain',
                                                  ),
                                                ),
                                              ),
                                              ListTile(
                                                title: Text(
                                                  'CTC: ${internship.InternshipCtc} LPA',
                                                  style: const TextStyle(
                                                    fontFamily: 'FontMain',
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  left: 200.0,
                                                  right: 10,
                                                  bottom: 10,
                                                ),
                                                child: InkWell(
                                                  onTap: () async {
                                                    print("Hello");
                                                    bool applied =
                                                        await checkIfApplied(
                                                            loginEmail,
                                                            internship
                                                                .InternshipProfile!,
                                                            internship
                                                                .companyName!);

                                                    if (applied) {
                                                      print("Applied");
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                              'You have already applied for this internship.'),
                                                        ),
                                                      );
                                                    } else {
                                                      print("Not Applied");
                                                      final int jobIndex =
                                                          internshipList
                                                              .indexOf(
                                                                  internship);
                                                      print(
                                                          "Selected Job Index: $jobIndex");
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              InternshipDescription(
                                                            jobIndex: jobIndex,
                                                            id: internship.id!,
                                                            InternshipProfile:
                                                                internship
                                                                    .InternshipProfile!,
                                                            InternshipLocation:
                                                                internship
                                                                    .InternshipLocation!,
                                                            InternshipCtc:
                                                                internship
                                                                    .InternshipCtc!,
                                                            companyName:
                                                                internship
                                                                    .companyName!,
                                                            education:
                                                                internship
                                                                    .education!,
                                                            InternshipDescreption:
                                                                internship
                                                                    .InternshipDescription!,
                                                            termsAndConditions:
                                                                internship
                                                                    .termsAndConditions!,
                                                            skillRequired:
                                                                internship
                                                                    .skillsRequired!,
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  },
                                                  child: Container(
                                                    width: 150,
                                                    height: 40,
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                          0xFFBD232B),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                    ),
                                                    child: const Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          'View details',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            fontSize: 15,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: 2,
                                                        ),
                                                        Icon(
                                                          Icons
                                                              .arrow_forward_ios,
                                                          size: 15,
                                                          color: Colors.white,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 73,
                                      ),
                                    ],
                                  );
                                },
                              )
                            : const Padding(
                                padding: EdgeInsets.only(bottom: 75.0),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ),
                      ),
                    ],
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
