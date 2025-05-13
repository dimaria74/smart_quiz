import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_quiz_app/models/question.dart';
import 'package:smart_quiz_app/models/quiz.dart';
import 'package:smart_quiz_app/theme/theme.dart';

class EditQuizView extends StatefulWidget {
  final Quiz quiz;
  const EditQuizView({super.key, required this.quiz});

  @override
  State<EditQuizView> createState() => _EditQuizViewState();
}

class QuestionFormItem {
  final TextEditingController questionController;
  int correctOptionIndex;
  final List<TextEditingController> optionsControllers;

  QuestionFormItem({
    required this.questionController,
    required this.correctOptionIndex,
    required this.optionsControllers,
  });

  void dispose() {
    questionController.dispose();
    optionsControllers.forEach((element) {
      element.dispose();
    });
  }
}

class _EditQuizViewState extends State<EditQuizView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _timeLimitController;
  bool _isLoading = false;
  late List<QuestionFormItem> _questionsItem;

  @override
  void initState() {
    _initData();
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _timeLimitController.dispose();
    for (var item in _questionsItem) {
      item.dispose();
    }
    super.dispose();
  }

  void _initData() {
    _titleController = TextEditingController(text: widget.quiz.title);
    _timeLimitController =
        TextEditingController(text: widget.quiz.timeLimit.toString());

    _questionsItem = widget.quiz.questions.map((question) {
      return QuestionFormItem(
        questionController: TextEditingController(text: question.text),
        correctOptionIndex: question.correctOptionIndex,
        optionsControllers: question.options
            .map((option) => TextEditingController(text: option))
            .toList(),
      );
    }).toList();
  }

  void _addQuestion() {
    setState(() {
      _questionsItem.add(
        QuestionFormItem(
          questionController: TextEditingController(),
          correctOptionIndex: 0,
          optionsControllers: List.generate(
            4,
            (e) => TextEditingController(),
          ),
        ),
      );
    });
  }

  void _removeQuestion(int index) {
    if (_questionsItem.length > 1) {
      setState(() {
        _questionsItem[index].dispose();
        _questionsItem.removeAt(index);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Quiz must have at least one question!'),
        ),
      );
    }
  }

  Future<void> _updateQuiz() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });
    try {
      final questions = _questionsItem
          .map(
            (item) => Question(
              text: item.questionController.text.trim(),
              options:
                  item.optionsControllers.map((e) => e.text.trim()).toList(),
              correctOptionIndex: item.correctOptionIndex,
            ),
          )
          .toList();

      final updateQuiz = widget.quiz.copyWith(
        title: _titleController.text.trim(),
        timeLimit: int.parse(_timeLimitController.text),
        questions: questions,
        createdAt: widget.quiz.createdAt
      );

      await _firestore.collection('quizzes').doc(widget.quiz.id).update(
            updateQuiz.toMap(isUpdated: true),
          );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Quiz updated successfully',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppTheme.secondaryColor,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update quiz',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Quiz',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _updateQuiz,
            icon: Icon(
              Icons.save,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(
            20,
          ),
          children: [
            Text(
              'Quiz Details',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.txtPrimaryColor),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 16),
                fillColor: Colors.white,
                labelText: 'Quiz Title',
                hintText: 'Enter quiz title',
                prefixIcon: Icon(
                  Icons.title,
                  color: AppTheme.primaryColor,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'please enter quiz title';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _timeLimitController,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 16),
                fillColor: Colors.white,
                labelText: 'Time Limit (minuites)',
                hintText: 'Enter time limit',
                prefixIcon: Icon(
                  Icons.timer,
                  color: AppTheme.primaryColor,
                ),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'please enter time limit';
                }

                final number = int.tryParse(value);
                if (number == null || number <= 0) {
                  return 'please enter a valid time limit';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Questions',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.txtPrimaryColor,
                        fontSize: 20,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _addQuestion,
                      label: Text(
                        'Add Question',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                ..._questionsItem.asMap().entries.map(
                  (entry) {
                    final index = entry.key;
                    final QuestionFormItem question = entry.value;

                    return Card(
                      margin: EdgeInsets.all(16),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Question ${index + 1}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor,
                                    fontSize: 16,
                                  ),
                                ),
                                if (_questionsItem.length > 1)
                                  IconButton(
                                    onPressed: () {
                                      _removeQuestion(index);
                                    },
                                    icon: Icon(
                                      Icons.delete,
                                      color: Colors.redAccent,
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              controller: question.questionController,
                              decoration: InputDecoration(
                                  labelText: 'Question Title',
                                  hintText: 'Enter question',
                                  prefixIcon: Icon(Icons.question_answer)),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'please enter question';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16),
                            ...question.optionsControllers.asMap().entries.map(
                              (entry) {
                                final optionIndex = entry.key;
                                final controller = entry.value;

                                return Padding(
                                  padding: EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      Radio<int>(
                                          activeColor: AppTheme.primaryColor,
                                          value: optionIndex,
                                          groupValue:
                                              question.correctOptionIndex,
                                          onChanged: (value) {
                                            setState(() {
                                              question.correctOptionIndex =
                                                  value!;
                                            });
                                          }),
                                      Expanded(
                                        child: TextFormField(
                                          controller: controller,
                                          decoration: InputDecoration(
                                            labelText:
                                                'Option ${optionIndex + 1}',
                                            hintText: 'Enter Option',
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'please enter qoption';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 24),
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _updateQuiz,
                    child: _isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Update Quiz',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
