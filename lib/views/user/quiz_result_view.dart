import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:smart_quiz_app/models/quiz.dart';
import 'package:smart_quiz_app/theme/theme.dart';
import 'package:smart_quiz_app/views/user/leaderboard.dart';
import 'package:smart_quiz_app/views/user/user_history_view.dart';

class QuizResultView extends StatefulWidget {
  final Quiz quiz;
  final int totalQuestions;
  final int correctAnswers;
  final Map<int, int?> selectedAnswers;
  const QuizResultView({
    super.key,
    required this.quiz,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.selectedAnswers,
  });

  @override
  State<QuizResultView> createState() => _QuizResultViewState();
}

class _QuizResultViewState extends State<QuizResultView> {
  int? userRank;

  @override
  void initState() {
    super.initState();
    _submitScore(widget.correctAnswers); // Save the score
    _fetchUserRank(); // Get the rank
  }

  Future<void> _fetchUserRank() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final rank = await _getUserRank(user.uid);
      setState(() {
        userRank = rank;
      });
    }
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(25),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 32,
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 24,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: AppTheme.txtSecondaryColor,
              fontSize: 14,
            ),
          ),
        ],
      ),
    ).animate().scale(
          duration: Duration(milliseconds: 400),
          delay: Duration(milliseconds: 300),
        );
  }

  Widget _buildAnswerRow(String lable, String answer, Color answerColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          lable,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: AppTheme.txtSecondaryColor,
          ),
        ),
        SizedBox(height: 4),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: answerColor.withAlpha(45),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            answer,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: answerColor,
            ),
          ),
        ),
      ],
    );
  }

  IconData _getPerformanceIcon(double score) {
    if (score >= 0.9) return Icons.emoji_events;
    if (score >= 0.8) return Icons.star;
    if (score >= 0.6) return Icons.thumb_up;
    if (score >= 0.4) return Icons.trending_up;

    return Icons.refresh;
  }

  Color _getScoreColor(double score) {
    if (score >= 0.8) return Colors.greenAccent;
    if (score >= 0.5) return Colors.orange;
    return Colors.redAccent;
  }

  String _getPerformanceMessage(double score) {
    if (score >= 0.9) return "OutStanding";
    if (score >= 0.8) return "Great Job!";
    if (score >= 0.6) return "Good Effort!";
    if (score >= 0.4) return "Keep Practicing";

    return "Try Again";
  }

  @override
  Widget build(BuildContext context) {
    final score = widget.correctAnswers / widget.totalQuestions;
    final scorePercentage = (score * 100).round();
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryColor.withAlpha(100),
                    AppTheme.primaryColor,
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  SizedBox(height: 30),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Quiz Result',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 40),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          shape: BoxShape.circle,
                        ),
                        child: CircularPercentIndicator(
                          radius: 100,
                          lineWidth: 15,
                          animation: true,
                          animationDuration: 1500,
                          percent: score,
                          center: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${scorePercentage}%',
                                style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '${((widget.correctAnswers / widget.totalQuestions) * 100).toInt()}',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white54,
                                ),
                              ),
                              if (userRank != null)
                                Text(
                                  'You are ranked $userRank',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white70,
                                  ),
                                ),
                            ],
                          ),
                          circularStrokeCap: CircularStrokeCap.round,
                          progressBorderColor: Colors.white,
                          backgroundColor: Colors.white54,
                        ),
                      ),
                    ],
                  ).animate().scale(
                      delay: Duration(
                        milliseconds: 800,
                      ),
                      curve: Curves.elasticInOut),
                  SizedBox(height: 24),
                  Container(
                    margin: EdgeInsets.only(bottom: 30),
                    padding: EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black45,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getPerformanceIcon(score),
                          color: _getScoreColor(score),
                          size: 32,
                        ),
                        SizedBox(width: 8),
                        Text(
                          _getPerformanceMessage(score),
                          style: TextStyle(
                            color: _getScoreColor(score),
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                  ).animate().slideY(
                        begin: 0.3,
                        duration: Duration(
                          milliseconds: 500,
                        ),
                        delay: Duration(
                          milliseconds: 200,
                        ),
                      ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                        "Correct",
                        widget.correctAnswers.toString(),
                        Icons.check_circle,
                        Colors.greenAccent),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                        "Incorrect",
                        (widget.totalQuestions - widget.correctAnswers)
                            .toString(),
                        Icons.cancel,
                        Colors.redAccent),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.analytics,
                        color: AppTheme.primaryColor,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Detailed Analysis',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.txtPrimaryColor),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  ...widget.quiz.questions.asMap().entries.map(
                    (entry) {
                      final index = entry.key;
                      final question = entry.value;
                      final selectedAnswer = widget.selectedAnswers[index];
                      final isCorrect = selectedAnswer != null &&
                          selectedAnswer == question.correctOptionIndex;
                      return Container(
                        margin: EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade500,
                              spreadRadius: 2,
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            dividerColor: Colors.transparent,
                          ),
                          child: ExpansionTile(
                            leading: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  color: isCorrect
                                      ? Colors.greenAccent.withAlpha(45)
                                      : Colors.redAccent.withAlpha(45),
                                  shape: BoxShape.circle),
                              child: Icon(
                                isCorrect
                                    ? Icons.check_circle_outline
                                    : Icons.close,
                                color: isCorrect
                                    ? Colors.greenAccent
                                    : Colors.redAccent,
                                size: 24,
                              ),
                            ),
                            title: Text(
                              'Question ${index + 1}',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: AppTheme.txtPrimaryColor,
                              ),
                            ),
                            subtitle: Text(
                              question.text,
                              style: TextStyle(
                                color: AppTheme.txtSecondaryColor,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            children: [
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.only(
                                  top: 16,
                                  bottom: 16,
                                  right: 5,
                                  left: 20,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.backgroundColor,
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(20),
                                    bottomRight: Radius.circular(20),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      question.text,
                                      style: TextStyle(
                                        color: AppTheme.txtPrimaryColor,
                                        fontSize: 18,
                                      ),
                                      maxLines: 4,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 20),
                                    _buildAnswerRow(
                                      'Your Answer: ',
                                      selectedAnswer != null
                                          ? question.options[selectedAnswer]
                                          : 'Not Answered',
                                      isCorrect
                                          ? Colors.greenAccent
                                          : Colors.redAccent,
                                    ),
                                    SizedBox(height: 12),
                                    _buildAnswerRow(
                                      'Correct Answer: ',
                                      question
                                          .options[question.correctOptionIndex],
                                      Colors.greenAccent,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ).animate().scaleX(
                            begin: 0.3,
                            duration: Duration(
                              milliseconds: 300,
                            ),
                            delay: Duration(milliseconds: 100 * index),
                          );
                    },
                  ).toList(),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: Expanded(
                      child: ElevatedButton.icon(
                        icon: Icon(
                          Icons.refresh,
                          color: Colors.white,
                          size: 24,
                        ),
                        label: Text(
                          'Try Again',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: Expanded(
                      child: ElevatedButton.icon(
                        icon: Icon(
                          Icons.leaderboard,
                          color: Colors.white,
                          size: 24,
                        ),
                        label: Text(
                          'View Leaderboard',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LeaderboardView()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: Expanded(
                      child: ElevatedButton.icon(
                        icon: Icon(
                          Icons.history,
                          color: Colors.white,
                          size: 24,
                        ),
                        label: Text(
                          'View History',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const UserHistoryView()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _submitScore(int score) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;

      // 🔥 Fetch user's name from Firestore instead of FirebaseAuth displayName
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      final name = userDoc['name'] ?? 'Anonymous';

      final leaderboardRef =
          FirebaseFirestore.instance.collection('leaderboard').doc(userId);
      final leaderboardDoc = await leaderboardRef.get();

      if (leaderboardDoc.exists) {
        // Update existing score
        final currentScore = leaderboardDoc['score'] ?? 0;
        final totalQuizzes = leaderboardDoc['totalQuizzes'] ?? 0;
        await leaderboardRef.update({
          'score': currentScore + score,
          'totalQuizzes': totalQuizzes + 1,
          'lastUpdated': Timestamp.now(),
        });
      } else {
        // Create new leaderboard entry
        await leaderboardRef.set({
          'username': name,
          'userId': userId,
          'score': score,
          'totalQuizzes': 1,
          'lastUpdated': Timestamp.now(),
        });
      }
    }
  }

  Future<int?> _getUserRank(String userId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('leaderboard')
        .orderBy('score', descending: true)
        .get();

    for (int i = 0; i < snapshot.docs.length; i++) {
      if (snapshot.docs[i].id == userId) {
        return i + 1; // Rank is index + 1
      }
    }

    return null; // user not found
  }
}
