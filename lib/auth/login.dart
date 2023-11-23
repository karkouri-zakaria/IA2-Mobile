import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/auth/sign_up.dart';
import 'package:project/home/activities_screen.dart';


class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _emailError = '';
  String _passwordError = '';
  String _loginError = '';

  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hanouta'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Login',
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
                  _loginError = '';
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

                try {
                    await _auth.signInWithEmailAndPassword(
                    email: email,
                    password: password,
                  );

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ActivitiesScreen(), // Replace with the actual Home page widget
                    ),
                  );
                } catch (e) {
                  // Handle login errors
                  if (e is FirebaseAuthException) {
                    if (e.code == 'wrong-password') {
                      setState(() {
                        _passwordError = 'Incorrect password';
                      });
                    } else {
                      setState(() {
                        _loginError = 'Login failed: ${e.message}';
                      });
                    }
                  } else {
                    setState(() {
                      _loginError = 'Login failed: $e';
                    });
                  }
                }
              },
              child: const Text('Se connecter'),
            ),
            if (_loginError.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _loginError,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Signup(), // Replace with your sign-up screen widget
                  ),
                );
              },
              child: const Text('Don\'t have an account? Sign Up'),
            ),
          ],
        ),
      ),
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$').hasMatch(email);
  }
}

