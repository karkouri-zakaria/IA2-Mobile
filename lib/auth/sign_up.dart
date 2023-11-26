import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../home/activities_screen.dart';
import 'login.dart';


class Signup extends StatefulWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  SignupState createState() => SignupState();
}

class SignupState extends State<Signup> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _emailError = '';
  String _passwordError = '';
  String _signupError = '';

  bool _showPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'EventFlow',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.lightBlue, // Example color
              Colors.blueAccent, // Example accent color
            ],
            tileMode: TileMode.clamp,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: const TextStyle(
                    color: Colors.black,
                  ),
                  errorText: _emailError,
                  filled: true,
                  fillColor: Colors.white,
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _passwordController,
                obscureText: !_showPassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: const TextStyle(
                    color: Colors.black,
                  ),
                  errorText: _passwordError,
                  suffixIcon: IconButton(
                    icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _showPassword = !_showPassword;
                      });
                    },
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    _emailError = '';
                    _passwordError = '';
                    _signupError = '';
                  });

                  String email = _emailController.text;
                  String password = _passwordController.text;

                  if (!_isValidEmail(email)) {
                    setState(() {
                      _emailError = 'Invalid email format';
                    });
                    return;
                  }

                  if (!_isValidPassword(password)) {
                    setState(() {
                      _passwordError = 'Password must be at least 6 characters';
                    });
                    return;
                  }

                  try {
                    await _auth.createUserWithEmailAndPassword(
                      email: email,
                      password: password,
                    );

                    if (context.mounted) {
                      Future.delayed(const Duration(milliseconds: 300), () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ActivitiesScreen(),
                          ),
                        );
                      });
                    }
                  } catch (e) {
                    if (e is FirebaseAuthException) {
                      if (e.code == 'email-already-in-use') {
                        setState(() {
                          _signupError = 'The email address is already in use.';
                        });
                      } else {
                        setState(() {
                          _signupError = 'Sign-up failed: ${e.message}';
                        });
                      }
                    } else {
                      setState(() {
                        _signupError = 'Sign-up failed: $e';
                      });
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.blue,
                  backgroundColor: Colors.white,
                  elevation: 5.0,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text(
                  'S\'inscrire',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 18.0,
                  ),
                ),
              ),
              if (_emailError.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SnackBar(
                    content: Text(
                      _emailError,
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.black,
                  ),
                ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Login(),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                ),
                child: const Text('Vous avez déjà un compte ? Connectez-vous.'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$').hasMatch(email);
  }
}

bool _isValidPassword(String password) {
    return password.length >= 6;
  }
