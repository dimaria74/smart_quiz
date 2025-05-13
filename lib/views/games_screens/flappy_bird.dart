import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class FlappyBirdPage extends StatefulWidget {
  @override
  _FlappyBirdPageState createState() => _FlappyBirdPageState();
}

class _FlappyBirdPageState extends State<FlappyBirdPage> {
  static const double gravity = 1.5;
  static const double jumpVelocity = -20;
  static const double birdWidth = 40;
  static const double birdHeight = 40;
  static const double pipeWidth = 60;
  static const double pipeGap = 150;
  static const int gameTickMs = 30;

  double birdY = 0;
  double birdVelocity = 0;
  bool isGameStarted = false;
  bool isGameOver = false;
  int score = 0;
  List<Pipe> pipes = [];
  Timer? gameLoop;

  void startGame() {
    isGameStarted = true;
    isGameOver = false;
    birdY = 300;
    birdVelocity = 0;
    score = 0;
    pipes.clear();
    generateInitialPipes();

    gameLoop = Timer.periodic(Duration(milliseconds: gameTickMs), (timer) {
      setState(() {
        birdVelocity += gravity;
        birdY += birdVelocity;

        for (var pipe in pipes) {
          pipe.x -= 5;
        }

        // Add new pipes when the first one goes off screen
        if (pipes.isNotEmpty && pipes.first.x < -pipeWidth) {
          pipes.removeAt(0);
          pipes.removeAt(0);
          addPipe();
          score++;
        }

        checkCollision();
      });
    });
  }

  void generateInitialPipes() {
    for (int i = 0; i < 2; i++) {
      addPipe(initial: true, offsetX: i * 300 + 500);
    }
  }

  void addPipe({bool initial = false, double? offsetX}) {
    double x = offsetX ?? 600;
    double gapY = Random().nextInt(250) + 100;
    pipes.add(Pipe(x: x, height: gapY - pipeGap / 2, isTop: true));
    pipes.add(Pipe(x: x, height: 600 - gapY - pipeGap / 2, isTop: false));
  }

  void jump() {
    if (!isGameStarted) {
      startGame();
    }
    if (!isGameOver) {
      setState(() {
        birdVelocity = jumpVelocity;
      });
    }
  }

  void checkCollision() {
    if (birdY < 0 || birdY + birdHeight > 600) {
      endGame();
    }

    for (var pipe in pipes) {
      if (pipe.x < 100 + birdWidth &&
          pipe.x + pipeWidth > 100 &&
          ((pipe.isTop && birdY < pipe.height) ||
              (!pipe.isTop && birdY + birdHeight > 600 - pipe.height))) {
        endGame();
      }
    }
  }

  void endGame() {
    isGameOver = true;
    gameLoop?.cancel();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text('Game Over'),
        content: Text('Score: $score'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                isGameStarted = false;
              });
            },
            child: Text('Restart'),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    gameLoop?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: jump,
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              color: Colors.lightBlue[200],
              child: CustomPaint(
                size: Size(double.infinity, 600),
                painter: GamePainter(
                  birdY: birdY,
                  pipes: pipes,
                  birdWidth: birdWidth,
                  birdHeight: birdHeight,
                  pipeWidth: pipeWidth,
                ),
              ),
            ),
            Positioned(
              top: 40,
              left: 20,
              child: Text(
                'Score: $score',
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
            ),
            if (!isGameStarted)
              Center(
                child: Text(
                  'TAP TO START',
                  style: TextStyle(fontSize: 30, color: Colors.white),
                ),
              )
          ],
        ),
      ),
    );
  }
}

class Pipe {
  double x;
  double height;
  bool isTop;

  Pipe({required this.x, required this.height, required this.isTop});
}

class GamePainter extends CustomPainter {
  final double birdY;
  final List<Pipe> pipes;
  final double birdWidth;
  final double birdHeight;
  final double pipeWidth;

  GamePainter({
    required this.birdY,
    required this.pipes,
    required this.birdWidth,
    required this.birdHeight,
    required this.pipeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bird = Paint()..color = Colors.yellow;
    final pipePaint = Paint()..color = Colors.green;

    // Draw bird
    canvas.drawRect(
      Rect.fromLTWH(100, birdY, birdWidth, birdHeight),
      bird,
    );

    // Draw pipes
    for (var pipe in pipes) {
      if (pipe.isTop) {
        canvas.drawRect(
          Rect.fromLTWH(pipe.x, 0, pipeWidth, pipe.height),
          pipePaint,
        );
      } else {
        canvas.drawRect(
          Rect.fromLTWH(pipe.x, 600 - pipe.height, pipeWidth, pipe.height),
          pipePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
