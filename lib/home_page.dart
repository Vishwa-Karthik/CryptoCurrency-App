// ignore_for_file: prefer_const_constructors

import 'package:crypto_app/app_theme.dart';
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
  bool isDarkMode = AppTheme.isDarkModeEnabled;

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
                title: const Text("Profiles"),
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
                  AppTheme.isDarkModeEnabled = isDarkMode;

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
      body:
          //* Search Bar
          Padding(
        padding: const EdgeInsets.all(18.0),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            // ignore: prefer_const_literals_to_create_immutables
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.black,
                    ),
                    label: Text("COINS", style: GoogleFonts.aBeeZee()),
                    hintText: "Search",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),

              //* List view to all coins
              Expanded(
                child: ListView.builder(
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return coinDetails();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget coinDetails() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: ListTile(
        leading: Image.network(
            "https://assets.coingecko.com/coins/images/1/small/bitcoin.png?1547033579"),
        title: Text(
          "BITCOIN\n BTC",
          style: GoogleFonts.aBeeZee(fontWeight: FontWeight.w800),
        ),
        trailing: RichText(
          textAlign: TextAlign.end,
          text: TextSpan(
            text: "1892772.89\n",
            style: GoogleFonts.aBeeZee(
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
            children: [
              TextSpan(
                text: "39.2%\n",
                style: GoogleFonts.aBeeZee(
                  fontWeight: FontWeight.w800,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
