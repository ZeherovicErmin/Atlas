import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class HabitLineChartPage extends StatefulWidget {
  final String habitTitle;
  final Color habitCardColor;

  HabitLineChartPage({
    required this.habitTitle,
    required this.habitCardColor
    });

  @override
  _HabitLineChartPageState createState() => _HabitLineChartPageState();
}

class _HabitLineChartPageState extends State<HabitLineChartPage> {
  //Variables
  late List<FlSpot> lineChartPoints;
  late List<String> pastWeek;
  late bool graphLoading;
  late double minY;
  late double maxY;

  @override
  void initState() {
    super.initState();
    pastWeek = [];
    graphLoading = true;
    minY = 0;
    maxY = 0;
    fetchDataForGraph();
  }

  //Grabs the habit card's data for the last 7 days for the graph
  void fetchDataForGraph() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    final uid = user?.uid;
    DateTime now = DateTime.now();
    List<FlSpot> spots = [];
    pastWeek.clear();

    //Calculates the last 6 days of the week for the x-axis
    for (int i = 6; i >= 0; i--) {
      DateTime day = now.subtract(Duration(days: i));
      String formattedDate = "${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";
      pastWeek.add("${day.month}/${day.day}");

      //Connects to the data in firebase for a specific habit card
      var snapshot = await FirebaseFirestore.instance
        .collection('Habits')
        .doc(uid)
        .collection(formattedDate)
        .doc('habits')
        .get();
      var data = snapshot.data() as Map<String, dynamic>?;

      //Gets the data for the specific habit card tracker
      if (data != null && data.containsKey(widget.habitTitle.toLowerCase())) {
        double value = double.tryParse(data[widget.habitTitle.toLowerCase()]) ?? 0;
        //Makes the data for the dates for the last 7 days of the week
        spots.add(FlSpot((6 - i).toDouble(), value));
      } else {
        //If the date has no data, 0 is given for the value of that date
        spots.add(FlSpot((6 - i).toDouble(), 0));
      }
    }

    //Math for the y-axis values
    double maxVal = spots.map((spot) => spot.y).reduce(max);
    double minVal = spots.map((spot) => spot.y).reduce(min);
    double range = maxVal - minVal;
    maxY = maxVal + range;
    minY = max(0, minVal - range);

    //Sets the states for variables
    setState(() {
      lineChartPoints = spots;
      graphLoading = false;
    });
  }

  //App bar for the graph
  PreferredSize graphAppBar(BuildContext context, String title) {
    return PreferredSize(
    preferredSize: const Size.fromHeight(50),
    child: AppBar(
      centerTitle: true,
      backgroundColor: widget.habitCardColor,
        title: Text(
          title,
          style: const TextStyle(
          fontFamily: 'Open Sans', fontWeight: FontWeight.bold
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: graphAppBar(context, 'Your ${widget.habitTitle.toLowerCase()} for the last 7 Days'),
      body: graphLoading ? const Center(
      child: CircularProgressIndicator()):
      Column(
        children:[
          Expanded(
            child: Stack(
              children:[
                Padding(
                  padding: const EdgeInsets.only(
                    left: 35,
                    right: 40,
                    top: 20,
                  ),
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              if (value % 1 == 0 && value.toInt() < pastWeek.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: Text(
                                    pastWeek[value.toInt()],
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              }
                              return Container();
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 35,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              return Text(value.toInt().toString(),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                )
                              );
                            },
                          ),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      minX: 0,
                      maxX: 6,
                      minY: minY,
                      maxY: maxY,
                      lineBarsData:[
                        LineChartBarData(
                          spots: lineChartPoints,
                          preventCurveOverShooting: true,
                          barWidth: 4,
                          dotData: const FlDotData(show: true),
                          color: widget.habitCardColor,
                          belowBarData: BarAreaData(
                            show: true,
                            color: widget.habitCardColor.withOpacity(.3),
                          ),
                        ),
                      ],
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          tooltipBgColor: Colors.black,
                          getTooltipItems: (List<LineBarSpot> touchedSpots) {
                            return touchedSpots.map((touchedSpot) {
                              const textStyle = TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              );
                              return LineTooltipItem('${touchedSpot.y.toInt()}', textStyle);
                            }).toList();
                          },
                        ),
                        touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {},
                        handleBuiltInTouches: true,
                      ),
                    ),
                  ),
                ),
                //Y-Axis Label
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: 10,
                  child: SizedBox(
                    width: 40,
                    child: RotatedBox(
                      quarterTurns: 3,
                      child: Text(
                        widget.habitTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          //X-Axis Label
          const Padding(
            padding: EdgeInsets.only(bottom: 12.0),
            child: Text(
              'Dates',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}