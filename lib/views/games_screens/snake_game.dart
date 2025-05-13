import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class SnakeGame extends StatefulWidget {
  @override
  State<SnakeGame> createState() => _SnakeGameState();
}

enum Direction { up, down, left, right }

class _SnakeGameState extends State<SnakeGame> {
  static const int rows = 20;
  static const int columns = 20;
  static const Duration tickRate = Duration(milliseconds: 200);
  static const Duration gameDuration = Duration(minutes: 2);

  List<Point<int>> snake = [Point(10, 10)];
  Direction direction = Direction.right;
  Point<int>? food;
  Timer? gameLoop;
  Timer? countdownTimer;
  int score = 0;
  int timeLeft = 120;
  bool isGameOver = false;

  @override
  void initState() {
    super.initState();
    spawnFood();
    startGame();
  }

  void startGame() {
    gameLoop = Timer.periodic(tickRate, (_) => update());
    countdownTimer = Timer.periodic(Duration(seconds: 1), (_) {
      setState(() {
        timeLeft--;
        if (timeLeft <= 0 && !isGameOver) {
          isGameOver = true;
          stopGame();
          showEndDialog('Time\'s Up! Draw!');
        }
      });
    });
  }

  void stopGame() {
    gameLoop?.cancel();
    countdownTimer?.cancel();
  }

  void update() {
    if (isGameOver) return;

    final head = snake.last;
    Point<int> newHead;

    switch (direction) {
      case Direction.up:
        newHead = Point(head.x, head.y - 1);
        break;
      case Direction.down:
        newHead = Point(head.x, head.y + 1);
        break;
      case Direction.left:
        newHead = Point(head.x - 1, head.y);
        break;
      case Direction.right:
        newHead = Point(head.x + 1, head.y);
        break;
    }

    if (newHead.x < 0 ||
        newHead.y < 0 ||
        newHead.x >= columns ||
        newHead.y >= rows ||
        snake.contains(newHead)) {
      isGameOver = true;
      stopGame();
      showEndDialog('Game Over!');
      return;
    }

    snake.add(newHead);

    if (newHead == food) {
      score++;
      spawnFood();
    } else {
      snake.removeAt(0);
    }

    setState(() {});
  }

  void spawnFood() {
    final rng = Random();
    while (true) {
      final newFood = Point(rng.nextInt(columns), rng.nextInt(rows));
      if (!snake.contains(newFood)) {
        food = newFood;
        break;
      }
    }
  }

  void changeDirection(Direction newDir) {
    if ((direction == Direction.up && newDir == Direction.down) ||
        (direction == Direction.down && newDir == Direction.up) ||
        (direction == Direction.left && newDir == Direction.right) ||
        (direction == Direction.right && newDir == Direction.left)) {
      return;
    }
    direction = newDir;
  }

  void showEndDialog(String title) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text('Score: $score'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('Back'),
          )
        ],
      ),
    );
  }

  Widget buildCell(int x, int y) {
    final point = Point(x, y);
    if (snake.contains(point)) {
      return Container(color: Colors.green);
    } else if (food == point) {
      return Container(color: Colors.red);
    } else {
      return Container(color: Colors.grey[200]);
    }
  }

  Widget controlButton(IconData icon, Direction dir) {
    return ElevatedButton(
      onPressed: () => changeDirection(dir),
      style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
      child: Icon(icon, color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[850],
      body: SafeArea(
        child: GestureDetector(
          onVerticalDragUpdate: (details) {
            if (details.delta.dy < -5) changeDirection(Direction.up);
            if (details.delta.dy > 5) changeDirection(Direction.down);
          },
          onHorizontalDragUpdate: (details) {
            if (details.delta.dx < -5) changeDirection(Direction.left);
            if (details.delta.dx > 5) changeDirection(Direction.right);
          },
          child: Column(
            children: [
              SizedBox(height: 16),
              Text(
                'Score: $score   |   Time: ${timeLeft}s',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    margin: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.orange, width: 5),
                    ),
                    child: GridView.builder(
                      itemCount: rows * columns,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                      ),
                      itemBuilder: (context, index) {
                        final x = index % columns;
                        final y = index ~/ columns;
                        return buildCell(x, y);
                      },
                    ),
                  ),
                ),
              ),
              Column(
                children: [
                  controlButton(Icons.arrow_upward, Direction.up),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      controlButton(Icons.arrow_back, Direction.left),
                      SizedBox(width: 16),
                      controlButton(Icons.arrow_forward, Direction.right),
                    ],
                  ),
                  controlButton(Icons.arrow_downward, Direction.down),
                  SizedBox(height: 16),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    stopGame();
    super.dispose();
  }
}
