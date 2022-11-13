import 'dart:async';
import 'dart:convert';

import 'package:crypto_app/app_theme.dart';
import 'package:crypto_app/coin_detail_model.dart';
import 'package:crypto_app/coin_graph_screen.dart';
import 'package:crypto_app/update_profile.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String name = "", email = "", age = "";
  bool isDarkMode = AppTheme.isDarkModeEnabled, firstTime = true;
  GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();
  List<CoinDetailsModel> coinList = [];
  late Future<List<CoinDetailsModel>> coinDetailFuture;
  String url =
      "https://api.coingecko.com/api/v3/coins/markets?vs_currency=inr&order=market_cap_desc&per_page=100&page=1&sparkline=false";

  void getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString("name") ?? "";
      email = prefs.getString("email") ?? "";
      age = prefs.getString("age") ?? "";
    });
  }

  Future<List<CoinDetailsModel>> getCoinDetails() async {
    Uri uri = Uri.parse(url);
    final response = await http.get(uri);
    if (response.statusCode == 200 || response.statusCode == 201) {
      List coinsData = json.decode(response.body);
      List<CoinDetailsModel> data = coinsData
          .map(
            (e) => CoinDetailsModel.fromJson(e),
          )
          .toList();
      print(coinsData);
      return data;
    } else {
      return <CoinDetailsModel>[];
    }
  }

  @override
  void initState() {
    getUser();
    coinDetailFuture = getCoinDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            _globalKey.currentState?.openDrawer();
          },
          icon: Icon(
            Icons.menu,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        elevation: 0,
        title: Text(
          "CryptoCurrency App",
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      drawer: Drawer(
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(
                name,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w500,
                ),
              ),
              accountEmail: Text(
                "$email\n Age :$age",
                style: const TextStyle(
                  fontSize: 17,
                ),
              ),
              currentAccountPicture: const Icon(
                Icons.account_circle,
                size: 70,
                color: Colors.white,
              ),
            ),
            ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UpdateProfileScreen(),
                  ),
                );
              },
              title: Text(
                "Update Profile",
                style: TextStyle(
                  fontSize: 17,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              leading: Icon(
                Icons.account_box,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            ListTile(
              onTap: () async {
                SharedPreferences pref = await SharedPreferences.getInstance();
                setState(() {
                  isDarkMode = !isDarkMode;
                });
                AppTheme.isDarkModeEnabled = isDarkMode;
                await pref.setBool("isDarkMode", isDarkMode);
              },
              title: Text(
                isDarkMode ? "Litgth Mode" : "Dark Mode",
                style: TextStyle(
                  fontSize: 17,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              leading: Icon(
                isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            )
          ],
        ),
      ),
      body: SizedBox(
        width: double.infinity,
        child: FutureBuilder(
          future: coinDetailFuture,
          builder: (context, AsyncSnapshot<List<CoinDetailsModel>> snapshot) {
            if (snapshot.hasData) {
              if (firstTime) {
                coinList = snapshot.data!;
                firstTime = false;
              }
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 20,
                    ),
                    child: TextField(
                      onChanged: (value) {
                        List<CoinDetailsModel> searchResult = snapshot.data!
                            .where((element) => element.name.contains(value))
                            .toList();
                        setState(() {
                          coinList = searchResult;
                        });
                      },
                      decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.search,
                            color: isDarkMode ? Colors.white : null,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: isDarkMode ? Colors.white : Colors.grey),
                            borderRadius: BorderRadius.circular(40),
                          ),
                          hintText: "Search for a coin",
                          hintStyle: TextStyle(
                              color: isDarkMode ? Colors.white : null)),
                    ),
                  ),
                  Expanded(
                    child: coinList.isEmpty
                        ? Center(
                            child: Text(
                              "No Coin found",
                              style: TextStyle(
                                  color:
                                      isDarkMode ? Colors.white : Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            itemCount: coinList.length,
                            itemBuilder: (context, index) {
                              CoinDetailsModel coin = coinList[index];
                              return coinsDetails(coin);
                            },
                          ),
                  ),
                ],
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }

  Widget coinsDetails(CoinDetailsModel model) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CoinGraphScreen(
                coinDetailsModel: model,
              ),
            ),
          );
        },
        leading: SizedBox(
          height: 50,
          width: 50,
          child: Image.network(
            model.image,
          ),
        ),
        title: Text(
          "${model.name}\n${model.symbol}",
          style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.white : null),
        ),
        trailing: RichText(
          textAlign: TextAlign.end,
          text: TextSpan(
              text: "Rs.${model.currentPrice}\n",
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
              children: [
                TextSpan(
                  text: "${model.priceChangePercentage24h}%",
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: Colors.red,
                  ),
                )
              ]),
        ),
      ),
    );
  }
}
