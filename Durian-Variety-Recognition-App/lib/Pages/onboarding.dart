// ignore_for_file: library_private_types_in_public_api

import 'package:durian_app/Pages/OnboardingPages/page_one.dart';
import 'package:durian_app/Pages/OnboardingPages/page_two.dart';
import 'package:durian_app/Pages/OnboardingPages/page_three.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  _OnboardingState createState() => _OnboardingState();
}

// PageController to track which page we're on
PageController _controller = PageController();

bool onLastPage = false;

class _OnboardingState extends State<Onboarding> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                onLastPage = (index == 2);
              });
            },
            children: [const page_one(), const page_two(), page_three()],
          ),
          Container(
            alignment: const Alignment(0, 0.75),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (!onLastPage)
                  TextButton(
                    onPressed: () async {
                      for (int i = _controller.page!.toInt(); i < 2; i++) {
                        await _controller.nextPage(
                          duration: const Duration(milliseconds: 180),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        fontFamily: 'KodeMono',
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF464653),
                      ),
                    ),
                  )
                else
                  const SizedBox(width: 60),
                if (!onLastPage)
                  GestureDetector(
                    onTapDown: (details) {
                      double tapPosition = details.localPosition.dx;
                      double indicatorWidth = 60.0;
                      int tappedPage =
                          (tapPosition / (indicatorWidth / 3)).floor();
                      _controller.animateToPage(
                        tappedPage,
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: SmoothPageIndicator(
                      controller: _controller,
                      count: 3,
                      effect: WormEffect(
                        activeDotColor: const Color(0xFF464653),
                        dotColor: Colors.grey,
                        spacing: 8.0,
                        dotHeight: 10,
                        dotWidth: 10,
                        radius: 12,
                      ),
                    ),
                  )
                else
                  const SizedBox(width: 60),
                if (!onLastPage)
                  TextButton(
                    onPressed: () {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: const Text(
                      'Next',
                      style: TextStyle(
                        fontFamily: 'KodeMono',
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF464653),
                      ),
                    ),
                  )
                else
                  const SizedBox(width: 60),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
