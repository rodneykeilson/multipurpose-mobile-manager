import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:multipurpose_mobile_manager/localizations.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      await _analytics.logLogin();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userEmail', userCredential.user!.email!);

      Navigator.pushReplacementNamed(context, '/pinpage');
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'user-not-found') {
        errorMessage =
            AppLocalizations.of(context).translate('userNotFoundError');
      } else if (e.code == 'wrong-password') {
        errorMessage =
            AppLocalizations.of(context).translate('wrongPasswordError');
      } else {
        errorMessage = AppLocalizations.of(context).translate('genericError');
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(errorMessage)));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xDBEF950E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  height: 100,
                  width: 100,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20),
                Text(
                  AppLocalizations.of(context).translate('loginAccount'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD58B0B),
                  ),
                ),
                const SizedBox(height: 20),
                Container(height: 1.0, width: 250, color: Colors.amber[300]),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  decoration:  InputDecoration(
                    hintText: 'E-mail',
                    prefixIcon: Icon(Icons.email, color: Colors.blueGrey),
                     filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.light
                      ? const Color.fromARGB(255, 255, 255, 255)
                          .withOpacity(0.6)
                      : const Color.fromARGB(255, 0, 0, 0).withOpacity(0.6),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide.none,
                    ),
                     constraints: const BoxConstraints(maxWidth: 300.0),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)
                          .translate('emailEmptyError');
                    } else if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return AppLocalizations.of(context)
                          .translate('emailInvalidError');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    prefixIcon: const Icon(Icons.lock, color: Colors.blueGrey),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: Theme.of(context).brightness == Brightness.light
                        ? const Color.fromARGB(255, 255, 255, 255)
                            .withOpacity(0.6)
                        : const Color.fromARGB(255, 0, 0, 0).withOpacity(0.6),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide.none,
                    ),
                     constraints: const BoxConstraints(maxWidth: 300.0),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)
                          .translate('passwordEmptyError');
                    } else if (value.length < 8) {
                      return AppLocalizations.of(context)
                          .translate('passwordShortError');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/forgotpassword');
                  },
                  child: Text(
                    AppLocalizations.of(context).translate('forgotPassword'),
                    style: const TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE8AE00),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            side: const BorderSide(
                                color: Color(0xFFE8AE00), width: 2),
                          ),
                          elevation: 5,
                          shadowColor: const Color(0xFFD7DA18),
                        ),
                        onPressed: _login,
                        child: Text(
                          AppLocalizations.of(context).translate('login'),
                          style: const TextStyle(color: Colors.white),
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
