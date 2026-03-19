import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

// Import path check karjo, jo tamara folder nu naam alag hoy to badaljo
import 'screen/auth/login.dart'; 
import 'screen/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase Success');
  } catch (e) {
    print('Firebase Error: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF3E8FF),
        primaryColor: const Color(0xFF7C3AED),
        colorScheme: const ColorScheme.light(primary: Color(0xFF7C3AED)),
      ),
      
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // 1. Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // 2. User Logged In
          if (snapshot.hasData && snapshot.data != null) {
            return const HomeScreen();
          }

          // 3. Not Logged In (Corrected)
          return LoginPage(); // REMOVED 'const' TO FIX ERROR
        },
      ),
    );
  }
}