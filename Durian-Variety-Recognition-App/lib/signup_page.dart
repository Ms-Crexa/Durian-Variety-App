import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:durian_app/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;
  bool isPasswordVisible = false; // To manage password visibility

  // Declare variables to hold user input
  String username = '';
  String email = '';
  String password = '';

  // Function to handle sign-up logic
  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() {
          isLoading = true;
        });

        // Create user with email and password
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Prepare data to be saved in Firestore
        Map<String, dynamic> data = {
          'username': username,
          'email': email,
          'uid': userCredential.user?.uid, // Store user ID
        };

        // Save username and email in Firestore as a new document
        await _firestore
            .collection('users')
            .doc(userCredential.user?.uid)
            .set(data);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User registered successfully!')),
        );

        // Navigate to LoginPage after successful sign-up
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      } catch (e) {
        print("Error during sign-up: $e"); // Log any error
        if (e is FirebaseAuthException) {
          String message;
          switch (e.code) {
            case 'weak-password':
              message = 'The password provided is too weak.';
              break;
            case 'email-already-in-use':
              message = 'The account already exists for that email.';
              break;
            case 'invalid-email':
              message = 'The email address is not valid.';
              break;
            default:
              message = e.message ?? 'An unknown error occurred.';
          }
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(message)));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to register user.')));
        }
      } finally {
        setState(() {
          isLoading = false;
        });
      }
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
                Image.asset('lib/assets/images/logo.png', height: 180),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(
                      fontFamily: 'KodeMono',
                      fontWeight: FontWeight.w600,
                      fontSize: 24,
                      color: Color(0xFF464653),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    labelStyle: TextStyle(
                      fontFamily: 'KodeMono',
                      color: Color(0xFF464653),
                    ),
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
                  style: const TextStyle(
                    fontFamily: 'KodeMono',
                    color: Color(0xFF464653),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your username';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      username = value; // Update username
                    });
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(
                      fontFamily: 'KodeMono',
                      color: Color(0xFF464653),
                    ),
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
                  style: const TextStyle(
                    fontFamily: 'KodeMono',
                    color: Color(0xFF464653),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        !value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      email = value; // Update email
                    });
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: const TextStyle(
                      fontFamily: 'KodeMono',
                      color: Color(0xFF464653),
                    ),
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
                        color: Color(0xFF464653),
                      ),
                      onPressed: () {
                        setState(() {
                          isPasswordVisible = !isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  obscureText: !isPasswordVisible,
                  style: const TextStyle(
                    fontFamily: 'KodeMono',
                    color: Color(0xFF464653),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    } else if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      password = value; // Update password
                    });
                  },
                ),
                const SizedBox(height: 70),
                SizedBox(
                  width: double.infinity,
                  child: isLoading
                      ? Center(
                          child: SizedBox(
                            height: 24.0,
                            width: 24.0,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2.0,
                              color: Color(0xFF464653),
                            ),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: _signUp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFEFBF),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 50, vertical: 15),
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
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(color: Color(0xFF464653)),
                          ),
                        ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(
                        fontFamily: 'KodeMono',
                        fontSize: 14,
                        color: Color(0xFF464653),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginPage()));
                      },
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: const Text(
                          'Log In',
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
