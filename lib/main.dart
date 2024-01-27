import 'dart:io';
import 'package:Billtracker/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // add you firebase details here and add you google-services.json file in android/app folder
  Platform.isAndroid
      ? await Firebase.initializeApp(
          options: const FirebaseOptions(
              apiKey: 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
              appId: 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
              messagingSenderId: 'XXXXXXXXXXXXXXXXXXXXXX',
              storageBucket: 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
              projectId: 'XXXXXXXXXXXXXXXXXXXXX'))
      : await Firebase.initializeApp();
  runApp(ProviderScope(child: MyApp()));
}

class ThemeNotifier extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.light;
  SharedPreferences? prefs;

  ThemeNotifier() {
    _init();
  }

  _init() async {
    prefs = await SharedPreferences.getInstance();

    int theme = prefs?.getInt("theme") ?? themeMode.index;
    themeMode = ThemeMode.values[theme];
    notifyListeners();
  }

  setTheme(ThemeMode mode) {
    themeMode = mode;
    notifyListeners();
    prefs?.setInt("theme", mode.index);
  }
}

final themeNotifierProvider =
    ChangeNotifierProvider<ThemeNotifier>((_) => ThemeNotifier());

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeNotifier = ref.watch(themeNotifierProvider);

    return MaterialApp(
      title: 'Flutter Demo',
      themeMode: themeNotifier.themeMode,
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF242248),
      ),
      home: const HomePage(),
    );
  }
}
