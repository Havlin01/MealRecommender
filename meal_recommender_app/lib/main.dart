import 'package:flutter/material.dart';
import 'package:meal_recommender_app/recommendation_screen.dart';
import 'preference_screen.dart'; // Import your preference screen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meal Recommender',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey, // Example primary color
        scaffoldBackgroundColor: Colors.grey[900], // Light gray background
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[800], // Darker gray app bar
          titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20), // White app bar title
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white), // Default white text color
          labelLarge: TextStyle(color: Colors.white), // White text for labels
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: const TextStyle(color: Colors.white),
          hintStyle: const TextStyle(color: Colors.grey),
          border: const OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey[600]!)),
          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueGrey[800], // Darker gray button background
            foregroundColor: Colors.white, // White button text
          ),
        ),
        // Removed filterChipTheme here
      ),
      home: const RecommendationScreen(), // Set PreferenceScreen as the starting screen
    );
  }
}