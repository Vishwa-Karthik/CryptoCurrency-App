// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'update_profile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String name = "", email = "";

  //* Dark Mode initialise
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    getUserDetails();
  }

  void getUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      name = prefs.getString('name') ?? "";
      email = prefs.getString('email') ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey : Colors.deepPurple.shade100,
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.black38 : Colors.deepPurple,
        title: const Text("CRYPTO APP"),
        centerTitle: true,
      ),
      drawer: Drawer(
        backgroundColor: Colors.deepPurple.shade200,
        child: Column(
            // ignore: prefer_const_literals_to_create_immutables
            children: [
              // * Drawer Header
              UserAccountsDrawerHeader(
                accountName: Text(
                  name,
                  style: GoogleFonts.actor(
                      fontWeight: FontWeight.bold, letterSpacing: 2),
                ),
                accountEmail: Text(email),
                currentAccountPicture: Icon(
                  Icons.account_circle_rounded,
                  size: 80,
                ),
                currentAccountPictureSize: Size.square(55),
              ),

              // * Drawer Tiles
              ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileUpdate(),
                    ),
                  );
                },
                leading: Icon(
                  Icons.card_membership,
                  color: Colors.black,
                ),
                title: const Text("Profile"),
              ),
              ListTile(
                onTap: () async {
                  // * Shared Preferences to save theme data locally
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();

                  //* Toggle Dark Mode
                  setState(() {
                    isDarkMode = !isDarkMode;
                  });

                  //* Save local theme data
                  await prefs.setBool("isDarkMode", isDarkMode);
                },
                leading: Icon(
                  isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  color: Colors.black,
                ),
                title: Text(isDarkMode ? "Light Mode" : "Dark Mode"),
              ),
            ]),
      ),
    );
  }
}
