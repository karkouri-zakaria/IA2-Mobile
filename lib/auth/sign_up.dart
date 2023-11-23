import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _emailError = '';
  String _passwordError = '';
  String _signupError = '';

  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                errorText: _emailError,
              ),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _passwordController,
              obscureText: !_showPassword,
              decoration: InputDecoration(
                labelText: 'Password',
                errorText: _passwordError,
                suffixIcon: IconButton(
                  icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _showPassword = !_showPassword;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () async {
                // Clear previous errors
                setState(() {
                  _emailError = '';
                  _passwordError = '';
                  _signupError = '';
                });

                // Add your email and password format check
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

                  // If successful, navigate to the Home page
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HomePage(), // Replace with the actual Home page widget
                    ),
                  );
                } catch (e) {
                  // Handle sign-up errors
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
              child: const Text('Sign Up'),
            ),
            if (_signupError.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _signupError,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }

  bool _isValidEmail(String email) {
    // You can implement a more sophisticated email validation if needed
    return RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$').hasMatch(email);
  }

  bool _isValidPassword(String password) {
    // You can customize password requirements as needed
    return password.length >= 6;
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: const Center(
        child: Text('Welcome to the Home page!'),
      ),
    );
  }
}
