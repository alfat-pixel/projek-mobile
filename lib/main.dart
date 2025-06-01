import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/book_model.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'services/auth_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(BookAdapter());
  await Hive.openBox<Book>('books');

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoggedIn = false;
  bool _checkingLogin = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    bool loggedIn = await AuthService.isLoggedIn();
    setState(() {
      _isLoggedIn = loggedIn;
      _checkingLogin = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingLogin) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'E-Book App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: _isLoggedIn ? const HomeScreen() : const LoginScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        // route lain jika perlu
      },
    );
  }
}
