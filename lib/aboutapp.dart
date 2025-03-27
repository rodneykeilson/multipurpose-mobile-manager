import 'package:flutter/material.dart';
import 'package:multipurpose_mobile_manager/localizations.dart';

class AboutApp extends StatelessWidget {
  const AboutApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            isDarkMode ? Colors.grey[850] : const Color(0xDBEF950E),
        title: Text(AppLocalizations.of(context).translate('aboutApp')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).translate('aboutAppTitle'),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).translate('aboutAppDescription'),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            BulletPoint(
                text: AppLocalizations.of(context).translate('feature1')),
            BulletPoint(
                text: AppLocalizations.of(context).translate('feature2')),
            BulletPoint(
                text: AppLocalizations.of(context).translate('feature3')),
            BulletPoint(
                text: AppLocalizations.of(context).translate('feature4')),
            BulletPoint(
                text: AppLocalizations.of(context).translate('feature5')),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).translate('aboutAppConclusion'),
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class BulletPoint extends StatelessWidget {
  final String text;

  const BulletPoint({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(fontSize: 16),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
