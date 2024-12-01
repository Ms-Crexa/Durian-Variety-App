import 'package:durian_app/Pages/unlocked_page.dart';
import 'package:durian_app/dashboard.dart';
import 'package:durian_app/models/durian.dart';
import 'package:durian_app/services/durian_parse.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Controllers/select_image_controller.dart';

class ResultPage extends StatefulWidget {
  final String result;

  const ResultPage({super.key, required this.result});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  SelectImageController selectImageController =
      Get.put(SelectImageController());

  late Future<List<Durian>> durianData;

  @override
  void initState() {
    super.initState();
    durianData = loadDurianData();
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
      body: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCongratulationsMessage(),
            const SizedBox(height: 20),
            _buildDurianDescription(),
            const SizedBox(height: 15),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: FutureBuilder<List<Durian>>(
                future: durianData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return const Text('Error loading data');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No durian data available');
                  }

                  final durian = snapshot.data!.firstWhere(
                    (d) => d.name.toLowerCase() == widget.result.toLowerCase(),
                    orElse: () => Durian(
                        id: '',
                        name: '',
                        description: '',
                        fruitType: '',
                        flavorProfile: '',
                        images: {},
                        locations: []),
                  );

                  final isUnknown = durian.name == 'Unknown';

                  return ElevatedButton(
                    onPressed: () {
                      if (isUnknown) {
                        selectImageController.showImagesPickerDialog(context);
                      } else {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UnlockedDurianPage(),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFEFBF),
                      textStyle: const TextStyle(
                        fontFamily: 'KodeMono',
                        color: Color.fromARGB(255, 83, 70, 79),
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      side: const BorderSide(
                        color: Color(0xFF464653),
                        width: 3,
                      ),
                    ),
                    child: Text(isUnknown ? 'Retry' : 'Continue'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCongratulationsMessage() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: BorderSide(color: Colors.grey.shade700, width: 5),
        ),
        color: Colors.amber.shade100,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder<List<Durian>>(
                future: durianData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Text('Error loading data');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No durian data available');
                  }

                  final durian = snapshot.data!.firstWhere(
                    (d) => d.name.toLowerCase() == widget.result.toLowerCase(),
                    orElse: () => Durian(
                        id: '',
                        name: '',
                        description: '',
                        fruitType: '',
                        flavorProfile: '',
                        images: {},
                        locations: []),
                  );

                  final isUnknown = durian.name == 'Unknown';
                  final headingText =
                      isUnknown ? "Unfortunately," : "Congratulations!";
                  final messageText = isUnknown
                      ? "We couldn't identify the durian :("
                      : "You've got ";
                  final prediction = isUnknown ? "" : "${durian.name}!";

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        headingText,
                        style: const TextStyle(
                          fontFamily: 'KodeMono',
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF464653),
                        ),
                      ),
                      RichText(
                          text: TextSpan(
                              text: messageText,
                              style: TextStyle(
                                fontFamily: 'KodeMono',
                                fontSize: 22,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF464653),
                              ),
                              children: [
                            TextSpan(
                              text: prediction,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF464653),
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ]))
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDurianDescription() {
    return FutureBuilder<List<Durian>>(
      future: durianData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Text('Error loading description');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('No durian description available');
        }

        final durian = snapshot.data!.firstWhere(
          (d) => d.name.toLowerCase() == widget.result.toLowerCase(),
          orElse: () => Durian(
              id: '',
              name: '',
              description: '',
              fruitType: '',
              flavorProfile: '',
              images: {},
              locations: []),
        );

        return Container(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              color: Colors.amber.shade100,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 250,
                padding: EdgeInsets.all(30),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Color(0xFF464653),
                    width: 4,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Image.asset(
                  durian.images['front'] ??
                      'lib/assets/images/IdentifyDurian.png',
                  width: 10,
                  height: 10,
                  // fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding:
                  EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    durian.name.isNotEmpty ? durian.name : 'No name available.',
                    style: const TextStyle(
                      fontFamily: 'KodeMono',
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      text: "Fruit Type: ",
                      style: const TextStyle(
                        fontFamily: 'KodeMono',
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF464653),
                      ),
                      children: [
                        TextSpan(
                          text: durian.flavorProfile.isNotEmpty
                              ? durian.fruitType
                              : 'No name available.',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                            color: Color(0xFF464653),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 15),
                  RichText(
                    text: TextSpan(
                      text: "Flavor Profile: ",
                      style: const TextStyle(
                        fontFamily: 'KodeMono',
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF464653),
                      ),
                      children: [
                        TextSpan(
                          text: durian.fruitType.isNotEmpty
                              ? durian.flavorProfile
                              : 'No description available.',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                            color: Color(0xFF464653),
                          ),
                        ),
                      ],
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      text: "Description: ",
                      style: const TextStyle(
                        fontFamily: 'KodeMono',
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF464653),
                      ),
                      children: [
                        TextSpan(
                          text: durian.description.isNotEmpty
                              ? durian.description
                              : 'No description available.',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                            color: Color(0xFF464653),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ));
      },
    );
  }
}
