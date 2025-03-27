import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class BiometricPage extends StatelessWidget {
  final LocalAuthentication auth = LocalAuthentication();

  Future<void> _authenticate(BuildContext context) async {
    try {
      final bool authenticated = await auth.authenticate(
        localizedReason: 'Authenticate to access the app',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (authenticated) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Authentication failed!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Biometric Login')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _authenticate(context),
          child: Text('Login with Biometrics'),
        ),
      ),
    );
  }
}
