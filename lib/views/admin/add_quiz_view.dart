import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_quiz_app/models/category.dart';
import 'package:smart_quiz_app/models/question.dart';
import 'package:smart_quiz_app/models/quiz.dart';
import 'package:smart_quiz_app/theme/theme.dart';

class AddQuizView extends StatefulWidget {
  final String? categoryId;
  final String? categoryName;
  const AddQuizView({super.key, this.categoryId, this.categoryName});

  @override
  State<AddQuizView> createState() => _AddQuizViewState();
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

class _AddQuizViewState extends State<AddQuizView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _timeLimitController = TextEditingController();
  bool _isLoading = false;
  String? _selectedCategoryId;
  List<QuestionFormItem> _questionsItem = [];

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.categoryId;
    _addQuestion();
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

  void _addQuestion() {
    setState(
      () {
        _questionsItem.add(
          QuestionFormItem(
            questionController: TextEditingController(),
            correctOptionIndex: 0,
            optionsControllers: List.generate(
              4,
              (_) => TextEditingController(),
            ),
          ),
        );
      },
    );
  }

  void _removeQuestion(int index) {
    setState(() {
      _questionsItem[index].dispose();
      _questionsItem.removeAt(index);
    });
  }

  Future<void> _saveQuiz() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a category'),
        ),
      );
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

      await _firestore.collection('quizzes').doc().set(
            Quiz(
              id: _firestore.collection('quizzes').doc().id,
              title: _titleController.text.trim(),
              categoryId: _selectedCategoryId!,
              timeLimit: int.parse(_timeLimitController.text),
              questions: questions,
              createdAt: DateTime.now(),
            ).toMap(),
          );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Quiz added successfully',
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
            'Failed to add quiz',
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

  // @override
  // void dispose() {
  //   _titleController.dispose();
  //   _timeLimitController.dispose();
  //   for (var item in _questionsItem) {
  //     item.dispose();
  //   }
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        title: Text(
          widget.categoryName != null
              ? "Add ${widget.categoryName} Quiz"
              : 'Add Quiz',
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _saveQuiz,
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
          padding: EdgeInsets.all(20),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quiz Details',
                  style: TextStyle(
                    color: AppTheme.txtPrimaryColor,
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 16),
                    fillColor: Colors.white,
                    labelText: 'Title',
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
                if (widget.categoryId == null)
                  StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('categories')
                        .orderBy('name')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text('Error');
                      }
                      if (!snapshot.hasData) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.primaryColor,
                          ),
                        );
                      }

                      final categories = snapshot.data!.docs
                          .map((doc) => Category.fromMap(
                              doc.id, doc.data() as Map<String, dynamic>))
                          .toList();

                      return DropdownButtonFormField<String>(
                        value: _selectedCategoryId,
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          labelText: 'Category',
                          hintText: 'Select category',
                          prefixIcon: Icon(
                            Icons.category,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        items: categories
                            .map(
                              (category) => DropdownMenuItem(
                                value: category.id,
                                child: Text(category.name),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(
                            () {
                              _selectedCategoryId = value;
                            },
                          );
                        },
                        // ignore: body_might_complete_normally_nullable
                        validator: (value) {
                          value == null ? "Please select a category" : 'null';
                        },
                      );
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
                SizedBox(height: 10),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                ...question.optionsControllers
                                    .asMap()
                                    .entries
                                    .map(
                                  (entry) {
                                    final optionIndex = entry.key;
                                    final controller = entry.value;

                                    return Padding(
                                      padding: EdgeInsets.only(bottom: 8),
                                      child: Row(
                                        children: [
                                          Radio<int>(
                                              activeColor:
                                                  AppTheme.primaryColor,
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
                        onPressed: _isLoading ? null : _saveQuiz,
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
                                'Save Quiz',
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
          ],
        ),
      ),
    );
  }
}
