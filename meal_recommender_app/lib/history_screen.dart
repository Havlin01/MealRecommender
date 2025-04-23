import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart'; // For formatting timestamps

class HistoryScreen extends StatefulWidget {
  final String? userId;

  const HistoryScreen({super.key, this.userId});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String? _userId;
  List<dynamic> _history = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserIdAndHistory();
    _userId = widget.userId; // Get the userId passed to the StatefulWidget
  }

  Future<void> _loadUserIdAndHistory() async {
    setState(() {
      _isLoading = true;
      _history = [];
      print('Loading history for user ID: $_userId'); // Check _userId here
    });

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('user_id');
    print('Retrieved user ID from prefs: $_userId'); // Verify retrieved ID

    if (_userId != null) {
      final String historyUrl = 'http://localhost:8000/api/history/$_userId/';
      print('Requesting history from: $historyUrl'); // Log the exact URL

      final response = await http.get(Uri.parse(historyUrl));
      print('HTTP Response Status Code: ${response.statusCode}');
      print('HTTP Response Body: ${response.body}');

      setState(() {
        _isLoading = false;
        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          _history = responseData['history'];
          print('History loaded successfully: $_history');
        } else {
          print(
            'Failed to load history. Status code: ${response.statusCode}, body: ${response.body}',
          );
          // Optionally show an error message to the user
        }
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      print('No User ID found, cannot load history.');
      // Optionally navigate back to preference screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recommendation History')),
      backgroundColor: Colors.grey[600],
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
              : _history.isEmpty
              ? const Center(
                child: Text(
                  'No recommendations yet.',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              )
              : ListView.builder(
                itemCount: _history.length,
                itemBuilder: (context, index) {
                  final historyItem = _history[index];
                  final recommendation = historyItem['recommendation'];
                  final timestamp = DateTime.parse(historyItem['timestamp']);
                  final formattedTimestamp = DateFormat(
                    'yyyy-MM-dd HH:mm:ss',
                  ).format(timestamp.toLocal());

                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text(
                        recommendation,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      subtitle: Text(
                        'Recommended on $formattedTimestamp',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      tileColor: Colors.blueGrey[800],
                    ),
                  );
                },
              ),
    );
  }
}
