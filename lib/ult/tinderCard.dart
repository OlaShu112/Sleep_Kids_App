import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

class Tindercard {
  final String storyId;
  final String title;
  final String content;

  Tindercard({
    required this.storyId,
    required this.title,
    required this.content,
  });
}

class TindercardView extends StatelessWidget {
  final List<Tindercard> stories; // ✅ Accept stories as a parameter

  const TindercardView({super.key, required this.stories});

  @override
  Widget build(BuildContext context) {
    if (stories.isEmpty) {
      return const Center(
        child: Text(
          "⚠️ No stories available",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      );
    }

    return CardSwiper(
      cardsCount: stories.length,
      cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
        return GestureDetector(
          onTap: () => _openFullScreenCard(context, stories[index]),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.deepPurpleAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: Text(
                stories[index].title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      },
      allowedSwipeDirection:
          const AllowedSwipeDirection.only(left: true, right: true),
    );
  }

  void _openFullScreenCard(BuildContext context, Tindercard card) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: animation,
              child: FullScreenCard(card: card),
            ),
          );
        },
      ),
    );
  }
}

class FullScreenCard extends StatelessWidget {
  final Tindercard card;

  const FullScreenCard({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Text(
                  card.title,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  card.content,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
