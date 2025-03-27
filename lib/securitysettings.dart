import 'package:flutter/material.dart';
import 'package:multipurpose_mobile_manager/biometricpage.dart';
import 'package:multipurpose_mobile_manager/localizations.dart';
import 'package:multipurpose_mobile_manager/pin.dart';

class SecuritySettingsPage extends StatefulWidget {
  @override
  _SecuritySettingsPageState createState() => _SecuritySettingsPageState();
}

class _SecuritySettingsPageState extends State<SecuritySettingsPage> {
  bool isTwoFactorAuthEnabled = false;
  bool isLoginNotificationEnabled = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            isDarkMode ? Colors.grey[850] : const Color(0xDBEF950E),
        title: Text(AppLocalizations.of(context).translate('securitySettings')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Fingerprint/Face ID Login
            ListTile(
              title: Text(AppLocalizations.of(context).translate('biometricAuthentication')),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BiometricPage()),
                );
              },
            ),

            Divider(),

            // Change PIN
            ListTile(
              title: Text(AppLocalizations.of(context).translate('changePIN')),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PinPage()),
                );
              },
            ),

            Divider(),

            // Two-Factor Authentication
            SwitchListTile(
              title: Text(AppLocalizations.of(context).translate('enableTwoFactorAuth')),
              subtitle: Text(AppLocalizations.of(context).translate('twoFactorAuthDescription')),
              value: isTwoFactorAuthEnabled,
              onChanged: (value) {
                setState(() {
                  isTwoFactorAuthEnabled = value;
                });
                if (value) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(AppLocalizations.of(context).translate('twoFactorAuthEnabled'))),
                  );
                }
              },
            ),

            Divider(),

            // Login Notification
            SwitchListTile(
              title: Text(AppLocalizations.of(context).translate('enableLoginNotifications')),
              subtitle: Text(AppLocalizations.of(context).translate('loginNotificationsDescription')),
              value: isLoginNotificationEnabled,
              onChanged: (value) {
                setState(() {
                  isLoginNotificationEnabled = value;
                });
              },
            ),

            Divider(),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(AppLocalizations.of(context).translate('securitySettingsSaved'))),
                );
              },
              child: Text(AppLocalizations.of(context).translate('saveChanges')),
            ),
          ],
        ),
      ),
    );
  }
}
