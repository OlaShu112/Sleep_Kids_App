import 'package:flutter/material.dart';
import 'package:sleep_kids_app/ult/tinderCard.dart';

class BedtimeStoriesScreen extends StatefulWidget {
  const BedtimeStoriesScreen({Key? key}) : super(key: key);

  @override
  _BedtimeStoriesScreenState createState() => _BedtimeStoriesScreenState();
}

class _BedtimeStoriesScreenState extends State<BedtimeStoriesScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Bedtime Stories",
      style: TextStyle(

        fontWeight: FontWeight.bold
      ),)),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          const Center(
              child: Icon(Icons.menu_book, size: 80, color: Colors.blueAccent)),
          Center(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.75,
              width: MediaQuery.of(context).size.width * 0.9,
              child: TindercardView(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryCard(
      {required String title,
      required String description,
      required IconData icon}) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.only(bottom: 16),
      child: ListTile(
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        leading: Icon(icon, color: Colors.blue),
      ),
    );
  }
}
