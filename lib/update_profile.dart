// ignore_for_file: prefer_const_constructors, must_be_immutable

import 'package:crypto_app/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileUpdate extends StatefulWidget {
  ProfileUpdate({super.key});

  @override
  State<ProfileUpdate> createState() => _ProfileUpdateState();
}

class _ProfileUpdateState extends State<ProfileUpdate> {
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
        actions: [
          IconButton(
              onPressed: () async {
                // * Shared Preferences to save theme data locally
                SharedPreferences prefs = await SharedPreferences.getInstance();

                //* Toggle Dark Mode
                setState(() {
                  isDarkMode = !isDarkMode;
                });
                AppTheme.isDarkModeEnabled = isDarkMode;

                //* Save local theme data
                await prefs.setBool("isDarkMode", isDarkMode);
              },
              icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode)),
        ],
      ),
      body: Column(
        // ignore: prefer_const_literals_to_create_immutables
        children: [
          // * Update Name
          myTextField("Name", name),

          // * Update Email
          myTextField("Email", email),

          // * Button
          Container(
            height: 50,
            width: 110,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25.0),
              boxShadow: [
                BoxShadow(
                    color:
                        isDarkMode ? Colors.grey.shade600 : Colors.deepPurple,
                    blurRadius: 5,
                    spreadRadius: 5),
              ],
            ),
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    backgroundColor:
                        isDarkMode ? Colors.grey.shade600 : Colors.deepPurple),
                onPressed: () {
                  saveDetails();
                },
                child: const Text(
                  "UPDATE",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                )),
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
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(19),
            borderSide: const BorderSide(color: Colors.black54),
          ),
          hintText: title,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
