import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:stock_tracking_firebase/pages/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:stock_tracking_firebase/pages/mainPage.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initLocalStorage();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    var email = localStorage.getItem("email");
    Widget content = const Mainpage();
    if (email == null) {
      content = const LoginScreen();
    }
    return MaterialApp(
      title: 'BR_ST Uygulamasına Hoşgeldiniz',
      theme: ThemeData(
        primaryColor: Colors.yellow[700], // Ana Renk: Sarı
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.yellow[700]!,
          brightness: Brightness.light,
          secondary: Colors.lightGreen[400]!, // Vurgu Rengi: Açık Yeşil
          surface: Colors.grey[200]!, // Yüzey Rengi: Açık Gri
        ),
        scaffoldBackgroundColor: Colors.white, // Arka Plan Rengi: Beyaz
      ),
      home: content,
    );
  }
}
