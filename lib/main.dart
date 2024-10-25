/// The main entry point for the I'm Bored application.
///
/// This file sets up the root widget of the application and defines the overall
/// theme and initial route.

import 'package:flutter/material.dart';
import 'package:im_bored/pages/splash_screen.dart';

/// The main function that runs the app.
void main() {
  runApp(const MyApp());
}

/// The root widget of the application.
///
/// This widget sets up the MaterialApp with the app's theme and initial route.
class MyApp extends StatelessWidget {
  /// Creates a new instance of [MyApp].
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'I\'m Bored',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SplashScreen(),
    );
  }
}
