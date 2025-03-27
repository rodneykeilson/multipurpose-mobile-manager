import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:multipurpose_mobile_manager/localizations.dart';

class LanguageSettingsPage extends StatefulWidget {
  final Function(String) onLanguageChange;

  const LanguageSettingsPage({Key? key, required this.onLanguageChange})
      : super(key: key);

  @override
  _LanguageSettingsPageState createState() => _LanguageSettingsPageState();
}

class _LanguageSettingsPageState extends State<LanguageSettingsPage> {
  List<Map<String, String>> languages = [
    {'code': 'en', 'name': 'English'},
    {'code': 'id', 'name': 'Bahasa Indonesia'},
  ];

  String? _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _loadLanguagePreference();
  }

  Future<void> _loadLanguagePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('languageCode') ?? 'en';
    });
  }

  Future<void> _changeLanguage(String code) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', code);
    widget.onLanguageChange(code);
    setState(() {
      _selectedLanguage = code;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            isDarkMode ? Colors.grey[850] : const Color(0xDBEF950E),
        title: Text(AppLocalizations.of(context).translate('languageSettings')),
      ),
      body: ListView.builder(
        itemCount: languages.length,
        itemBuilder: (context, index) {
          final language = languages[index];
          return ListTile(
            title: Text(language['name']!),
            trailing: _selectedLanguage == language['code']
                ? const Icon(Icons.check, color: Colors.blue)
                : null,
            onTap: () {
              _changeLanguage(language['code']!);
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }
}
