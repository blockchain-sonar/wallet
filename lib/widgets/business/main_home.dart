//
// Copyright 2021 Free TON Wallet Team
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// 	http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import "dart:convert" show json;
import "dart:math" show max, min;
import "package:fl_chart/fl_chart.dart"
    show
        BarAreaData,
        FlGridData,
        FlLine,
        FlSpot,
        FlTitlesData,
        LineChart,
        LineChartBarData,
        LineChartData,
        SideTitles;
import "package:flutter/material.dart" show BottomNavigationBar, Colors;
import "package:flutter/widgets.dart"
    show
        BuildContext,
        Color,
        Column,
        Container,
        EdgeInsets,
        Expanded,
        FontWeight,
        Padding,
        SizedBox,
        State,
        StatefulWidget,
        StatelessWidget,
        Text,
        TextStyle,
        Widget;
import "package:http/http.dart" as http;

import "../layout/my_scaffold.dart" show MyScaffold;

class HomeChartWidget extends StatelessWidget {
  final BottomNavigationBar bottomNavigationBar;

  HomeChartWidget(
    this.bottomNavigationBar,
  );

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      appBarTitle: "Home",
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ChartWidget(),
        ),
      ),
      bottomNavigationBar: this.bottomNavigationBar,
    );
  }
}

class ChartWidget extends StatefulWidget {
  @override
  _ChartWidgetWidgetState createState() => _ChartWidgetWidgetState();
}

class _ChartWidgetWidgetState extends State<ChartWidget> {
  List<ChartDataRow> chartData = <ChartDataRow>[];

  String currentPair = "";

  void setPair(String currency1, String currency2) {
    this.currentPair = "${currency1}/${currency2}";
    this.fetchData(currency1, currency2);
  }

  void fetchData(String currency1, String currency2) async {
    Uri url = Uri.parse("https://cex.io").replace(pathSegments: <String>[
      "api",
      "price_stats",
      currency1,
      currency2,
    ]);

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

    this.setPair("TON", "USD");
  }

  double get chartBottomInterval => this.chartData.length == 0
      ? 1
      : (this.chartData.last.timestamp - this.chartData.first.timestamp) / 2;

  double get currentLastPrice =>
      this.chartData.length == 0 ? 0 : this.chartData.last.price;

  double get chartMinY => this.chartData.length == 0
      ? 0
      : this.chartData.map((ChartDataRow e) => e.price).reduce(min) * 0.99;

  double get chartMaxY => this.chartData.length == 0
      ? 1
      : this.chartData.map((ChartDataRow e) => e.price).reduce(max) * 1.01;

  String getDateFromTimestamp(double timestamp) {
    DateTime date =
        DateTime.fromMillisecondsSinceEpoch((timestamp * 1000).toInt());

    String result = "${date.year}";
    result += "-${date.month.toString().padLeft(2, '0')}";
    result += "-${date.day.toString().padLeft(2, '0')}\n";
    result += "${date.hour.toString().padLeft(2, '0')}";
    result += ":${date.minute.toString().padLeft(2, '0')}";
    result += ":${date.second.toString().padLeft(2, '0')}";
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 20,
        ),
        Text(
          "TON Crystal/USD",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue,
            fontSize: 24,
          ),
        ),
        Text(
          this.currentLastPrice.toString(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue,
            fontSize: 36,
          ),
        ),
        SizedBox(
          height: 20,
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.fromLTRB(0, 10, 20, 10),
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
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: SideTitles(
                    showTitles: true,
                    rotateAngle: 90,
                    interval: this.chartBottomInterval,
                    getTitles: (double title) =>
                        this.getDateFromTimestamp(title),
                  ),
                ),
                lineBarsData: <LineChartBarData>[
                  LineChartBarData(
                    isCurved: true,
                    spots: this
                        .chartData
                        .map((ChartDataRow e) => e.chartData)
                        .toList(),
                    colors: <Color>[
                      Colors.blue,
                      Colors.cyan,
                    ],
                    barWidth: 3,
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(
          height: 30,
        ),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceAround,
        //   children: <Widget>[
        //     TextButton(
        //       onPressed: () => this.setPair("TON", "USD"),
        //       child: Padding(
        //         padding: EdgeInsets.symmetric(
        //           vertical: 5,
        //           horizontal: 10,
        //         ),
        //         child: Text(
        //           "TON/USD",
        //           style: TextStyle(
        //             fontWeight: FontWeight.bold,
        //           ),
        //         ),
        //       ),
        //     ),
        //     TextButton(
        //       onPressed: () => this.setPair("TON", "USDT"),
        //       child: Padding(
        //         padding: EdgeInsets.symmetric(
        //           vertical: 5,
        //           horizontal: 10,
        //         ),
        //         child: Text(
        //           "TON/USDT",
        //           style: TextStyle(
        //             fontWeight: FontWeight.bold,
        //           ),
        //         ),
        //       ),
        //     ),
        //   ],
        // ),
        // SizedBox(
        //   height: 20,
        // ),
      ],
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
