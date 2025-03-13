import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sleep_kids_app/ult/tinderCard.dart';

class BedtimeStoriesScreen extends StatefulWidget {
  const BedtimeStoriesScreen({Key? key}) : super(key: key);

  @override
  _BedtimeStoriesScreenState createState() => _BedtimeStoriesScreenState();
}

class _BedtimeStoriesScreenState extends State<BedtimeStoriesScreen> {
  // Fetch stories from Firestore
  Stream<QuerySnapshot> _fetchStories() {
    return FirebaseFirestore.instance.collection('Stories').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Bedtime Stories",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _fetchStories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(" Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No bedtime stories available."));
          }

          // Convert Firestore data into a list of Tindercard objects
          final List<Tindercard> stories = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>? ?? {};
            return Tindercard(
              storyId: doc.id,
              title: data['description'] ?? "No Title",
              content: data['context'] ?? "No story available",
            );
          }).toList();

          return Column(
            children: [
              const SizedBox(height: 20),
              const Center(
                child:
                    Icon(Icons.menu_book, size: 80, color: Colors.blueAccent),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.75,
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: TindercardView(stories: stories),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
