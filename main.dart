import 'package:flutter/material.dart';
import 'package:not_pad/UI/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;

void main() {
  // Initialize database factory for desktop platforms
  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.macOS)) {
    sqfliteFfiInit(); // Initialize FFI for SQLite
    databaseFactory = databaseFactoryFfi; // Set the FFI database factory
  }

  runApp(const NotePad());
}
class NotePad extends StatefulWidget {
  const NotePad({super.key});

  @override
  State<NotePad> createState() => _NotePadState();
}

class _NotePadState extends State<NotePad> {

  ThemeMode _themeMode=ThemeMode.light;
  Future<void>loadThemepreferences()async{
    SharedPreferences pref=await SharedPreferences.getInstance();
    bool isDarkMode=pref.getBool('isDarMode')??false;
    setState(() {
      _themeMode=isDarkMode?ThemeMode.dark:ThemeMode.light;
    });
  }
  Future<void>toggleTheme(bool isDarkMode)async{
    SharedPreferences pref=await SharedPreferences.getInstance();
    setState(() {
      _themeMode=isDarkMode?ThemeMode.dark:ThemeMode.light;
      pref.setBool('isDarkMode', isDarkMode);
    });
  }
  @override
  // ignore: override_on_non_overriding_member
  void initstate(){
    super.initState();
    loadThemepreferences();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Note App",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey),
        useMaterial3: true,
        brightness:Brightness.light,  
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      themeMode:_themeMode,
       home: Home(onThemeChanged: toggleTheme),
    );
  }
}
