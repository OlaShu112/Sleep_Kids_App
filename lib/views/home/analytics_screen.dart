import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sleep_kids_app/core/models/sleep_data_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sleep_kids_app/services/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  _AnalyticsScreenState createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  late ThemeMode _themeMode;
  final FirebaseService _firebaseService = FirebaseService();

  List<DocumentSnapshot> childProfiles = [];
  String? selectedChildId;
  List<SleepData> sleepDataList = [];

  @override
  void initState() {
    super.initState();
    _loadTheme();
    _fetchSleepData();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    int themeIndex = prefs.getInt('themeModeIndex') ?? 0;
    setState(() {
      _themeMode = ThemeMode.values[themeIndex];
    });
  }

  Future<void> _toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    int newThemeIndex = (_themeMode.index + 1) % 3;
    setState(() {
      _themeMode = ThemeMode.values[newThemeIndex];
    });
    await prefs.setInt('themeModeIndex', newThemeIndex);
  }

  Future<void> _fetchSleepData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('child_profiles')
            .where('guardianId', arrayContains: user.uid)
            .get();

        childProfiles = snapshot.docs;

        if (childProfiles.isNotEmpty) {
          selectedChildId = childProfiles.first.id;
          await _fetchSleepForSelectedChild();
        }

        setState(() {});
      } catch (e) {
        print("\u274C Error fetching children: $e");
      }
    }
  }

  Future<void> _fetchSleepForSelectedChild() async {
    if (selectedChildId == null) return;

    final data = await _firebaseService.getSleepDataByChildId(selectedChildId!);

    setState(() {
      sleepDataList = data;
    });
  }

  List<double> _extractSleepDurations() =>
      sleepDataList.map((e) => e.sleepDuration.toDouble()).toList();

  List<double> _extractAwakenings() => sleepDataList
      .map((e) => e.notes.isEmpty ? 0.0 : double.tryParse(e.notes) ?? 0)
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sleep Analytics"),
        backgroundColor: const Color.fromARGB(255, 35, 104, 174),
        actions: [
          IconButton(
            icon: Icon(
              _themeMode == ThemeMode.dark
                  ? Icons.dark_mode
                  : _themeMode == ThemeMode.light
                      ? Icons.light_mode
                      : Icons.nightlight_round,
              color: Colors.white,
            ),
            onPressed: _toggleTheme,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          const Text(
            "Track and Analyze Your Child's Sleep",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),

          if (childProfiles.isNotEmpty)
            DropdownButton<String>(
              value: selectedChildId,
              isExpanded: true,
              items: childProfiles.map((childDoc) {
                final childName = childDoc['childName'];
                return DropdownMenuItem<String>(
                  value: childDoc.id,
                  child: Text(childName),
                );
              }).toList(),
              onChanged: (value) async {
                setState(() => selectedChildId = value);
                await _fetchSleepForSelectedChild();
              },
            ),

          const SizedBox(height: 10),
          _buildAnalyticsCard(
            title: "Sleep Duration",
            description: "Track total hours of sleep each night.",
            icon: Icons.access_time,
            data: _extractSleepDurations(),
          ),
          _buildAnalyticsCard(
            title: "Sleep Disturbances",
            description: "View trends in awakenings or disturbances.",
            icon: Icons.notifications_active,
            data: _extractAwakenings(),
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

  Widget _buildAnalyticsCard({
    required String title,
    required String description,
    required IconData icon,
    required List<double> data,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.only(bottom: 10),
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
          data.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      "No data available",
                      style: TextStyle(color: Colors.redAccent, fontSize: 16),
                    ),
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
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
                                    toY: data[index],
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
                              leftTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: true)),
                              bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: true)),
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
                                color: Colors.green,
                                belowBarData: BarAreaData(show: false),
                              ),
                            ],
                            gridData: FlGridData(show: true),
                            borderData: FlBorderData(show: true),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: true)),
                              bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: true)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}
