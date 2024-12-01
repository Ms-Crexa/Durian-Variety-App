import 'package:durian_app/Pages/onboarding.dart';
import 'package:durian_app/dashboard.dart';
import 'package:durian_app/edit_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEFBF),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF464653), width: 4),
                ),
                child: ClipOval(
                  child: Image.asset(
                    'lib/assets/images/logo.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'User Settings',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Color(0xFF464653),
                fontFamily: 'KodeMono',
              ),
            ),
            const SizedBox(height: 20),
            CustomButton(
              label: 'Edit Profile',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditProfilePage()),
                );
              },
            ),
            const SizedBox(height: 8),
            CustomButton(
              label: 'Get Started',
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Onboarding()),
                );
              },
            ),
            const SizedBox(height: 125),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFEFBF),
                  padding: const EdgeInsets.symmetric(vertical: 15),
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
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (Route<dynamic> route) => false,
                  );
                },
                child: const Text(
                  'Log out',
                  style: TextStyle(
                    color: Color(0xFF464653),
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

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const CustomButton({required this.label, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF8F0D8),
          textStyle: const TextStyle(
            fontFamily: 'KodeMono',
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Color(0xFF464653),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          side: const BorderSide(
            color: Color(0xFF464653),
            width: 3,
          ),
        ),
        onPressed: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Color(0xFF464653),
                fontFamily: 'KodeMono',
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                size: 24, color: Color(0xFF464653)),
          ],
        ),
      ),
    );
  }
}
