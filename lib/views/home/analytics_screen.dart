import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart'; // Import fl_chart for bar charts

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  _AnalyticsScreenState createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  late ThemeMode _themeMode; // Stores current theme mode

  @override
  void initState() {
    super.initState();
    _loadTheme(); // Load saved theme when the screen initializes
  }

  // Load theme mode from SharedPreferences
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    int themeIndex = prefs.getInt('themeModeIndex') ?? 0;
    setState(() {
      _themeMode = ThemeMode.values[themeIndex];
    });
  }

  // Toggle theme and save preference
  Future<void> _toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    int newThemeIndex = (_themeMode.index + 1) % 3; // Toggle between 3 modes
    setState(() {
      _themeMode = ThemeMode.values[newThemeIndex];
    });
    await prefs.setInt('themeModeIndex', newThemeIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sleep Analytics"),
        backgroundColor: const Color.fromARGB(255, 58, 81, 183),
        actions: [
          IconButton(
            icon: Icon(
              _themeMode == ThemeMode.dark
                  ? Icons.dark_mode
                  : _themeMode == ThemeMode.light
                      ? Icons.light_mode
                      : Icons
                          .nightlight_round, // Use a unique icon for black mode
              color: Colors.white,
            ),
            onPressed: _toggleTheme, // Call theme toggle function
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Track and Analyze Your Child's Sleep",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          _buildAnalyticsCard(
            title: "Sleep Duration",
            description: "Track total hours of sleep each night.",
            icon: Icons.access_time,
            data: [4, 5, 6, 7, 8, 9, 6, 7], // Example data for sleep duration
          ),
          _buildAnalyticsCard(
            title: "Sleep Quality",
            description: "Analyze sleep quality using sleep scores.",
            icon: Icons.star_rate,
            data: [3, 4, 5, 2, 4, 3, 5, 4], // Example data for sleep quality
          ),
          _buildAnalyticsCard(
            title: "Sleep Consistency",
            description: "Monitor bedtime and wake-up consistency.",
            icon: Icons.schedule,
            data: [
              7,
              6,
              6,
              7,
              8,
              7,
              6,
              8
            ], // Example data for sleep consistency
          ),
          _buildAnalyticsCard(
            title: "Sleep Disturbances",
            description: "View trends in awakenings or disturbances.",
            icon: Icons.notifications_active,
            data: [
              1,
              2,
              1,
              3,
              2,
              1,
              2,
              1
            ], // Example data for sleep disturbances
          ),
          const SizedBox(height: 20),
          const Center(
            child: Icon(
              Icons.bar_chart,
              size: 80,
              color: Color.fromARGB(255, 71, 58, 183),
            ),
          ),
        ],
      ),
    );
  }

  // Method to build a card with an expandable chart and description
  Widget _buildAnalyticsCard({
    required String title,
    required String description,
    required IconData icon,
    required List<double> data,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: Icon(icon, color: Colors.blue),
        children: <Widget>[
          ListTile(
            title: Text(description),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceBetween,
                  barGroups: List.generate(data.length, (index) {
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: data[index], // Updated from `y` to `toY`
                          gradient: const LinearGradient(
                            colors: [Colors.blue, Colors.lightBlue],
                          ),
                          width: 16,
                          borderRadius: BorderRadius.zero,
                        ),
                      ],
                      showingTooltipIndicators: [0],
                    );
                  }),
                  titlesData: FlTitlesData(
                    leftTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: true)),
                    bottomTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: true)),
                  ),
                  gridData: FlGridData(show: true),
                  borderData: FlBorderData(show: true),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(data.length, (index) {
                        return FlSpot(index.toDouble(), data[index]);
                      }),
                      isCurved: true,
                      color: Colors.green, // `colors` replaced with `color`
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                  gridData: FlGridData(show: true),
                  borderData: FlBorderData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: true)),
                    bottomTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: true)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  } // Ensure this closing bracket is here!
}
