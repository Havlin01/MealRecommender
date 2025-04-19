import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RecommendationScreen extends StatefulWidget {
  const RecommendationScreen({super.key});

  @override
  RecommendationScreenState createState() => RecommendationScreenState();
}

class RecommendationScreenState extends State<RecommendationScreen> {
  String? _userId;
  String _recommendation = 'Tap the button for a recommendation!';
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
    if (_userId == null) {
      // Consider navigating back to the preference screen if no user ID is found
      print('No User ID found!');
    }
  }

  Future<void> _getRecommendation() async {
    if (_userId == null) return;

    setState(() {
      _isLoading = true;
      _recommendation = 'Loading recommendation...';
    });

    final response = await http.get(
      Uri.parse('http://localhost:8000/api/recommendation/$_userId/'), // Replace with your Django URL
    );

    setState(() {
      _isLoading = false;
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        _recommendation = responseData['recommendation'];
      } else {
        _recommendation = 'Failed to get recommendation.';
        print('Failed to get recommendation. Status code: ${response.statusCode}, body: ${response.body}');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Recommendation', style: TextStyle(fontSize: 22, color: Colors.white)),
        backgroundColor: Colors.grey[800],
        centerTitle: true,
      ),
      backgroundColor: Colors.grey[800],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                _recommendation,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: _isLoading ? null : _getRecommendation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey[800],
                  foregroundColor: Colors.white,
                ),
                child: Text(_isLoading ? 'Loading...' : 'Get Recommendation'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}