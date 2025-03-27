import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sleep_kids_app/ult/tinderCard.dart';

class BedtimeStoriesScreen extends StatefulWidget {
  const BedtimeStoriesScreen({super.key});

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
      extendBodyBehindAppBar: true, // Allows body to extend behind the AppBar
      appBar: AppBar(
      title: const Text("Bedtime Stories", style: TextStyle(color: Colors.white),),
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.purpleAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    ),
      body: Stack( // Stack to place background image behind other content
        children: [
          // Image Background that spans the entire screen
          Positioned.fill(
            child: Image.asset(
              'assets/images/night_sky.jpeg', // Path to your background image
              fit: BoxFit.cover, // Ensure the image covers the whole screen
            ),
          ),
          // Content Layer
          StreamBuilder<QuerySnapshot>(
            stream: _fetchStories(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("No bedtime stories available."));
              }

              // Convert Firestore data into a list of Tindercard objects
              final List<Tindercard> stories = snapshot.data!.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>? ?? {};
                return Tindercard(
                  storyId: doc.id,
                  title: data['title'] ?? "No Title",
                  content: data['context'] ?? "No story available",
                );
              }).toList();

              return Column(
                children: [
                  const SizedBox(height: 100),
                  
                  
                  Expanded(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.75,
                      width: double.infinity, // or just remove width completely if wrapping

                      child: TindercardView(stories: stories),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
