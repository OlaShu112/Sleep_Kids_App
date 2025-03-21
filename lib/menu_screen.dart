import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';  // To handle the JSON data

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  List<dynamic> _menuItems = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchMenuData();
  }

  // Fetch menu data from the backend
  Future<void> _fetchMenuData() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:8080/menu'));

      if (response.statusCode == 200) {
        // If the server returns a successful response, parse the JSON data
        setState(() {
          _menuItems = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load menu data';
          _isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'An error occurred: $error';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Menu'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(child: Text(_errorMessage))
          : ListView.builder(
        itemCount: _menuItems.length,
        itemBuilder: (context, index) {
          var menuItem = _menuItems[index];
          return ListTile(
            title: Text(menuItem['name']),
            leading: Icon(Icons.menu),
          );
        },
      ),
    );
  }
}
