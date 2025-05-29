import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:smart_quiz_app/models/category.dart';
import 'package:smart_quiz_app/models/quiz.dart';
import 'package:smart_quiz_app/theme/theme.dart';
import 'package:smart_quiz_app/views/user/quiz_play_view.dart';
import 'package:audioplayers/audioplayers.dart';

class CategoryView extends StatefulWidget {
  final Category category;
  const CategoryView({super.key, required this.category});

  @override
  State<CategoryView> createState() => _CategoryViewState();
}

class _CategoryViewState extends State<CategoryView> {
  List<Quiz> _quizzes = [];
  bool _isLoading = true;

  @override
  void initState() {
    _fetchQuizzes();
    super.initState();
  }

  Future<void> _fetchQuizzes() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('quizzes')
          .where('categoryId', isEqualTo: widget.category.id)
          .get();

      setState(() {
        _quizzes = snapshot.docs
            .map(
              (doc) => Quiz.fromMap(
                doc.id,
                doc.data(),
              ),
            )
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load quizzes'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber,
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryColor,
              ),
            )
          : _quizzes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.quiz_outlined,
                        color: AppTheme.txtSecondaryColor,
                        size: 64,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No quizzes available for this subject',
                        style: TextStyle(
                          color: AppTheme.txtSecondaryColor,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Go Back..'),
                      ),
                    ],
                  ),
                )
              : CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(24),
                          bottomRight: Radius.circular(24),
                        ),
                      ),
                      foregroundColor: Colors.white,
                      backgroundColor: AppTheme.primaryColor,
                      expandedHeight: 235,
                      floating: false,
                      pinned: true,
                      leading: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                      ),
                      flexibleSpace: FlexibleSpaceBar(
                        centerTitle: true,
                        title: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            widget.category.description,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        background: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.category,
                                size: 64,
                                color: Colors.white,
                              ),
                              // SizedBox(height: 8),
                              Text(
                                widget.category.name,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 24,
                                ),
                              ),
                              SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        child: ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: _quizzes.length,
                            itemBuilder: (context, index) {
                              final quiz = _quizzes[index];
                              return _buildQuizCard(quiz, index);
                            }),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildQuizCard(Quiz quiz, int index) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (contect) => QuizPlayView(
                quiz: quiz,
              ),
            ),
          );
          // AudioPlayer audio = AudioPlayer();
          // audio.play(AssetSource('kids-happy-music.mp3'));
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withAlpha(45),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.quiz_rounded,
                  color: AppTheme.primaryColor,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quiz.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppTheme.txtPrimaryColor,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.question_answer,
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Text('${quiz.questions.length} Questions'),
                            SizedBox(width: 16),
                            Icon(
                              Icons.timer,
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Text('${quiz.timeLimit} mins'),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 32,
                color: AppTheme.primaryColor,
              )
            ],
          ),
        ),
      ),
    )
        .animate(
          delay: Duration(
            microseconds: 100 * index,
          ),
        )
        .slideX(begin: 0.5, end: 0, duration: Duration(milliseconds: 300))
        .fadeIn();
  }
}
