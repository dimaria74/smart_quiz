import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_quiz_app/models/category.dart';
import 'package:smart_quiz_app/models/quiz.dart';
import 'package:smart_quiz_app/theme/theme.dart';
import 'package:smart_quiz_app/views/admin/add_quiz_view.dart';
import 'package:smart_quiz_app/views/admin/edit_quiz_view.dart';

class ManageQuizzesView extends StatefulWidget {
  final String? categoryId;
  final String? categoryName;
  const ManageQuizzesView({super.key, this.categoryId, this.categoryName});

  @override
  State<ManageQuizzesView> createState() => _ManageQuizzesViewState();
}

class _ManageQuizzesViewState extends State<ManageQuizzesView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String? _selectedCategoryId;
  List<Category> _categories = [];
  Category? _initialCategory;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final querySnapshot = await _firestore.collection('categories').get();
      final categories = querySnapshot.docs
          .map((doc) => Category.fromMap(doc.id, doc.data()))
          .toList();
      setState(() {
        _categories = categories;
        if (widget.categoryId != null) {
          _initialCategory = _categories.firstWhere(
            (category) => category.id == widget.categoryId,
            orElse: () => Category(
                id: widget.categoryId!, name: 'Unknown', description: ''),
          );

          _selectedCategoryId = _initialCategory!.id;
        }
      });
    } catch (e) {
      print('Error Fetching Categories : $e');
    }
  }

  Stream<QuerySnapshot> _getQuizStream() {
    Query query = _firestore.collection("quizzes");
    String? filterCategoryId = _selectedCategoryId ?? widget.categoryId;

    if (filterCategoryId != null) {
      query = query.where("categoryId", isEqualTo: filterCategoryId);
    }

    return query.snapshots();
  }

  Widget _buildTitle() {
    String? categoryId = _selectedCategoryId ?? widget.categoryId;
    if (categoryId == null) {
      return Text(
        'All Quizzes',
        style: TextStyle(fontWeight: FontWeight.bold),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection("categories").doc(categoryId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            Text(
              'Loading...',
              style: TextStyle(fontWeight: FontWeight.bold),
            );
          }
          final category = Category.fromMap(
            categoryId,
            snapshot.data!.data() as Map<String, dynamic>,
          );
          return Text(
            category.name,
            style: TextStyle(fontWeight: FontWeight.bold),
          ); // LOL
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: _buildTitle(), // LOL
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddQuizView(
                    categoryId: widget.categoryId,
                    categoryName: widget.categoryName,
                  ),
                ),
              );
            },
            icon: Icon(
              Icons.add_circle,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                fillColor: Colors.white,
                hintText: 'Search Quizzes',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12),
            child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 16, horizontal: 10),
                  border: OutlineInputBorder(),
                  hintText: 'Category',
                ),
                value: _selectedCategoryId,
                items: [
                  DropdownMenuItem(
                    value: null,
                    child: Text('All Categories'),
                  ),
                  if (_initialCategory != null &&
                      _categories.every((c) => c.id != _initialCategory!.id))
                    DropdownMenuItem(
                      value: _initialCategory!.id,
                      child: Text(_initialCategory!.name),
                    ),
                  ..._categories.map(
                    (category) => DropdownMenuItem(
                      value: category.id,
                      child: Text(category.name),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCategoryId = value;
                  });
                }),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getQuizStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error'),
                  );
                }

                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryColor,
                    ),
                  );
                }

                final quizzes = snapshot.data!.docs
                    .map((doc) => Quiz.fromMap(
                        doc.id, doc.data() as Map<String, dynamic>))
                    .where(
                      (quiz) =>
                          _searchQuery.isEmpty ||
                          quiz.title.toLowerCase().contains(_searchQuery),
                    )
                    .toList();

                if (quizzes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.quiz,
                          color: AppTheme.txtSecondaryColor,
                          size: 64,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No quizzes yet',
                          style: TextStyle(
                            color: AppTheme.txtSecondaryColor,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddQuizView(
                                    categoryId: widget.categoryId,
                                    categoryName: widget.categoryName,
                                  ),
                                ),
                              );
                            },
                            child: Text('Add Quiz')),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: quizzes.length,
                    itemBuilder: (context, index) {
                      final Quiz quiz = quizzes[index];
                      return Card(
                        margin: EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          //   onTap: () {
                          //     Navigator.push(
                          //         context,
                          //         MaterialPageRoute(
                          //             builder: (context) =>
                          //                 ManageQuizzesView(categoryId: category.id)));
                          //   },
                          contentPadding: EdgeInsets.all(16),
                          leading: Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withAlpha(45),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.quiz,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          title: Text(
                            quiz.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.question_answer,
                                    size: 16,
                                  ),
                                  SizedBox(
                                    width: 4,
                                  ),
                                  Text(
                                    "${quiz.questions.length} Questions",
                                  ),
                                  SizedBox(
                                    width: 12,
                                  ),
                                  Icon(
                                    Icons.timer,
                                    color: AppTheme.primaryColor,
                                    size: 16,
                                  ),
                                  SizedBox(
                                    width: 4,
                                  ),
                                  Text('${quiz.timeLimit} mins')
                                ],
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton(
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'edit',
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: Icon(
                                    Icons.edit,
                                    color: AppTheme.primaryColor,
                                  ),
                                  title: Text('Edit'),
                                ),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: Icon(
                                    Icons.delete,
                                    color: Colors.redAccent,
                                  ),
                                  title: Text('Delete'),
                                ),
                              ),
                            ],
                            onSelected: (value) =>
                                _handleQuizAction(context, value, quiz),
                          ),
                        ),
                      );
                    });
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleQuizAction(
    context,
    String value,
    Quiz quiz,
  ) async {
    if (value == 'edit') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditQuizView(quiz: quiz),
        ),
      );
    } else if (value == 'delete') {
      // await _firestore.collection('categories').doc(category.id).delete();
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Delete Quiz!'),
          content: Text('Are you sure you want to delete this quiz?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: Text('Cancle'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        ),
      );
      if (confirm == true) {
        await _firestore.collection('quizzes').doc(quiz.id).delete();
      }
    }
  }
}
