import 'package:edubot/constants/constants.dart';
import 'package:edubot/providers/chat_provider.dart';
import 'package:edubot/screens/auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
              create: (_) => ChatProvider(),
          )
        ],
        child: MaterialApp(
          title: 'EduBot',
          debugShowCheckedModeBanner: false,
          theme:  ThemeData(
            scaffoldBackgroundColor: BACKGROUND_COLOR,
            appBarTheme: AppBarTheme(
              color: CART_COLOR,
            ),
          ),
          home: const AuthScreen(),
        ),
    );
  }
}
