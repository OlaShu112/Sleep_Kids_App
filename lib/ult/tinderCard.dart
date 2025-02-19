import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

class Tindercard {
  final String title;
  final String content;
  final Color boxColor;

  Tindercard({
    required this.title,
    required this.content,
    required this.boxColor,
  });
}

class TindercardView extends StatelessWidget {
  final List<Tindercard> cards = [
    Tindercard(
      title: "Card 1",
      content: "This is the description for Card 1",
      boxColor: Colors.blueGrey,
    ),
    Tindercard(
      title: "Card 2",
      content: "This is the description for Card 2",
      boxColor: Colors.red,
    ),
    Tindercard(
      title: "Card 3",
      content: "This is the description for Card 3",
      boxColor: Colors.purpleAccent,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CardSwiper(
          cardsCount: cards.length,
          cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
            return GestureDetector(
              onTap: () {
                _openFullScreenCard(context, cards[index]);
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: cards[index].boxColor.withOpacity(0.9),
                ),
                child: Text(
                  cards[index].title,
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            );
          },

          allowedSwipeDirection: AllowedSwipeDirection.only(left: true,right: true),
        ),
      ),
    );
  }

  void _openFullScreenCard(BuildContext context, Tindercard card) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: animation,
              child: FullScreenCard(
                card: card,
              ),
            ),
          );
        },
      ),
    );
  }
}

class FullScreenCard extends StatelessWidget {
  final Tindercard card;

  FullScreenCard({required this.card});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: card.boxColor,
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context); // this is to go back
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                card.title,
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  card.content,
                  style: TextStyle(fontSize: 20, color: Colors.white70),
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
