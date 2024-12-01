import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:durian_app/Pages/unlocked_page.dart';
import 'package:durian_app/settings_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/services.dart';
import '../../Controllers/select_image_controller.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final User? user = FirebaseAuth.instance.currentUser;
  final SelectImageController selectImageController =
      Get.put(SelectImageController());

  int _selectedIndex = 0;

  Future<List<String>> loadFacts() async {
    final String response =
        await rootBundle.loadString('lib/assets/data/facts.json');
    final List<dynamic> data = json.decode(response);
    return data.map((fact) => fact['fact'].toString()).toList();
  }

  Future<List<dynamic>> loadFeaturedVarieties() async {
    final String response =
        await rootBundle.loadString('lib/assets/data/featured_variety.json');
    return json.decode(response);
  }

  Future<int> fetchVarietyCount() async {
    if (user == null) return 0;

    try {
      var userRef =
          firestore.collection('users').doc(user!.uid).collection('varieties');
      var snapshot = await userRef.get();
      return snapshot.docs.length;
    } catch (e) {
      print('Error fetching varieties count: $e');
      return 0;
    }
  }

  Future<DocumentSnapshot> getUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      return await _firestore.collection("users").doc(user.uid).get();
    }
    throw Exception("No user logged in");
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FFAA),
      body: Column(
        children: [
          Expanded(
            child: _selectedIndex == 1
                ? UnlockedDurianPage()
                : _selectedIndex == 2
                    ? SettingsPage()
                    : FutureBuilder<DocumentSnapshot>(
                        future: getUserData(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          if (snapshot.hasError) {
                            return Center(
                                child: Text("Error: ${snapshot.error}"));
                          }

                          if (!snapshot.hasData || !snapshot.data!.exists) {
                            return const Center(
                                child: Text("No User Data Found"));
                          }

                          Map<String, dynamic> userData =
                              snapshot.data!.data() as Map<String, dynamic>;

                          return _selectedIndex == 0
                              ? _buildUserProfilePage(userData)
                              : _buildOtherPage();
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? Padding(
              padding: const EdgeInsets.only(top: 20),
              child: FloatingActionButton(
                onPressed: () {
                  setState(() {
                    _selectedIndex = 3;
                  });
                  selectImageController.showImagesPickerDialog(context);
                },
                backgroundColor: const Color(0xFFFFEFBF),
                elevation: 0,
                shape: CircleBorder(
                  side: BorderSide(color: const Color(0xFF464653), width: 5),
                ),
                child: const FaIcon(
                  FontAwesomeIcons.camera,
                  size: 30,
                  color: Color(0xFF464653),
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _selectedIndex == 0
          ? Container(
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFFFFEFBF),
                border: Border.all(color: const Color(0xFF464653), width: 5),
              ),
              child: BottomAppBar(
                shape: const CircularNotchedRectangle(),
                notchMargin: 4,
                color: const Color(0xFFF8F0D8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildIconCircle(
                      icon: FontAwesomeIcons.list,
                      onTap: () => _onItemTapped(1),
                    ),
                    const SizedBox(width: 30),
                    _buildIconCircle(
                      icon: FontAwesomeIcons.userLarge,
                      onTap: () => _onItemTapped(2),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildIconCircle(
      {required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFFFFEFBF),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF464653), width: 5),
            ),
          ),
          FaIcon(
            icon,
            size: 15,
            color: const Color(0xFF464653),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfilePage(Map<String, dynamic> userData) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          _buildUserInfoCard(userData),
          const SizedBox(height: 35),
          _buildDidYouKnowCard(),
          _buildFeaturedVarietyCard(),
        ],
      ),
    );
  }

  Widget _buildUserInfoCard(Map<String, dynamic> userData) {
    return FutureBuilder<int>(
      future: fetchVarietyCount(),
      builder: (context, snapshot) {
        int varietyCount = snapshot.data ?? 0;

        String getTitle(int count) {
          if (count >= 10) return 'Durian Connoisseur';
          if (count >= 8) return 'Master Gatherer';
          if (count >= 5) return 'Fruit Explorer';
          if (count >= 3) return 'Durian Enthusiast';
          if (count >= 1) return 'Avid Collector';
          return 'Newcomer';
        }

        return Card(
          color: const Color(0xFFFFEFBF),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: Color(0xFF464653), width: 5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFF8F0D8),
                    border:
                        Border.all(color: const Color(0xFF464653), width: 5),
                  ),
                  child: ClipOval(
                    child: userData['profile_picture'] != null &&
                            userData['profile_picture'].isNotEmpty
                        ? Image.network(
                            userData['profile_picture'],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'lib/assets/images/logo.png',
                                fit: BoxFit.cover,
                              );
                            },
                          )
                        : Image.asset(
                            'lib/assets/images/logo.png',
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AutoSizeText(
                        '${userData['username']}',
                        style: const TextStyle(
                          fontFamily: 'KodeMono',
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF464653),
                        ),
                        maxLines: 1,
                        minFontSize: 12,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        getTitle(varietyCount),
                        style: const TextStyle(
                          fontFamily: 'KodeMono',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF464653),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDidYouKnowCard() {
    return FutureBuilder<List<String>>(
      future: loadFacts(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final facts = snapshot.data!;
        final randomFact = (facts..shuffle()).first;

        return SizedBox(
          height: 190,
          child: Stack(
            children: [
              Positioned(
                top: 30,
                left: 0,
                right: 0,
                child: Card(
                  color: const Color(0xFFF8F0D8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: Color(0xFF464653), width: 5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 60,
                                height: 60,
                                child: Image.asset(
                                  'lib/assets/images/DurianCapture.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    randomFact,
                                    style: const TextStyle(
                                      fontFamily: 'KodeMono',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF464653),
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                child: Card(
                  color: const Color(0xFFFFEFBF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: Color(0xFF464653), width: 5),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.only(top: 8, bottom: 4),
                    child: Text(
                      'Did you know?',
                      style: TextStyle(
                        fontFamily: 'KodeMono',
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF464653),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeaturedVarietyCard() {
    return FutureBuilder<List<dynamic>>(
      future: loadFeaturedVarieties(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final varieties = snapshot.data!;
        final index = DateTime.now().day % varieties.length;
        final featuredVariety = varieties[index];

        return SizedBox(
          height: 330,
          child: Stack(
            children: [
              Positioned(
                top: 50,
                left: 0,
                right: 0,
                child: Card(
                  color: const Color(0xFFF8F0D8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: Color(0xFF464653), width: 5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFEFBF),
                                  border: Border.all(
                                      color: const Color(0xFF464653), width: 5),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Image.asset(
                                  featuredVariety['image'],
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      featuredVariety['name'],
                                      style: const TextStyle(
                                        fontFamily: 'KodeMono',
                                        fontSize: 24,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF464653),
                                        height: 1.0,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            featuredVariety['description'],
                            style: const TextStyle(
                              fontFamily: 'KodeMono',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF464653),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                child: Card(
                  color: const Color(0xFFFFEFBF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: Color(0xFF464653), width: 5),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.only(top: 10, bottom: 12),
                    child: Text(
                      'Featured Variety\nof the Day',
                      style: TextStyle(
                        fontFamily: 'KodeMono',
                        fontSize: 24,
                        height: 0.9,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF464653),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOtherPage() {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FFAA),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50.0),
        child: AppBar(
          backgroundColor: const Color(0xFFFFEFBF),
          elevation: 0,
          titleSpacing: 0,
          title: const Text(
            'Dashboard',
            style: TextStyle(
              fontFamily: 'KodeMono',
              fontWeight: FontWeight.w600,
              color: Color(0xFF464653),
              fontSize: 18,
            ),
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.chevron_left_rounded,
              color: Color(0xFF464653),
              size: 30,
            ),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => UserProfileScreen()),
              );
            },
          ),
          shape: const RoundedRectangleBorder(
            side: BorderSide(color: Color(0xFF464653), width: 5),
          ),
        ),
      ),
      body: Center(
        child: Text(
          'You have to scan first',
          style: TextStyle(
            fontFamily: 'KodeMono',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF464653),
          ),
        ),
      ),
    );
  }
}
