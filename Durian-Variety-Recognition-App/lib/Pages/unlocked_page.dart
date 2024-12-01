import 'package:durian_app/dashboard.dart';
import 'package:durian_app/Pages/durian_info_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:durian_app/models/durian.dart';
import 'package:durian_app/services/durian_parse.dart';

class UnlockedDurianPage extends StatefulWidget {
  const UnlockedDurianPage({super.key});

  @override
  _UnlockedDurianPageState createState() => _UnlockedDurianPageState();
}

class _UnlockedDurianPageState extends State<UnlockedDurianPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final User? user = FirebaseAuth.instance.currentUser;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _scrollbarKey = GlobalKey();

  final List<String> allDurians = [
    'Aroncillo',
    'D101',
    'Davao Selection',
    'Duyaya',
    'Kob Basketball',
    'Kob White',
    'Lacson',
    'Monthong',
    'Native',
    'Puyat'
  ];

  List<String> unlockedDurians = [];
  List<Durian> durianData = [];
  Durian? selectedDurian;

  @override
  void initState() {
    super.initState();
    fetchUnlockedDurians();
    loadDurianInfo();
  }

  Future<void> fetchUnlockedDurians() async {
    if (user == null) return;

    try {
      var userRef =
          firestore.collection('users').doc(user!.uid).collection('varieties');
      var snapshot = await userRef.get();

      List<String> unlocked =
          snapshot.docs.map((doc) => doc['name'].toString()).toList();

      setState(() {
        unlockedDurians = unlocked;
      });
    } catch (e) {
      print('Error fetching unlocked durians: $e');
    }
  }

  Future<void> loadDurianInfo() async {
    durianData = await loadDurianData();
    setState(() {});
  }

  Durian? getDurianDetails(String name) {
    return durianData.firstWhere((durian) => durian.name == name,
        orElse: () => Durian(
              id: '',
              name: name,
              fruitType: '',
              flavorProfile: '',
              description: '',
              locations: [],
              images: {},
            ));
  }

  String getLockedImagePath(String durianName) {
    return 'lib/assets/images/locked/${durianName.replaceAll(' ', ' ').toUpperCase()}-BLK.png';
  }

  String getUnlockedImagePath(String durianName) {
    return 'lib/assets/images/unlocked/${durianName.replaceAll(' ', ' ').toUpperCase()}-FRNT.png';
  }

  void _onDragUpdate(DragUpdateDetails details) {
    final renderBox =
        _scrollbarKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final position = renderBox.globalToLocal(details.globalPosition);
      final newScrollPosition = (position.dy / (renderBox.size.height - 20)) *
          _scrollController.position.maxScrollExtent;
      _scrollController.jumpTo(newScrollPosition.clamp(
          0.0, _scrollController.position.maxScrollExtent));
    }
  }

  @override
  Widget build(BuildContext context) {
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
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 270,
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F0D8),
                    border:
                        Border.all(color: const Color(0xFF464653), width: 5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: selectedDurian != null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              unlockedDurians.contains(selectedDurian!.name)
                                  ? getUnlockedImagePath(selectedDurian!.name)
                                  : getLockedImagePath(selectedDurian!.name),
                              width: 220,
                              height: 220,
                              fit: BoxFit.cover,
                            ),
                          ],
                        )
                      : const Center(
                          child: Text(
                            'Select a durian from\nthe list below',
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'KodeMono',
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF464653),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 300,
                        padding: const EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F0D8),
                          border: Border.all(
                              color: const Color(0xFF464653), width: 5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: allDurians.length,
                          itemBuilder: (context, index) {
                            String durianName = allDurians[index];
                            bool isUnlocked =
                                unlockedDurians.contains(durianName);
                            bool isSelected =
                                selectedDurian?.name == durianName;

                            return Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 12),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFFFEFBF)
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF464653)
                                      : Colors.transparent,
                                  width: 5,
                                ),
                                borderRadius: isSelected
                                    ? BorderRadius.circular(8)
                                    : null,
                              ),
                              child: ListTile(
                                title: Text(
                                  isUnlocked ? durianName : "-------------",
                                  style: const TextStyle(
                                    fontFamily: 'KodeMono',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18,
                                    color: Color(0xFF464653),
                                  ),
                                ),
                                trailing: Text(
                                  isUnlocked
                                      ? ':${(index + 1).toString().padLeft(3, '0')}'
                                      : ':   ',
                                  style: const TextStyle(
                                    fontFamily: 'KodeMono',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18,
                                    color: Color(0xFF464653),
                                  ),
                                ),
                                onTap: () {
                                  setState(() {
                                    selectedDurian =
                                        getDurianDetails(durianName);
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      key: _scrollbarKey,
                      width: 30,
                      height: 300,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F0D8),
                        border: Border.all(
                            color: const Color(0xFF464653), width: 5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: GestureDetector(
                        onVerticalDragUpdate: _onDragUpdate,
                        child: Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            Positioned(
                              top: _scrollController.hasClients
                                  ? (_scrollController.offset /
                                          _scrollController
                                              .position.maxScrollExtent) *
                                      (250 - 20)
                                  : 0,
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF464653),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 16,
            right: -16,
            child: ElevatedButton(
              onPressed: selectedDurian != null &&
                      unlockedDurians.contains(selectedDurian!.name)
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DurianInfoPage(durian: selectedDurian!),
                        ),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFEFBF),
                disabledBackgroundColor: const Color(0xFFFFEFBF),
                foregroundColor: const Color(0xFF464653),
                padding:
                    const EdgeInsets.symmetric(horizontal: 100, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(
                    color: Color(0xFF464653),
                    width: 5,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      'Select',
                      style: TextStyle(
                        fontFamily: 'KodeMono',
                        fontWeight: FontWeight.w600,
                        fontSize: 24,
                        color: Color(0xFF464653),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
