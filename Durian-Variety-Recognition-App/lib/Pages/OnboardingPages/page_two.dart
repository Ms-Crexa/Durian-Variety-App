// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';

class page_two extends StatelessWidget {
  const page_two({super.key});

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
              child: Image.asset('lib/assets/images/IdentifyDurian.png',
                  width: 300, height: 330, fit: BoxFit.fill),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(0, 15, 0, 3),
              child: const Text(
                'IDENTIFY',
                style: TextStyle(
                  fontFamily: 'KodeMono',
                  fontWeight: FontWeight.w600,
                  fontSize: 24,
                  color: Color(0xFF464653),
                ),
              ),
            ),
            Container(
              width: 300,
              margin: const EdgeInsets.only(top: 10),
              child: const Text(
                'Identify what kind of Durian Varieties and dive more on its characteristics.',
                style: TextStyle(
                  fontFamily: 'KodeMono',
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
