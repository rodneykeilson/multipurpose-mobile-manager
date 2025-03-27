import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:multipurpose_mobile_manager/localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);

      Navigator.pushReplacementNamed(context, '/dashboard');
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'weak-password') {
        errorMessage = AppLocalizations.of(context).translate('weakPassword');
      } else if (e.code == 'invalid-email') {
        errorMessage = AppLocalizations.of(context).translate('invalidEmail');
      } else if (e.code == 'email-already-in-use') {
        errorMessage = AppLocalizations.of(context).translate('usedEmail');
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
          padding: const EdgeInsets.symmetric(horizontal: 20),
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
                  AppLocalizations.of(context).translate('registerAccount'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD58B0B),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Divider(color: Colors.amber[300], thickness: 1.0),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context).translate('email'),
                    prefixIcon: const Icon(Icons.email, color: Colors.blueGrey),
                    filled: true,
                    fillColor: Theme.of(context).brightness == Brightness.light
                        ? const Color.fromARGB(255, 255, 255, 255).withOpacity(0.6)
                        : const Color.fromARGB(255, 0, 0, 0).withOpacity(0.6),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppLocalizations.of(context)
                          .translate('emailEmptyError');
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value.trim())) {
                      return AppLocalizations.of(context)
                          .translate('invalidEmail');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_passwordVisible,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context).translate('password'),
                    prefixIcon: const Icon(Icons.lock, color: Colors.blueGrey),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: Theme.of(context).brightness == Brightness.light
                        ? const Color.fromARGB(255, 255, 255, 255).withOpacity(0.6)
                        : const Color.fromARGB(255, 0, 0, 0).withOpacity(0.6),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppLocalizations.of(context)
                          .translate('passwordEmptyError');
                    }
                    if (value.trim().length < 6) {
                      return AppLocalizations.of(context)
                          .translate('weakPassword');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: !_confirmPasswordVisible,
                  decoration: InputDecoration(
                    hintText:
                        AppLocalizations.of(context).translate('confirmPassword'),
                    prefixIcon: const Icon(Icons.lock, color: Colors.blueGrey),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _confirmPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _confirmPasswordVisible = !_confirmPasswordVisible;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: Theme.of(context).brightness == Brightness.light
                        ? const Color.fromARGB(255, 255, 255, 255).withOpacity(0.6)
                        : const Color.fromARGB(255, 0, 0, 0).withOpacity(0.6),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppLocalizations.of(context)
                          .translate('confirmPasswordEmptyError');
                    }
                    if (value.trim() != _passwordController.text.trim()) {
                      return AppLocalizations.of(context)
                          .translate('passwordMismatch');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _register,
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
                        child: Text(
                          AppLocalizations.of(context).translate('register'),
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
