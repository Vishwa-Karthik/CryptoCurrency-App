// ignore_for_file: prefer_const_constructors

import 'package:crypto_app/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileUpdate extends StatelessWidget {
  ProfileUpdate({super.key});

  // * Text Controllers
  final TextEditingController name = TextEditingController();
  final TextEditingController email = TextEditingController();

  // * Shared Preferences
  Future<void> saveLocal(String key, String value) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    await _prefs.setString(key, value);
  }

  // * Save Function
  void saveDetails() async {
    await saveLocal("name", name.text);
    await saveLocal("email", email.text);
    print("Locally saved");
  }

  //* Dark Mode Concept
  bool isDarkMode = AppTheme.isDarkModeEnabled;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey : Colors.deepPurple.shade100,
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.black38 : Colors.deepPurple,
        title: const Text("Profile "),
      ),
      body: Column(
        // ignore: prefer_const_literals_to_create_immutables
        children: [
          // * Update Name
          myTextField("Name", name),

          // * Update Email
          myTextField("Email", email),

          // * Button
          ElevatedButton(
            onPressed: () {
              saveDetails();
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  Widget myTextField(String title, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: title,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
