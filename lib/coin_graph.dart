import 'dart:convert';

import 'package:crypto_app/coin_details.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'app_theme.dart';

class CoinGraphScreen extends StatefulWidget {
  final CoinDetails coinDetails;

  const CoinGraphScreen({super.key, required this.coinDetails});

  @override
  State<CoinGraphScreen> createState() => _CoinGraphScreenState();
}

class _CoinGraphScreenState extends State<CoinGraphScreen> {
  //* Dark Mode initialise
  bool isDarkMode = AppTheme.isDarkModeEnabled;

  bool isLoading = true, isFirstTime = true;

  List<FlSpot> flSpotList = [];

  double minX = 0.0, minY = 0.0, maxX = 0.0, maxY = 0.0;

  @override
  void initState() {
    super.initState();
    getChartData("1");
  }

  //* Get values from api
  void getChartData(String days) async {
    // * loadin the chart
    if (isFirstTime == true) {
      isFirstTime = false;
    } else {
      setState(() {
        isLoading = true;
      });
    }

    String api =
        "https://api.coingecko.com/api/v3/coins/${widget.coinDetails.id}/market_chart?vs_currency=inr&days=$days";

    Uri uri = Uri.parse(api);

    final respone = await http.get(uri);

    if (respone.statusCode == 200 || respone.statusCode == 201) {
      //* "Result" holds whole respone object
      Map<String, dynamic> result = json.decode(respone.body);

      //* "rawList" holds all values of key "prices"
      List rawList = result['prices'];

      //* "chartData" holds list of all data
      List<List> chartData = rawList.map((e) => e as List).toList();

      List<PriceAndTime> priceAndTimeList = chartData
          .map(
            (e) => PriceAndTime(time: e[0] as int, price: e[1] as double),
          )
          .toList();

      flSpotList = [];

      for (var ele in priceAndTimeList) {
        flSpotList.add(
          FlSpot(ele.time.toDouble(), ele.price),
        );
      }
      minX = priceAndTimeList.first.time.toDouble();
      maxX = priceAndTimeList.last.time.toDouble();

      priceAndTimeList.sort(
        ((a, b) => a.price.compareTo(b.price)),
      );

      minY = priceAndTimeList.first.price;
      maxY = priceAndTimeList.last.price;

      setState(() {
        isLoading = false;
      });
    }
  }

  // * beautifying code

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey : Colors.deepPurple.shade100,
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.black38 : Colors.deepPurple,
        title: Text(
          widget.coinDetails.id.toUpperCase(),
          style: GoogleFonts.aBeeZee(
              fontWeight: FontWeight.bold, letterSpacing: 3),
        ),
        centerTitle: true,
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
      body: isLoading == false
          ?
          //* First card in the content
          SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: RichText(
                        text: TextSpan(
                            text: "${widget.coinDetails.name} Price\n",
                            style: GoogleFonts.actor(
                                color: Colors.black, fontSize: 20),
                            children: [
                              TextSpan(
                                text:
                                    "Rs.${widget.coinDetails.currentPrice.toStringAsFixed(2)}\n",
                                style: GoogleFonts.aBeeZee(
                                    color: Colors.black,
                                    fontSize: 25,
                                    fontWeight: FontWeight.w700),
                              ),
                              TextSpan(
                                text:
                                    "${widget.coinDetails.priceChange24h.toStringAsFixed(2)}%\n",
                                style: GoogleFonts.aBeeZee(
                                    color: Colors.red.shade900,
                                    fontSize: 25,
                                    fontWeight: FontWeight.w700),
                              ),
                              TextSpan(
                                text: "Rs.${maxY.toStringAsFixed(2)}\n",
                                style: GoogleFonts.aBeeZee(
                                    color: Colors.black,
                                    fontSize: 25,
                                    fontWeight: FontWeight.w700),
                              ),
                            ]),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 100,
                  ),

                  //* Graph begins here
                  SizedBox(
                    height: 300,
                    width: double.infinity,
                    child: LineChart(
                      LineChartData(
                        minX: minX,
                        minY: minY,
                        maxX: maxX,
                        maxY: maxY,
                        borderData: FlBorderData(
                          show: false,
                        ),
                        titlesData: FlTitlesData(
                          show: false,
                        ),
                        gridData: FlGridData(
                          getDrawingHorizontalLine: (value) {
                            return FlLine(strokeWidth: 0);
                          },
                          getDrawingVerticalLine: (value) {
                            return FlLine(strokeWidth: 0);
                          },
                        ),
                        lineBarsData: [
                          LineChartBarData(
                              color: isDarkMode ? Colors.black : Colors.purple,
                              spots: flSpotList,
                              dotData: FlDotData(show: false)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        //* 1D Button
                        Container(
                          height: 50,
                          width: 90,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25.0),
                            boxShadow: [
                              BoxShadow(
                                  color: isDarkMode
                                      ? Colors.grey.shade600
                                      : Colors.deepPurple,
                                  blurRadius: 5,
                                  spreadRadius: 5),
                            ],
                          ),
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25.0),
                                  ),
                                  backgroundColor: isDarkMode
                                      ? Colors.grey.shade600
                                      : Colors.deepPurple),
                              onPressed: () {
                                getChartData("1");
                              },
                              child: const Text(
                                "1D",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              )),
                        ),

                        //* 15D Button
                        Container(
                          height: 50,
                          width: 90,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25.0),
                            boxShadow: [
                              BoxShadow(
                                  color: isDarkMode
                                      ? Colors.grey.shade600
                                      : Colors.deepPurple,
                                  blurRadius: 3,
                                  spreadRadius: 5),
                            ],
                          ),
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(25.0)),
                                  backgroundColor: isDarkMode
                                      ? Colors.grey.shade600
                                      : Colors.deepPurple),
                              onPressed: () {
                                getChartData("15");
                              },
                              child: const Text(
                                "15D",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20),
                              )),
                        ),

                        //* 30D Button
                        Container(
                          height: 50,
                          width: 90,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25.0),
                            boxShadow: [
                              BoxShadow(
                                  color: isDarkMode
                                      ? Colors.grey.shade600
                                      : Colors.deepPurple,
                                  blurRadius: 5,
                                  spreadRadius: 5),
                            ],
                          ),
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25.0),
                                  ),
                                  backgroundColor: isDarkMode
                                      ? Colors.grey.shade600
                                      : Colors.deepPurple),
                              onPressed: () {
                                getChartData("30");
                              },
                              child: const Text(
                                "30D",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20),
                              )),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}

class PriceAndTime {
  late int time;
  late double price;

  PriceAndTime({required this.time, required this.price});
}
