// ignore_for_file: use_build_context_synchronously

import 'package:durian_app/dashboard.dart';
import 'package:durian_app/signup_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  // Variable types
  String username = '';
  String email = '';
  String password = '';
  bool isLoading = false;
  bool isPasswordVisible = false;

  // Function to fetch email based on the username from Firestore
  Future<String> _getEmailFromUsername(String username) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first['email'];
      } else {
        throw Exception('Username not found');
      }
    } catch (error) {
      throw Exception('Error fetching email: $error');
    }
  }

  Future<void> _loginWithUsernamePassword() async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() {
          isLoading = true;
        });

        // Fetch the email associated with the entered username
        email = await _getEmailFromUsername(username);

        // Proceed with Firebase Authentication using email and password
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);

        // Navigate to UserProfileScreen on successful login
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => UserProfileScreen(),
          ),
        );
      } catch (error) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      setState(() {
        isLoading = true;
      });

      // Initiate the Google Sign-In process
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User canceled the sign-in
        setState(() {
          isLoading = false;
        });
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase using the Google credentials
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // Check if the user already exists in Firestore
        final DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        if (!userDoc.exists) {
          // Save new user details to Firestore
          await _firestore.collection('users').doc(user.uid).set({
            'username': user.displayName ?? 'Anonymous',
            'email': user.email,
            'profile_picture': user.photoURL ?? '',
          });
        }

        // Navigate to the UserProfileScreen after successful login
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => UserProfileScreen(),
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Function to send a password reset email
  Future<void> _forgotPassword() async {
    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter your username first')));
      return;
    }
    try {
      setState(() {
        isLoading = true;
      });

      // Fetch the email associated with the username
      email = await _getEmailFromUsername(username);

      // Send the password reset email
      await _auth.sendPasswordResetEmail(email: email);

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset email sent!')));
    } catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFF6FFAA),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 50),
                const Text(
                  'Welcome to',
                  style: TextStyle(
                    fontFamily: 'KodeMono',
                    fontWeight: FontWeight.w600,
                    fontSize: 24,
                    color: Color(0xFF464653),
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0, -10),
                  child: const Text(
                    'DurioDex',
                    style: TextStyle(
                      fontFamily: 'KodeMono',
                      fontWeight: FontWeight.bold,
                      fontSize: 50,
                      color: Colors.red,
                    ),
                  ),
                ),
                Image.asset('lib/assets/images/logo.png', height: 180),
                const SizedBox(height: 20),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    labelStyle: TextStyle(
                        fontFamily: 'KodeMono', color: Color(0xFF464653)),
                    filled: true,
                    fillColor: Color(0xFFF9F1D7),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                      borderSide: BorderSide(
                        color: Color(0xFF464653),
                        width: 1,
                      ),
                    ),
                  ),
                  style: const TextStyle(fontFamily: 'KodeMono'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your username';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      username = value;
                    });
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(
                        fontFamily: 'KodeMono', color: Color(0xFF464653)),
                    filled: true,
                    fillColor: const Color(0xFFF9F1D7),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                      borderSide: BorderSide(
                        color: Color(0xFF464653),
                        width: 1,
                      ),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          isPasswordVisible = !isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  obscureText: !isPasswordVisible,
                  style: const TextStyle(fontFamily: 'KodeMono'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      password = value;
                    });
                  },
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: isLoading
                      ? Center(
                          child: SizedBox(
                            height: 24.0,
                            width: 24.0,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2.0,
                            ),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: _loginWithUsernamePassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFEFBF),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 50, vertical: 15),
                            textStyle: const TextStyle(
                                fontFamily: 'KodeMono',
                                fontSize: 24,
                                fontWeight: FontWeight.w600),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            side: const BorderSide(
                              color: Color(0xFF464653),
                              width: 3,
                            ),
                          ),
                          child: const Text(
                            'Login',
                            style: TextStyle(color: Color(0xFF464653)),
                          ),
                        ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Don\'t have an account? ',
                      style: TextStyle(
                        fontFamily: 'KodeMono',
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignUpPage()));
                      },
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            fontFamily: 'KodeMono',
                            fontSize: 14,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _signInWithGoogle,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFEFBF),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 20),
                      textStyle: const TextStyle(
                          fontFamily: 'KodeMono',
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      side: const BorderSide(
                        color: Color(0xFF464653),
                        width: 3,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'lib/assets/images/Google.png',
                          height: 18,
                          width: 18,
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Continue with Google',
                          style: TextStyle(color: Color(0xFF464653)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _forgotPassword,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        fontFamily: 'KodeMono',
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                        color: Color(0xFF464653),
                      ),
                    ),
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
