import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Memory Game',
      theme: ThemeData.dark(),
      home: StartScreen(),
    );
  }
}

// 🎮 Start Screen with Animations
class StartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "COLOR MEMORY GAME",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              style: _buttonStyle(),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ColorMemoryGame()),
                );
              },
              child: Text("Start Game"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: _buttonStyle(),
              onPressed: () {
                _showGameRules(context);
              },
              child: Text("Game Rules"),
            ),
          ],
        ),
      ),
    );
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.deepPurpleAccent,
      shadowColor: Colors.purpleAccent,
      elevation: 10,
      textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  void _showGameRules(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: Text("Game Rules", style: TextStyle(color: Colors.white)),
          content: Text(
            "1. Tap to flip two cards.\n"
                "2. If they match, they remain flipped.\n"
                "3. If not, they turn back after a second.\n"
                "4. Match all pairs to win!",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK", style: TextStyle(color: Colors.deepPurpleAccent)),
            ),
          ],
        );
      },
    );
  }
}

// 🎭 The Game Itself
class ColorMemoryGame extends StatefulWidget {
  @override
  _ColorMemoryGameState createState() => _ColorMemoryGameState();
}

class _ColorMemoryGameState extends State<ColorMemoryGame> {
  final int gridSize = 4;
  late List<Color> _colors;
  late List<int> _shuffledIndexes;
  late List<bool> _flippedCards;
  late List<int> _selectedTiles;
  int _matchedCount = 0;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    _colors = [
      Colors.red, Colors.green, Colors.blue, Colors.yellow,
      Colors.orange, Colors.purple, Colors.teal, Colors.cyan,
      Colors.red, Colors.green, Colors.blue, Colors.yellow,
      Colors.orange, Colors.purple, Colors.teal, Colors.cyan
    ];
    _shuffledIndexes = List.generate(_colors.length, (index) => index)..shuffle();
    _flippedCards = List.generate(_colors.length, (index) => false);
    _selectedTiles = [];
    _matchedCount = 0;
  }

  void _flipTile(int index) {
    if (_flippedCards[index] || _selectedTiles.length == 2) return;

    setState(() {
      _flippedCards[index] = true;
      _selectedTiles.add(index);
      if (_selectedTiles.length == 2) _checkMatch();
    });
  }

  void _checkMatch() {
    int first = _selectedTiles[0];
    int second = _selectedTiles[1];

    if (_colors[_shuffledIndexes[first]] == _colors[_shuffledIndexes[second]]) {
      _matchedCount++;
      _selectedTiles.clear();
      if (_matchedCount == (_colors.length ~/ 2)) _showGameOverDialog();
    } else {
      Future.delayed(Duration(milliseconds: 600), () {
        setState(() {
          _flippedCards[first] = false;
          _flippedCards[second] = false;
          _selectedTiles.clear();
        });
      });
    }
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: Text("🎉 YOU WON!", style: TextStyle(color: Colors.white)),
          content: Text(
            "Congratulations! You matched all the colors!",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _initializeGame();
                });
              },
              child: Text("Play Again", style: TextStyle(color: Colors.deepPurpleAccent)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Memory Game", style: TextStyle(fontSize: 22)),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: gridSize,
            childAspectRatio: 1.0,
          ),
          itemCount: _colors.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => _flipTile(index),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: _flippedCards[index]
                      ? _colors[_shuffledIndexes[index]]
                      : Colors.grey[900],
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    if (_flippedCards[index])
                      BoxShadow(color: _colors[_shuffledIndexes[index]].withOpacity(0.6), blurRadius: 15, spreadRadius: 1),
                  ],
                ),
                margin: EdgeInsets.all(8.0),
              ),
            );
          },
        ),
      ),
    );
  }
}
