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

  const TindercardView({Key? key, required this.stories}) : super(key: key);

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
              border: Border.fromBorderSide(BorderSide(color: Colors.black)),
              color: Colors.blueAccent,
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

  const FullScreenCard({Key? key, required this.card}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  card.content,
                  style: const TextStyle(fontSize: 20, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
