import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_glow/flutter_glow.dart';

class TicTacToeGame extends StatefulWidget {
  @override
  _TicTacToeGameState createState() => _TicTacToeGameState();
}

class _TicTacToeGameState extends State<TicTacToeGame> {
  List<String> board = List.filled(9, '');
  bool xTurn = false; // O starts first
  List<int> winIndices = [];

  static const Color neonRed = Color(0xFFFF005C);
  static const Color neonBlue = Color(0xFF00FFFF);
  static const Color bgColor = Colors.black;
  static const Color borderColor = Colors.orangeAccent;

  Timer? countdownTimer;
  int remainingSeconds = 30;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (remainingSeconds == 0) {
        timer.cancel();
        _showResultDialog("Time's Up! It's a Draw!");
      } else {
        setState(() {
          remainingSeconds--;
        });
      }
    });
  }

  void _handleTap(int index) {
    if (board[index] != '' || winIndices.isNotEmpty) return;

    setState(() {
      board[index] = xTurn ? 'X' : 'O';
      xTurn = !xTurn;
      winIndices = _checkWin();
    });

    if (winIndices.isNotEmpty) {
      countdownTimer?.cancel();
      Future.delayed(Duration(milliseconds: 300), () {
        _showResultDialog("${board[winIndices[0]]} Wins!");
      });
    } else if (!board.contains('')) {
      countdownTimer?.cancel();
      Future.delayed(Duration(milliseconds: 300), () {
        _showResultDialog("It's a Draw!");
      });
    }
  }

  List<int> _checkWin() {
    List<List<int>> winPatterns = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6]
    ];

    for (var pattern in winPatterns) {
      String a = board[pattern[0]];
      String b = board[pattern[1]];
      String c = board[pattern[2]];

      if (a != '' && a == b && b == c) {
        return pattern;
      }
    }
    return [];
  }

  void _showResultDialog(String result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.black87,
        title: Text(
          result,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back
            },
            child: Text(
              'Back',
              style: TextStyle(color: Colors.orangeAccent, fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTile(int index) {
    String symbol = board[index];
    Color glowColor = symbol == 'X' ? neonRed : neonBlue;

    return GestureDetector(
      onTap: () => _handleTap(index),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white24, width: 2),
        ),
        child: Center(
          child: symbol != ''
              ? GlowText(
                  symbol,
                  style: TextStyle(
                    fontSize: 64,
                    color: glowColor,
                    fontWeight: FontWeight.bold,
                  ),
                  glowColor: glowColor.withOpacity(0.7),
                )
              : null,
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$secs";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20),
            Text(
              'Timer: ${_formatTime(remainingSeconds)}',
              style: TextStyle(
                color: Colors.orangeAccent,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: Center(
                child: Container(
                  margin: EdgeInsets.all(20),
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: borderColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: GridView.builder(
                      itemCount: 9,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3),
                      itemBuilder: (_, i) => _buildTile(i),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
