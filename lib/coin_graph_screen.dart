import 'dart:convert';

import 'package:crypto_app/coin_detail_model.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'app_theme.dart';

class CoinGraphScreen extends StatefulWidget {
  final CoinDetailsModel coinDetailsModel;
  const CoinGraphScreen({super.key, required this.coinDetailsModel});

  @override
  State<CoinGraphScreen> createState() => _CoinGraphScreenState();
}

class _CoinGraphScreenState extends State<CoinGraphScreen> {
  bool isDarkModeEnabled = AppTheme.isDarkModeEnabled;
  bool isLoading = true, isFirstTime = true;
  List<FlSpot> flspotList = [];
  double minX = 0.0, minY = 0.0, maxX = 0.0, maxY = 0.0;

  @override
  void initState() {
    getChartData("1");
    super.initState();
  }

  void getChartData(String days) async {
    if (isFirstTime) {
      isFirstTime = false;
    } else {
      setState(() {
        isLoading = true;
      });
    }
    String apiUrl =
        "https://api.coingecko.com/api/v3/coins/${widget.coinDetailsModel.id}/market_chart?vs_currency=usd&days=$days";
    Uri uri = Uri.parse(apiUrl);
    final responce = await http.get(uri);
    if (responce.statusCode == 200 || responce.statusCode == 201) {
      Map<String, dynamic> result = json.decode(responce.body);
      List rawList = result["prices"];
      List<List> chartData = rawList.map((e) => e as List).toList();
      List<PriceAndTime> priceAndTime = chartData
          .map((e) => PriceAndTime(time: e[0] as int, price: e[1] as double))
          .toList();
      flspotList = [];
      for (var elt in priceAndTime) {
        flspotList.add(FlSpot(elt.time.toDouble(), elt.price));
      }
      priceAndTime.sort((a, b) => a.price.compareTo(b.price));
      minX = priceAndTime.first.time.toDouble();
      minY = priceAndTime.first.price.toDouble();
      maxX = priceAndTime.last.time.toDouble();
      maxY = priceAndTime.last.price.toDouble();
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkModeEnabled ? Colors.black : Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDarkModeEnabled ? Colors.white : Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: isDarkModeEnabled ? Colors.black : Colors.white,
        elevation: 0,
        title: Text(
          widget.coinDetailsModel.name,
          style: TextStyle(
            color: isDarkModeEnabled ? Colors.white : Colors.black,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading == false
          ? SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: RichText(
                        text: TextSpan(
                            text: "${widget.coinDetailsModel.name} Price\n",
                            style: TextStyle(
                              color: isDarkModeEnabled
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 18,
                            ),
                            children: [
                              TextSpan(
                                text:
                                    "Rs.${widget.coinDetailsModel.currentPrice}\n",
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w500,
                                  color: isDarkModeEnabled
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                              TextSpan(
                                text:
                                    "${widget.coinDetailsModel.priceChangePercentage24h}%\n",
                                style: const TextStyle(
                                  color: Colors.red,
                                ),
                              ),
                              TextSpan(
                                text: "Rs.${maxY}",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: isDarkModeEnabled
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              )
                            ]),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 100,
                  ),
                  SizedBox(
                    height: 300,
                    width: double.infinity,
                    child: LineChart(
                      LineChartData(
                        minX: minX,
                        minY: minY,
                        maxX: maxX,
                        maxY: maxY,
                        borderData: FlBorderData(show: false),
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
                            spots: flspotList,
                            dotData: FlDotData(
                              show: false,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            getChartData("1");
                          },
                          child: const Text('1d'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            getChartData("15");
                          },
                          child: const Text('15d'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            getChartData("30");
                          },
                          child: const Text('30d'),
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
