// Copyright 2021 Free TON Wallet Team

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

// 	http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import "dart:convert" show json;
import "dart:math" show max, min;
import "package:fl_chart/fl_chart.dart"
    show FlGridData, FlLine, FlSpot, LineChart, LineChartBarData, LineChartData;
import 'package:flutter/material.dart';
import 'package:freeton_wallet/app.dart';
import "package:http/http.dart" as http;
import "package:flutter/material.dart"
    show
        AppBar,
        BuildContext,
        Colors,
        Column,
        EdgeInsets,
        Padding,
        Row,
        Scaffold,
        SizedBox,
        State,
        StatefulWidget,
        Text,
        TextButton,
        Widget;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<ChartDataRow> chartData = [];

  void fetchData(String currency1, String currency2) async {
    Uri url = Uri.parse("https://cex.io/api/price_stats/TON/USD");
    print(url.toString());
    http.Response response = await http.post(url,
        body: <String, String>{"lastHours": "24", "maxRespArrSize": "100"});
    List<ChartDataRow> chartDataRows = (json.decode(response.body)
            as List<dynamic>)
        .map((dynamic e) => ChartDataRow.fromJson(e as Map<String, dynamic>))
        .toList();
    this.setState(() {
      chartData = chartDataRows;
    });
  }

  @override
  void initState() {
    super.initState();
    this.fetchData("TON", "USD");
  }

  double get chartMinY => this.chartData.length == 0
      ? 0
      : this.chartData.map((ChartDataRow e) => e.price).reduce(min) * 0.98;

  double get chartMaxY => this.chartData.length == 0
      ? 1
      : this.chartData.map((ChartDataRow e) => e.price).reduce(max) * 1.02;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("TON"),
      ),
      body: Column(
        children: <Widget>[
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                onPressed: () => this.fetchData("TON", "USD"),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 10,
                  ),
                  child: Text("USD"),
                ),
              ),
              TextButton(
                onPressed: () => this.fetchData("TON", "BTC"),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 10,
                  ),
                  child: Text("BTC"),
                ),
              ),
              TextButton(
                onPressed: () => this.fetchData("TON", "ETH"),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 10,
                  ),
                  child: Text("ETH"),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 500,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 10,
              ),
              child: LineChart(
                LineChartData(
                  backgroundColor: Colors.white,
                  minX: this.chartData.length == 0
                      ? 0
                      : this.chartData.first.timestamp,
                  maxX: this.chartData.length == 0
                      ? 1
                      : this.chartData.last.timestamp,
                  minY: this.chartMinY,
                  maxY: this.chartMaxY,
                  lineBarsData: <LineChartBarData>[
                    LineChartBarData(
                      spots: this.chartData.map((e) => e.chartData).toList(),
                      isCurved: true,
                      colors: [
                        Colors.red,
                        Colors.green,
                      ],
                      barWidth: 5,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChartDataRow {
  final double timestamp;
  // final DateTime date;
  final double price;
  factory ChartDataRow.fromJson(Map<String, dynamic> dataRaw) {
    if (dataRaw["tmsp"] == null) {
      throw Exception("Bad server response. No filed 'tmsp'");
    }
    double timestamp = dataRaw["tmsp"];
    // DateTime date = DateTime.fromMillisecondsSinceEpoch(dataRaw["tmsp"] * 1000);
    if (dataRaw["price"] == null) {
      throw Exception("Bad server response. No filed 'price'");
    }
    double price = double.parse(dataRaw["price"].toString());
    return ChartDataRow(timestamp, price);
  }

  FlSpot get chartData => FlSpot(this.timestamp, this.price);

  ChartDataRow(
    this.timestamp,
    // this.date,
    this.price,
  );
}
