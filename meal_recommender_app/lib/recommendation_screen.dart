import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'history_screen.dart'; // Import the HistoryScreen
import 'preference_screen.dart';

class RecommendationScreen extends StatefulWidget {
  const RecommendationScreen({super.key});

  @override
  RecommendationScreenState createState() => RecommendationScreenState();
}

class RecommendationScreenState extends State<RecommendationScreen> {
  String? _userId;
  String _recommendation = 'Click below to get a recommendation.';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString('user_id');
    });
  }

  Future<void> _getRecommendation() async {
    if (_userId == null) return;

    setState(() {
      _isLoading = true;
      _recommendation = 'Loading recommendation...';
    });

    final response = await http.get(
      Uri.parse('http://localhost:8000/api/recommendation/$_userId/'),
    );

    setState(() {
      _isLoading = false;
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        _recommendation = responseData['recommendation'];
      } else {
        _recommendation = 'Failed to get recommendation.';
        print(
          'Failed to get recommendation. Status code: ${response.statusCode}, body: ${response.body}',
        );
      }
    });
  }

  void _navigateToHistoryScreen() {
    if (_userId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HistoryScreen()),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User ID not found.')));
    }
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text(
        'Your Recommendation',
        style: TextStyle(color: Colors.white),
      ),
    ),
    backgroundColor: Colors.grey[600],
    body: SingleChildScrollView( // Wrap the Center widget with SingleChildScrollView
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (_isLoading)
                const CircularProgressIndicator(color: Colors.white)
              else
                Text(
                  _recommendation,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _getRecommendation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey[800],
                  foregroundColor: Colors.white,
                ),
                child: const Text('Get New Recommendation'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HistoryScreen(userId: _userId)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey[800],
                  foregroundColor: Colors.white,
                ),
                child: const Text('View History'),
              ),
            ],
          ),
        ),
      ),
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PreferenceScreen()),
        );
      },
      backgroundColor: Colors.grey[600],
      child: const Icon(Icons.settings, color: Colors.white),
    ),
  );
}
}
