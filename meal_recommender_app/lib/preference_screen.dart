import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PreferenceScreen extends StatefulWidget {
  const PreferenceScreen({super.key});

  @override
  PreferenceScreenState createState() => PreferenceScreenState();
}

class PreferenceScreenState extends State<PreferenceScreen> {
  final _allergiesController = TextEditingController();
  final _favoriteFoodsController = TextEditingController();
  final _dislikedFoodsController = TextEditingController();
  String? _userId;
  List<String> _selectedAllergies = [];
  List<String> _selectedFavorites = [];
  List<String> _selectedDislikes = [];

  final List<String> _commonAllergies = ['Peanuts', 'Dairy', 'Gluten', 'Soy', 'Eggs', 'Shellfish', 'Tree Nuts', 'Fish'];
  final List<String> _commonFoods = ['Chicken', 'Beef', 'Pasta', 'Rice', 'Vegetables', 'Fruits', 'Salad', 'Soup'];

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');
    if (userId == null) {
      userId = DateTime.now().millisecondsSinceEpoch.toString();
      await prefs.setString('user_id', userId);
    }
    setState(() {
      _userId = userId;
    });
    print('User ID: $_userId'); // For debugging
  }

  Future<void> _savePreferences() async {
     if (_userId == null) return;

    String allergiesToSend = _selectedAllergies.isNotEmpty || _allergiesController.text.trim().isNotEmpty
      ? [..._selectedAllergies, ..._allergiesController.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty)].join(',')
      : 'None';

  String favoritesToSend = _selectedFavorites.isNotEmpty || _favoriteFoodsController.text.trim().isNotEmpty
      ? [..._selectedFavorites, ..._favoriteFoodsController.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty)].join(',')
      : 'None';

  String dislikesToSend = _selectedDislikes.isNotEmpty || _dislikedFoodsController.text.trim().isNotEmpty
      ? [..._selectedDislikes, ..._dislikedFoodsController.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty)].join(',')
      : 'None';

  final response = await http.post(
    Uri.parse('http://localhost:8000/api/preferences/'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode({
      'user_id': _userId,
      'allergies': allergiesToSend,
      'favorite_foods': favoritesToSend,
      'disliked_foods': dislikesToSend,
    }),
  );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preferences saved!', style: TextStyle(color: Colors.white))),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save preferences.', style: TextStyle(color: Colors.white)), backgroundColor: Colors.redAccent),
      );
      print('Failed to save preferences. Status code: ${response.statusCode}, body: ${response.body}'); // For debugging
    }
  }

  Widget _buildFoodAllergyButtons(String title, List<String> items, List<String> selectedItems, Function(String) onItemToggled) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8.0),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: items.map((item) {
            final isSelected = selectedItems.contains(item);
            return FilterChip(
              label: Text(item, style: TextStyle(color: isSelected ? Colors.black : Colors.white)),
              selected: isSelected,
              onSelected: (bool selected) {
                onItemToggled(item);
              },
              backgroundColor: Colors.blueGrey[800],
              selectedColor: Colors.white,
              checkmarkColor: Colors.black,
              showCheckmark: true,
              labelStyle: TextStyle(color: isSelected ? Colors.black : Colors.white), // Apply style here
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)), // Optional: rounded corners
              side: BorderSide(color: isSelected ? Colors.white : Colors.grey[600]!), // Optional: border
            );
          }).toList(),
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Preferences', style: TextStyle(color: Colors.white, fontSize: 22), textAlign: TextAlign.center),
        backgroundColor: Colors.grey[800],
        centerTitle: true
      ),
      backgroundColor: Colors.grey[800],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildFoodAllergyButtons(
              'Common Allergies',
              _commonAllergies,
              _selectedAllergies,
              (allergy) {
                setState(() {
                  if (_selectedAllergies.contains(allergy)) {
                    _selectedAllergies.remove(allergy);
                  } else {
                    _selectedAllergies.add(allergy);
                  }
                });
              },
            ),
            TextField(
              controller: _allergiesController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Other Allergies (separate by comma)',
                labelStyle: const TextStyle(color: Colors.white),
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey[700]!)),
                focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 24.0),
            _buildFoodAllergyButtons(
              'Favorite Foods',
              _commonFoods,
              _selectedFavorites,
              (food) {
                setState(() {
                  if (_selectedFavorites.contains(food)) {
                    _selectedFavorites.remove(food);
                  } else {
                    _selectedFavorites.add(food);
                  }
                });
              },
            ),
            TextField(
              controller: _favoriteFoodsController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Other Favorite Foods (separate by comma)',
                labelStyle: const TextStyle(color: Colors.white),
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey[600]!)),
                focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 24.0),
            _buildFoodAllergyButtons(
              'Foods You Dislike',
              _commonFoods,
              _selectedDislikes,
              (food) {
                setState(() {
                  if (_selectedDislikes.contains(food)) {
                    _selectedDislikes.remove(food);
                  } else {
                    _selectedDislikes.add(food);
                  }
                });
              },
            ),
            TextField(
              controller: _dislikedFoodsController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Other Foods You Dislike (separate by comma)',
                labelStyle: const TextStyle(color: Colors.white),
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey[600]!)),
                focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: _savePreferences,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey[800],
                foregroundColor: Colors.white,
              ),
              child: const Text('Save Preferences'),
            ),
          ],
        ),
      ),
    );
  }
}