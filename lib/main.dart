import 'package:chat_app/screens/chat_screen.dart';
import 'package:chat_app/screens/home_screen.dart';
import 'package:chat_app/screens/login_screen.dart';
import 'package:chat_app/screens/profile_screen.dart';
import 'package:chat_app/screens/splash_screen.dart';
import 'package:chat_app/screens/view_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'chat_user.dart';
import 'firebase_options.dart';

late Size mq;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  _initializeFirebase();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyChat',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          elevation: 5,
          iconTheme: IconThemeData(
            color: Colors.black,
          ),
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
          backgroundColor: Colors.white70,
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white70),
        useMaterial3: true,
      ),
      //home: const LoginScreen(),
      initialRoute: '/',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/': (context) => const SplashScreen(),
        '/home': (context) => const HomeScreen(),

        // '/profile': (context) => const ProfileScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == ProfileScreen.routeName) {
          final args = settings.arguments as ChatUser;
          return MaterialPageRoute(
            builder: (context) {
              return ProfileScreen(user: args);
            },
          );
        }

        if (settings.name == ViewProfileScreen.routeName) {
          final args = settings.arguments as ChatUser;
          return MaterialPageRoute(
            builder: (context) {
              return ViewProfileScreen(user: args);
            },
          );
        }

        if (settings.name == ChatScreen.routeName) {
          final args = settings.arguments as ChatUser;
          return MaterialPageRoute(
            builder: (context) {
              return ChatScreen(user: args);
            },
          );
        }
        return null; // Unknown route
      },
      //home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

_initializeFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}
