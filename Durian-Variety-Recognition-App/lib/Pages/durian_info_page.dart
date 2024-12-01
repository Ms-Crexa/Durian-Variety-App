import 'package:flutter/material.dart';
import 'package:durian_app/models/durian.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DurianInfoPage extends StatefulWidget {
  final Durian durian;

  const DurianInfoPage({super.key, required this.durian});

  @override
  _DurianInfoPageState createState() => _DurianInfoPageState();
}

class _DurianInfoPageState extends State<DurianInfoPage> {
  bool showDefinition = true;
  int currentViewIndex = 0;

  final List<String> viewCodes = ['FRNT', 'BCK', 'TP', 'BTTM'];
  final List<String> viewLabels = [
    'Front View',
    'Back View',
    'Top View',
    'Bottom View'
  ];

  String get currentViewCode => viewCodes[currentViewIndex];
  String get currentViewLabel => viewLabels[currentViewIndex];

  void nextView() {
    setState(() {
      currentViewIndex = (currentViewIndex + 1) % viewCodes.length;
    });
  }

  void previousView() {
    setState(() {
      currentViewIndex =
          (currentViewIndex - 1 + viewCodes.length) % viewCodes.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FFAA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFEFBF),
        elevation: 0,
        title: Text(
          'Collection',
          style: const TextStyle(
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
            Navigator.pop(context);
          },
        ),
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: Color(0xFF464653), width: 5),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEFBF),
                    border:
                        Border.all(color: const Color(0xFF464653), width: 5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.durian.name,
                        style: const TextStyle(
                          fontFamily: 'KodeMono',
                          fontWeight: FontWeight.w600,
                          fontSize: 24,
                          color: Color(0xFF464653),
                        ),
                      ),
                      Text(
                        ': ${widget.durian.id}',
                        style: const TextStyle(
                          fontFamily: 'KodeMono',
                          fontWeight: FontWeight.w600,
                          fontSize: 24,
                          color: Color(0xFF464653),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  height: 280,
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F0D8),
                    border:
                        Border.all(color: const Color(0xFF464653), width: 5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    showDefinition
                        ? widget.durian.description
                        : "This variety is commonly available at:\n${widget.durian.locations.map((location) => '   => $location').join('\n')}",
                    style: const TextStyle(
                      fontFamily: 'KodeMono',
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      color: Color(0xFF464653),
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 260,
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
                            side: const BorderSide(
                                color: Color(0xFF464653), width: 5),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      icon: const FaIcon(
                                        FontAwesomeIcons.chevronLeft,
                                        color: Color(0xFF464653),
                                      ),
                                      onPressed: previousView,
                                    ),
                                    Image.asset(
                                      'lib/assets/images/unlocked/${widget.durian.name.replaceAll(' ', ' ').toUpperCase()}-$currentViewCode.png',
                                      width: 160,
                                      height: 160,
                                      fit: BoxFit.cover,
                                    ),
                                    IconButton(
                                      icon: const FaIcon(
                                        FontAwesomeIcons.chevronRight,
                                        color: Color(0xFF464653),
                                      ),
                                      onPressed: nextView,
                                    ),
                                  ],
                                ),
                              ],
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
                            side: const BorderSide(
                                color: Color(0xFF464653), width: 5),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 4),
                            child: Text(
                              currentViewLabel,
                              style: const TextStyle(
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
                ),
              ],
            ),
          ),
          Positioned(
            top: 230,
            right: -16,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  showDefinition = true;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: showDefinition
                    ? const Color(0xFFFFEFBF)
                    : const Color(0xFFF8F0D8),
                foregroundColor: const Color(0xFF464653),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: Color(0xFF464653), width: 5),
                ),
                fixedSize: const Size(240, 50),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Definition',
                  style: const TextStyle(
                    fontFamily: 'KodeMono',
                    fontWeight: FontWeight.w600,
                    fontSize: 24,
                    color: Color(0xFF464653),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 290,
            right: -16,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  showDefinition = false;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: !showDefinition
                    ? const Color(0xFFFFEFBF)
                    : const Color(0xFFF8F0D8),
                foregroundColor: const Color(0xFF464653),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: Color(0xFF464653), width: 5),
                ),
                fixedSize: const Size(240, 50),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Location',
                  style: const TextStyle(
                    fontFamily: 'KodeMono',
                    fontWeight: FontWeight.w600,
                    fontSize: 24,
                    color: Color(0xFF464653),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
