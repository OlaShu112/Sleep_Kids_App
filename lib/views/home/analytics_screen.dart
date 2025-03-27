import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sleep_kids_app/core/models/sleep_data_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sleep_kids_app/services/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:sleep_kids_app/core/models/goals_model.dart';
import 'package:intl/intl.dart';

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
  Goal? currentGoal;
  Map<DateTime, bool> goalSleepMap = {};
  DateTime? selectedDate;

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

  Future<void> _fetchGoalForSelectedChild() async {
    if (selectedChildId == null) return;
    final snapshot = await FirebaseFirestore.instance
        .collection('goals')
        .where('childId', isEqualTo: selectedChildId)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      setState(() {
        currentGoal = Goal.fromDocument(snapshot.docs.first);
      });
    }
  }

  Future<void> _fetchSleepForChild() async {
    if (selectedChildId == null) return;
    final data = await _firebaseService.getSleepDataByChildId(selectedChildId!);
    await _fetchGoalForSelectedChild();
    setState(() {
      sleepDataList = data;
      _populateGoalSleepMap();
    });
  }

  Future<void> _fetchSleepData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('child_profiles')
          .where('guardianId', arrayContains: user.uid)
          .get();
      childProfiles = snapshot.docs;
      if (childProfiles.isNotEmpty) {
        selectedChildId = childProfiles.first.id;
        await _fetchSleepForChild();
      }
    }
  }

  void _populateGoalSleepMap() {
    goalSleepMap.clear();
    if (currentGoal == null) return;
    double goalDurationInHours = currentGoal!.duration;
    DateTime goalBedtime = currentGoal!.bedtime;

    for (var sleepData in sleepDataList) {
      DateTime date = DateTime(sleepData.bedtime.year, sleepData.bedtime.month,
          sleepData.bedtime.day);
      double sleepDurationInHours = sleepData.sleepDuration / 60.0;
      bool meetsBedtime = sleepData.bedtime.isBefore(goalBedtime);
      bool meetsDuration = sleepDurationInHours >= goalDurationInHours;
      goalSleepMap[date] = meetsBedtime && meetsDuration;
    }
  }

  List<SleepData> get _filteredSleepData {
    if (selectedDate == null) return sleepDataList;
    return sleepDataList.where((data) {
      final date = data.bedtime.toLocal();
      return date.year == selectedDate!.year &&
          date.month == selectedDate!.month &&
          date.day == selectedDate!.day;
    }).toList();
  }

  List<double> _extractSleepDurations() => _filteredSleepData
      .map((e) => double.parse((e.sleepDuration / 3600).toStringAsFixed(2)))
      .toList();

  List<double> _extractAwakenings() => _filteredSleepData
      .map((e) => (e.awakeningsId?.length ?? 0).toDouble())
      .toList();

  Future<void> _showGoalCalendar() async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Goal Calendar'),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TableCalendar(
                  firstDay: DateTime(2020),
                  lastDay: DateTime(2101),
                  focusedDay: DateTime.now(),
                  calendarFormat: CalendarFormat.month,
                  headerStyle: const HeaderStyle(formatButtonVisible: false),
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, date, _) {
                      final normalized =
                          DateTime(date.year, date.month, date.day);
                      if (goalSleepMap.containsKey(normalized)) {
                        final met = goalSleepMap[normalized]!;
                        return _buildDateCell(
                            date.day, met ? Colors.green : Colors.red);
                      }
                      return null;
                    },
                    todayBuilder: (context, date, _) =>
                        _buildDateCell(date.day, Colors.blue),
                  ),
                ),
                const SizedBox(height: 10),
                _buildCalendarSummary(),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDateCell(int day, Color color) {
    return Container(
      margin: const EdgeInsets.all(6.0),
      alignment: Alignment.center,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Text('$day', style: const TextStyle(color: Colors.white)),
    );
  }

  Widget _buildCalendarSummary() {
    final total = goalSleepMap.length;
    final met = goalSleepMap.values.where((v) => v).length;
    final percent = total > 0 ? (met / total * 100).toStringAsFixed(1) : '0';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("📈 Sleep Goal Summary",
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("📅 Days Tracked: $total"),
          Text("✅ Days Met: $met"),
          Text("🎯 Success Rate: $percent%"),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,
      appBar: AppBar(
        title: const Text("Sleep Analytics"),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: Icon(
                _themeMode == ThemeMode.dark
                    ? Icons.dark_mode
                    : Icons.light_mode,
                color: Colors.white),
            onPressed: _toggleTheme,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButton<String>(
            value: selectedChildId,
            isExpanded: true,
            style: const TextStyle(fontSize: 16, color: Colors.black),
            items: childProfiles.map((doc) {
              return DropdownMenuItem(
                value: doc.id,
                child: Text(doc['childName']),
              );
            }).toList(),
            onChanged: (value) async {
              selectedChildId = value;
              await _fetchSleepForChild();
            },
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                selectedDate != null
                    ? "Selected Date: ${DateFormat.yMMMd().format(selectedDate!)}"
                    : "Select a date",
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              IconButton(
                icon:
                    const Icon(Icons.calendar_today, color: Colors.deepPurple),
                onPressed: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() {
                      selectedDate = picked;
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildAnalyticsCard(
            title: "Sleep Duration",
            description: "Track total hours of sleep each night.",
            icon: Icons.bedtime,
            data: _extractSleepDurations(),
            sleepDataList: _filteredSleepData,
            isSleepDuration: true,
          ),
          _buildAnalyticsCard(
            title: "Sleep Disturbances",
            description: "Awakenings during the night.",
            icon: Icons.notifications_active,
            data: _extractAwakenings(),
            sleepDataList: _filteredSleepData,
            isSleepDuration: false,
          ),
          const SizedBox(height: 10),
          _calendarCard(
              title: "Goal Calendar",
              description: "Visualize goals on calendar.",
              onTap: _showGoalCalendar),
        ],
      ),
    );
  }

  Widget _calendarCard(
      {required String title,
      required String description,
      VoidCallback? onTap}) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.calendar_month, color: Colors.blue, size: 36),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                Text(description, style: TextStyle(color: Colors.grey[600])),
              ])
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyticsCard({
    required String title,
    required String description,
    required IconData icon,
    required List<double> data,
    required List<SleepData> sleepDataList,
    required bool isSleepDuration,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        leading: Icon(icon, color: Colors.deepPurple),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Text(description),
          ),
          data.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text("No data available",
                      style: TextStyle(color: Colors.redAccent)),
                )
              : SizedBox(
                  height: 240,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: isSleepDuration
                          ? 24
                          : 20, // ✅ Cap to 5 for awakenings
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          tooltipBgColor: Colors.deepPurple,
                          tooltipMargin: 8,
                          tooltipRoundedRadius: 8,
                          getTooltipItem: (group, _, rod, __) {
                            final index = group.x.toInt();
                            if (index >= sleepDataList.length) return null;
                            final data = sleepDataList[index];
                            return BarTooltipItem(
                              isSleepDuration
                                  ? "🛏️ ${DateFormat.jm().format(data.bedtime)}\n"
                                      "🌞 ${DateFormat.jm().format(data.wakeUpTime)}\n"
                                      "🕒 ${rod.toY.toStringAsFixed(2)} h"
                                  : "😴 ${data.awakeningsId?.length ?? 0} awakenings",
                              const TextStyle(color: Colors.white),
                            );
                          },
                        ),
                      ),
                      barGroups: List.generate(data.length, (i) {
                        return BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: data[i],
                              borderRadius: BorderRadius.circular(8),
                              width: 18,
                              gradient: const LinearGradient(
                                colors: [
                                  Colors.deepPurple,
                                  Colors.purpleAccent
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                          ],
                        );
                      }),
                      titlesData: FlTitlesData(
                        topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, _) {
                              if (isSleepDuration) {
                                return value % 1 == 0
                                    ? Text("${value.toInt()} h",
                                        style: const TextStyle(fontSize: 12))
                                    : const SizedBox();
                              } else {
                                return value >= 1 &&
                                        value <= 5 &&
                                        value % 1 == 0
                                    ? Text("${value.toInt()}",
                                        style: const TextStyle(fontSize: 12))
                                    : const SizedBox();
                              }
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, _) => Text(
                                (value.toInt() + 1).toString(),
                                style: const TextStyle(fontSize: 12)),
                          ),
                        ),
                      ),
                      gridData: FlGridData(show: true),
                      borderData: FlBorderData(show: false),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
