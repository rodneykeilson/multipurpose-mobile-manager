import 'package:flutter/material.dart';
import 'package:multipurpose_mobile_manager/dashboard_pages/dashboardhome.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:multipurpose_mobile_manager/localizations.dart';
import 'package:multipurpose_mobile_manager/provider/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Dashboard extends StatefulWidget {
  final Function(String) changeLanguage;
  Dashboard({super.key, required this.changeLanguage});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    DashboardHome(),
    // DashboardHome(),
    // DashboardHome(),
    // SearchPage(),
    // DashboardProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return Scaffold(
      key: _key,
      appBar: AppBar(
          title: const Text(
            'Multipurpose Mobile Manager',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor:
              isDarkMode ? Colors.grey[850] : const Color(0xDBEF950E),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(
              Icons.menu,
              color: Colors.white,
            ),
            onPressed: () {
              _key.currentState!.openDrawer();
            },
          ),
          actions: [
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return IconButton(
                  icon: Icon(
                    themeProvider.isDarkMode
                        ? Icons.dark_mode
                        : Icons.light_mode,
                  ),
                  onPressed: () {
                    themeProvider.toggleTheme();
                  },
                );
              },
            ),
          ]),
      drawer: Drawer(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color.fromARGB(255, 48, 47, 47)
            : const Color(0xFF827C7C).withOpacity(0.6),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 100,
                    width: 145,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Manager App',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/contact');
                },
                child: ListTile(
                  leading: const Icon(Icons.contact_mail),
                  title: Text(AppLocalizations.of(context).translate('contact'),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                      )),
                )),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/settings');
              },
              child: ListTile(
                leading: const Icon(Icons.settings),
                title: Text(AppLocalizations.of(context).translate('settings'),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                    )),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/feedback');
              },
              child: ListTile(
                leading: const Icon(Icons.feedback),
                title: Text(AppLocalizations.of(context).translate('feedback'),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                    )),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
    );
  }
}

class MenuButton extends StatelessWidget {
  final String title;
  final IconData icon;

  const MenuButton({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
            color: Colors.amber.shade400,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }
}
