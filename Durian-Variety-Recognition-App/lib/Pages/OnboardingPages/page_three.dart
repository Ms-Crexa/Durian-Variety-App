// ignore_for_file: camel_case_types

import 'package:durian_app/dashboard.dart';
import 'package:flutter/material.dart';

class page_three extends StatefulWidget {
  const page_three({super.key});

  @override
  State<page_three> createState() => _page_threeState();
}

class _page_threeState extends State<page_three> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF6FFAA),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(10, 0, 5, 10),
              child: Image.asset('lib/assets/images/DurianStart.png',
                  width: 300, height: 300, fit: BoxFit.fill),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(0, 15, 0, 3),
              child: const Text(
                'READY SET..',
                style: TextStyle(
                  fontFamily: 'KodeMono',
                  fontWeight: FontWeight.w600,
                  fontSize: 24,
                  color: Color.fromARGB(255, 203, 0, 0),
                ),
              ),
            ),
            Container(
              width: 300,
              margin: const EdgeInsets.only(top: 10, bottom: 20),
              child: const Text(
                'Are you ready to capture, identify, and learn about the Durian Varieties?',
                style: TextStyle(
                  fontFamily: 'KodeMono',
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to UserProfileScreen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => UserProfileScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFEFBF),
                padding:
                    const EdgeInsets.symmetric(horizontal: 90, vertical: 15),
                textStyle: const TextStyle(
                  fontFamily: 'KodeMono',
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                side: const BorderSide(
                  color: Color(0xFF464653),
                  width: 3,
                ),
              ),
              child: const Text(
                'START NOW',
                style: TextStyle(
                  color: Color(0xFF464653),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
