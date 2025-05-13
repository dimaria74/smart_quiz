import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_quiz_app/services/auth_services.dart';
import 'package:smart_quiz_app/theme/theme.dart';
import 'package:smart_quiz_app/views/admin/manage_categories_view.dart';
import 'package:smart_quiz_app/views/admin/manage_quizzes_view.dart';
import 'package:smart_quiz_app/views/login_view.dart';

final AuthService _authService = AuthService();

class AdminHomeView extends StatefulWidget {
  const AdminHomeView({super.key});

  @override
  State<AdminHomeView> createState() => _AdminHomeViewState();
}

class _AdminHomeViewState extends State<AdminHomeView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<Map<String, dynamic>> _fetchStatistics() async {
    final categoriesCount =
        await _firestore.collection('categories').count().get();

    final quizzesCount = await _firestore.collection('quizzes').count().get();

    final latestQuizzes = await _firestore
        .collection('quizzes')
        .orderBy('createdAt', descending: true)
        .limit(5)
        .get();

    final categories = await _firestore.collection('categories').get();
    final categoryData = await Future.wait(
      categories.docs.map(
        (category) async {
          final quizCount = await _firestore
              .collection('quizzes')
              .where('categoryId', isEqualTo: category.id)
              .count()
              .get();

          return {
            'name': category.data()['name'] as String,
            'count': quizCount.count,
          };
        },
      ),
    );
    return {
      'totalCategories': categoriesCount.count,
      'totalQuizzes': quizzesCount.count,
      'latestQuizzes': latestQuizzes.docs,
      'categoryData': categoryData,
    };
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildStateCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: color.withAlpha(45),
              ),
              child: Icon(
                icon,
                color: color,
                size: 25,
              ),
            ),
            SizedBox(
              height: 12,
            ),
            Text(
              value,
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.txtPrimaryColor),
            ),
            SizedBox(
              height: 4,
            ),
            Text(
              title,
              style: TextStyle(fontSize: 14, color: AppTheme.txtSecondaryColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withAlpha(45),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.primaryColor,
                  size: 32,
                ),
              ),
              SizedBox(
                height: 12,
              ),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.txtPrimaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Admin Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: FutureBuilder(
        future: _fetchStatistics(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryColor,
              ),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('An error occured!'),
            );
          }
          final Map<String, dynamic> stats = snapshot.data!;
          final List<dynamic> categoryData = stats['categoryData'];
          final List<QueryDocumentSnapshot> latestQuizzes =
              stats['latestQuizzes'];

          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome Admin!',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.txtPrimaryColor),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Text(
                    "Here's your quiz application overview",
                    style: TextStyle(
                        fontSize: 16, color: AppTheme.txtSecondaryColor),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStateCard(
                            'Total Categories',
                            stats['totalCategories'].toString(),
                            Icons.category,
                            AppTheme.primaryColor),
                      ),
                      SizedBox(
                        width: 16,
                      ),
                      Expanded(
                        child: _buildStateCard(
                            'Total Quizzes',
                            stats['totalQuizzes'].toString(),
                            Icons.quiz,
                            AppTheme.secondaryColor),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.pie_chart,
                                color: AppTheme.primaryColor,
                                size: 24,
                              ),
                              SizedBox(
                                width: 16,
                              ),
                              Text(
                                'Category Statistics',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: AppTheme.txtPrimaryColor),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          ListView.builder(
                              itemCount: categoryData.length,
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                final category = categoryData[index];
                                final totalQuizzes = categoryData.fold<int>(
                                  0,
                                  // ignore: avoid_types_as_parameter_names
                                  (sum, item) => sum + (item['count'] as int),
                                );
                                final percentage = totalQuizzes > 0
                                    ? (category['count'] as int) /
                                        totalQuizzes *
                                        100
                                    : 0.0;
                                return Padding(
                                  padding: EdgeInsets.only(bottom: 16),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              category['name'] as String,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: AppTheme.txtPrimaryColor,
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            Text(
                                              "${category['count']} ${(category['count'] as int) == 1 ? 'quiz' : 'quizzes'}",
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color:
                                                    AppTheme.txtSecondaryColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryColor
                                              .withAlpha(45),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          '${percentage.toStringAsFixed(1)}%',
                                          style: TextStyle(
                                            color: AppTheme.primaryColor,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              })
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.history,
                                color: AppTheme.primaryColor,
                                size: 24,
                              ),
                              SizedBox(
                                width: 16,
                              ),
                              Text(
                                'Recent Activity',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: AppTheme.txtPrimaryColor),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          ListView.builder(
                              itemCount: latestQuizzes.length,
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                final quiz = latestQuizzes[index].data()
                                    as Map<String, dynamic>;
                                return Padding(
                                  padding: EdgeInsets.only(bottom: 16),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryColor
                                              .withAlpha(45),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          Icons.quiz,
                                          color: AppTheme.primaryColor,
                                          size: 20,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 16,
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              quiz['title'],
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: AppTheme.txtPrimaryColor,
                                              ),
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              "Created on ${_formatDate(quiz['createdAt'].toDate())}",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color:
                                                    AppTheme.txtSecondaryColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              })
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.speed,
                                color: AppTheme.primaryColor,
                                size: 24,
                              ),
                              SizedBox(
                                width: 16,
                              ),
                              Text(
                                'Quiz Actions',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: AppTheme.txtPrimaryColor),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.9,
                            crossAxisSpacing: 12,
                            children: [
                              _buildDashboardCard(
                                  context, 'Quizzes', Icons.quiz, () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ManageQuizzesView(),
                                    ));
                              }),
                              _buildDashboardCard(
                                  context, 'Categories', Icons.category, () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ManageCategoriesView(),
                                    ));
                              }),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 28,
                  ),
                  Center(
                    child: SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {
                          _authService.signOut();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginView(),
                            ),
                          );
                        },
                        child: const Text(
                          "SignOut",
                          style: TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
