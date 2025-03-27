import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:multipurpose_mobile_manager/language.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:multipurpose_mobile_manager/aboutapp.dart';
import 'package:multipurpose_mobile_manager/securitysettings.dart';
import 'package:multipurpose_mobile_manager/localizations.dart';

class Settings extends StatelessWidget {
  final Function(String)? changeLanguage;

  const Settings({Key? key, this.changeLanguage}) : super(key: key);

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).translate('chooseLanguage')),
          actions: [
            TextButton(
              onPressed: () {
                if (changeLanguage != null) {
                  changeLanguage!('en');
                }
                Navigator.pop(context);
              },
              child: const Text('English'),
            ),
            TextButton(
              onPressed: () {
                if (changeLanguage != null) {
                  changeLanguage!('id');
                }
                Navigator.pop(context);
              },
              child: const Text('Bahasa Indonesia'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            isDarkMode ? Colors.grey[850] : const Color(0xDBEF950E),
        title: Text(AppLocalizations.of(context).translate('settings')),
      ),
      body: ListView(
        children: [
          // ListTile(
          //   leading: const Icon(Icons.security),
          //   title: Text(AppLocalizations.of(context).translate('securitySettings')),
          //   onTap: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (context) => SecuritySettingsPage()),
          //     );
          //   },
          // ),
          ListTile(
            leading: const Icon(Icons.info),
            title: Text(AppLocalizations.of(context).translate('aboutApp')),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AboutApp()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(AppLocalizations.of(context).translate('languageSettings')),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LanguageSettingsPage(
                    onLanguageChange: (String newLanguage) {
                      changeLanguage?.call(newLanguage);
                    },
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: Text(AppLocalizations.of(context).translate('logout')),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }
}
