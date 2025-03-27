import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sleep_kids_app/core/models/sleep_data_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sleep_kids_app/services/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:sleep_kids_app/core/models/goals_model.dart';

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
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('child_profiles')
            .where('guardianId', arrayContains: user.uid)
            .get();

        childProfiles = snapshot.docs;

        if (childProfiles.isNotEmpty) {
          selectedChildId = childProfiles.first.id;
          await _fetchSleepForChild();
        }

        setState(() {});
      } catch (e) {
        print("\u274C Error fetching children: $e");
      }
    }
  }

  void _populateGoalSleepMap() {
    goalSleepMap.clear();

    if (currentGoal == null) return;

    double goalDurationInHours = currentGoal!.duration;
    DateTime goalBedtime = currentGoal!.bedtime;

    for (var sleepData in sleepDataList) {
      DateTime date = DateTime(
        sleepData.bedtime.year,
        sleepData.bedtime.month,
        sleepData.bedtime.day,
      );

      double sleepDurationInHours = sleepData.sleepDuration / 60.0;

      bool meetsBedtime = sleepData.bedtime.hour < goalBedtime.hour ||
          (sleepData.bedtime.hour == goalBedtime.hour &&
              sleepData.bedtime.minute < goalBedtime.minute);

      bool meetsDuration = sleepDurationInHours >= goalDurationInHours;

      bool goalMet = meetsDuration && meetsBedtime;

      goalSleepMap[date] = goalMet;
    }
  }

Future<void> _showGoalCalendar() async {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Goal Calendar'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: SingleChildScrollView( // ✅ Allow scroll if content overflows
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TableCalendar(
                firstDay: DateTime(2020),
                lastDay: DateTime(2101),
                focusedDay: DateTime.now(),
                calendarFormat: CalendarFormat.month,
                daysOfWeekVisible: true,
                headerStyle: const HeaderStyle(formatButtonVisible: false),
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, date, _) {
                    final normalizedDate =
                        DateTime(date.year, date.month, date.day);

                    if (goalSleepMap.containsKey(normalizedDate)) {
                      final goalMet = goalSleepMap[normalizedDate]!;
                      return Container(
                        margin: const EdgeInsets.all(6.0),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: goalMet ? Colors.green : Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${date.day}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }
                    return null;
                  },
                  todayBuilder: (context, date, _) {
                    return Container(
                      margin: const EdgeInsets.all(6.0),
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${date.day}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  },
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


 Widget _buildCalendarSummary() {
  final total = goalSleepMap.length;
  final met = goalSleepMap.values.where((v) => v).length;
  final percent = total > 0 ? (met / total * 100).toStringAsFixed(1) : '0';

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: Colors.grey[100],
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.insert_chart, color: Colors.blue),
            SizedBox(width: 8),
            Text(
              "Sleep Goal Summary",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text("📆 Days Tracked: $total"),
        Text("✅ Days Goal Met: $met"),
        Text("📊 Success Rate: $percent%"),
        const SizedBox(height: 12),
        const Divider(),
        const Text(
          "Legend:",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            _buildLegendDot(color: Colors.green),
            const SizedBox(width: 6),
            Expanded(child: Text("Achived", overflow: TextOverflow.ellipsis)),
            const SizedBox(width: 16),
            _buildLegendDot(color: Colors.red),
            const SizedBox(width: 6),
            Expanded(child: Text("Missed", overflow: TextOverflow.ellipsis)),
            const SizedBox(width: 16),
            _buildLegendDot(color: Colors.blue),
            const SizedBox(width: 6),
            Expanded(child: Text("Today", overflow: TextOverflow.ellipsis)),

          ],
        ),
      ],
    ),
  );
}

Widget _buildLegendDot({required Color color}) {
  return Container(
    width: 14,
    height: 14,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
    ),
  );
}



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
                await _fetchSleepForChild();
              },
            ),
          const SizedBox(height: 10),
          _buildAnalyticsCard(
            title: "Sleep Duration",
            description: "Track total hours of sleep each night.",
            icon: Icons.access_time,
            data:
                sleepDataList.map((e) => e.sleepDuration.toDouble()).toList(),
          ),
          _buildAnalyticsCard(
            title: "Sleep Disturbances",
            description: "View trends in awakenings or disturbances.",
            icon: Icons.notifications_active,
            data: sleepDataList
                .map((e) =>
                    e.notes.isEmpty ? 0.0 : double.tryParse(e.notes) ?? 0)
                .toList(),
          ),
          const SizedBox(height: 10),
          _calendarCard(
            title: "Goal Calendar",
            description: "View Goal in Calendar.",
            onTap: _showGoalCalendar,
          ),
        ],
      ),
    );
  }

  Widget _calendarCard({
    required String title,
    required String description,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.calendar_today, color: Colors.blue, size: 40),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 5),
                    Text(description,
                        style: TextStyle(
                            color: Colors.grey[600], fontSize: 14)),
                  ],
                ),
              ),
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
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.only(bottom: 10),
      child: ExpansionTile(
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        leading: Icon(icon, color: Colors.blue),
        children: <Widget>[
          ListTile(title: Text(description)),
          data.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      "No data available",
                      style:
                          TextStyle(color: Colors.redAccent, fontSize: 16),
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
                                  return FlSpot(
                                      index.toDouble(), data[index]);
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