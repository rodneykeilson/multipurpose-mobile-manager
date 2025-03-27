import 'package:flutter/material.dart';
import 'package:multipurpose_mobile_manager/aboutapp.dart';
import 'package:multipurpose_mobile_manager/biometricpage.dart';
import 'package:multipurpose_mobile_manager/changepin.dart';
import 'package:multipurpose_mobile_manager/contact.dart';
import 'package:multipurpose_mobile_manager/dashboard.dart';
import 'package:multipurpose_mobile_manager/data_gaji_karyawan_page.dart';
import 'package:multipurpose_mobile_manager/data_karyawan.dart';
import 'package:multipurpose_mobile_manager/feedback.dart';
import 'package:multipurpose_mobile_manager/forgotpassword.dart';
import 'package:multipurpose_mobile_manager/language.dart';
import 'package:multipurpose_mobile_manager/login.dart';
import 'package:multipurpose_mobile_manager/pembukuan_bulanan_page.dart';
import 'package:multipurpose_mobile_manager/persediaan_barang.dart';
import 'package:multipurpose_mobile_manager/profile.dart';
import 'package:multipurpose_mobile_manager/provider/theme_provider.dart';
import 'package:multipurpose_mobile_manager/securitysettings.dart';
import 'package:multipurpose_mobile_manager/settings.dart';
import 'package:multipurpose_mobile_manager/stokbarang.dart';
import 'package:multipurpose_mobile_manager/pin.dart';
import 'package:multipurpose_mobile_manager/register.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// for localizations
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:multipurpose_mobile_manager/localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool? isLoggedIn = prefs.getBool('isLoggedIn');
  String? savedLanguageCode = prefs.getString('languageCode') ?? 'en';

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: MyApp(
        initialRoute: isLoggedIn == true ? '/pinpage' : '/',
        savedLanguageCode: savedLanguageCode,
      ),
    ),
  );

  // jaga-jaga untuk delete jika bermasalah
  final dbPath = await getDatabasesPath();
  await deleteDatabase(join(dbPath, 'multipurpose_mobile_manager.db'));
}

class MyApp extends StatefulWidget {
  final String initialRoute;
  final String savedLanguageCode;
  const MyApp(
      {Key? key, required this.initialRoute, required this.savedLanguageCode})
      : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Locale _locale;

  @override
  void initState() {
    super.initState();
    _locale = Locale(widget.savedLanguageCode); // Load saved language code
  }

  Future<void> _changeLanguage(String languageCode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'languageCode', languageCode); // Save language to preferences
    setState(() {
      _locale = Locale(languageCode);
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      locale: _locale,
      supportedLocales: const [Locale('en'), Locale('id')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      darkTheme: ThemeData.dark(),
      initialRoute: widget.initialRoute,
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      routes: {
        '/': (context) => const HomePage(),
        '/register': (context) => const RegisterPage(),
        '/login': (context) => const Login(),
        '/forgotpassword': (context) => const ForgotPassword(),
        '/pinpage': (context) => const PinPage(),
        '/dashboard': (context) => Dashboard(changeLanguage: _changeLanguage),
        '/stokbarang': (context) => const StokBarang(),
        '/persediaanBarang': (context) => const PersediaanBarangPage(),
        '/pembukuanBulanan': (context) => const PembukuanBulananPage(),
        '/dataKaryawan': (context) => DataKaryawanPage(),
        '/dataGajiKaryawan': (context) => DataGajiKaryawanPage(),
        '/settings': (context) => Settings(changeLanguage: _changeLanguage),
        '/securitysettings': (context) => SecuritySettingsPage(),
        '/changepin': (context) => ChangePinPage(),
        '/feedback': (context) => FeedbackPage(),
        '/profile': (context) => ProfilePage(),
        '/aboutapp': (context) => AboutApp(),
        '/biometric': (context) => BiometricPage(),
        '/contact': (context) => ContactPage(),
        '/language': (context) => LanguageSettingsPage(
              onLanguageChange: _changeLanguage,
            ),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/images/logo.png',
              height: 100,
              width: 100,
              fit: BoxFit.contain,
            ),
            const Text(
              'Multipurpose Mobile Manager',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFD58B0B),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: 1.0,
              width: 250,
              color: const Color(0xFFD7DA18),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE8AE00),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  side: const BorderSide(width: 2, color: Color(0xFFE8AE00)),
                ),
                elevation: 5,
                shadowColor: const Color(0xFFD7DA18),
              ),
              child: Text(
                AppLocalizations.of(context).translate('register'),
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 232, 174, 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  side: const BorderSide(color: Color(0xFFE8AE00), width: 2),
                ),
                elevation: 5,
                shadowColor: const Color(0xFFD7DA18),
              ),
              child: Text(
                AppLocalizations.of(context).translate('login'),
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              height: 1.0,
              width: 250,
              color: const Color.fromARGB(255, 215, 218, 24),
            ),
            const SizedBox(
              height: 20,
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
