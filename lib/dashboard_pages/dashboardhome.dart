import 'package:flutter/material.dart';
import 'package:multipurpose_mobile_manager/localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/gestures.dart';

class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16.0,
                crossAxisSpacing: 16.0,
                children: [
                  DashboardButton(
                    title: AppLocalizations.of(context).translate("inventory"),
                    icon: Icons.inventory,
                    onTap: () => Navigator.pushNamed(context, '/persediaanBarang'),
                  ),
                  DashboardButton(
                    title: AppLocalizations.of(context).translate("monthlyRecords"), 
                    icon: Icons.book,
                    onTap: () => Navigator.pushNamed(context, '/pembukuanBulanan'),
                  ),
                  DashboardButton(
                    title: AppLocalizations.of(context).translate("employeeData"), 
                    icon: Icons.people,
                    onTap: () => Navigator.pushNamed(context, '/dataKaryawan'),
                  ),
                  DashboardButton(
                    title: AppLocalizations.of(context).translate("salaryData"),
                    icon: Icons.monetization_on,
                    onTap: () => Navigator.pushNamed(context, '/dataGajiKaryawan'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text.rich(
              TextSpan(
                text: AppLocalizations.of(context).translate("likeOurApp"),
                children: [
                  TextSpan(
                    text: AppLocalizations.of(context).translate("watchAd"),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        // Show interstitial ad
                        InterstitialAd.load(
                          adUnitId: 'ca-app-pub-3940256099942544/1033173712',
                          request: const AdRequest(),
                          adLoadCallback: InterstitialAdLoadCallback(
                            onAdLoaded: (InterstitialAd ad) {
                              ad.show();
                            },
                            onAdFailedToLoad: (LoadAdError error) {
                              print('InterstitialAd failed to load: $error');
                            },
                          ),
                        );
                      },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const DashboardButton({
    required this.title,
    required this.icon,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.light
              ? const Color.fromARGB(255, 255, 255, 255).withOpacity(0.6)
              : const Color.fromARGB(255, 0, 0, 0).withOpacity(0.6),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: Colors.orange,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
