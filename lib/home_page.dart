// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:crypto_app/app_theme.dart';
import 'package:crypto_app/coin_details.dart';
import 'package:crypto_app/coin_graph.dart';
import 'package:crypto_app/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
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

  //* List to handle search function
  List<CoinDetails> coinDetailList = [];

  late Future<List<CoinDetails>> coinDetailFuture;

  //* Null search funtion
  bool isFirstTimeAcsess = true;

  // * Init method to call GetUserDetails from shared preferences
  @override
  void initState() {
    super.initState();
    getUserDetails();
    coinDetailFuture = getCoinDetails();
  }

// * fetch details from Shared preferences and var them.
  void getUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      name = prefs.getString('name') ?? "";
      email = prefs.getString('email') ?? "";
    });
  }

//* do a HTTP request to fetch all details
  Future<List<CoinDetails>> getCoinDetails() async {
    Uri uri = Uri.parse(api);
    final response = await http.get(uri);

    if (response.statusCode == 200 || response.statusCode == 201) {
      // * fetch all details into one variable, here coinsData
      List coinsData = json.decode(response.body);

      //* store em in viewModel of
      List<CoinDetails> data =
          coinsData.map((e) => CoinDetails.fromJson(e)).toList();

      return data;
    } else {
      return <CoinDetails>[];
    }
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
      body: FutureBuilder(
          future: coinDetailFuture,
          builder: (context, AsyncSnapshot<List<CoinDetails>> snapshot) {
            if (snapshot.hasData) {
              if (isFirstTimeAcsess) {
                coinDetailList = snapshot.data!;
                isFirstTimeAcsess = false;
              }

              return Column(
                children: [
                  //* Search Bar
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: TextField(
                      onChanged: (query) {
                        List<CoinDetails> searchRes =
                            snapshot.data!.where((element) {
                          String coinName = element.name;
                          bool isItemFound = coinName.contains(query);

                          return isItemFound;
                        }).toList();
                        setState(() {
                          coinDetailList = searchRes;
                        });
                      },
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.black,
                        ),
                        label: Text("COINS", style: GoogleFonts.aBeeZee()),
                        hintText: "Search Coins",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),

                  //* List view to all coins
                  Expanded(
                    child: coinDetailList.isEmpty
                        ? Center(
                            child: const Text("No Coins found"),
                          )
                        : ListView.builder(
                            itemCount: coinDetailList.length,
                            itemBuilder: (context, index) {
                              return coinDetailTile(coinDetailList[index]);
                            },
                          ),
                  )
                ],
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    );
  }

  Widget coinDetailTile(CoinDetails model) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CoinGraphScreen(
                coinDetails: model,
              ),
            ),
          );
        },
        leading:
            SizedBox(height: 50, width: 50, child: Image.network(model.image)),
        title: Text(
          "${model.name}\n ${model.symbol}",
          style: GoogleFonts.aBeeZee(fontWeight: FontWeight.w800),
        ),
        trailing: RichText(
          textAlign: TextAlign.end,
          text: TextSpan(
            text: "${model.currentPrice}\n",
            style: GoogleFonts.aBeeZee(
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
            children: [
              TextSpan(
                text: "${model.priceChange24h}%\n",
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
