import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_quiz_app/theme/theme.dart';
import 'package:smart_quiz_app/models/category.dart';
import 'package:smart_quiz_app/views/admin/add_category_view.dart';
import 'package:smart_quiz_app/views/admin/manage_quizzes_view.dart';

class ManageCategoriesView extends StatefulWidget {
  const ManageCategoriesView({super.key});
  @override
  State<ManageCategoriesView> createState() => _ManageCategoriesViewState();
}

class _ManageCategoriesViewState extends State<ManageCategoriesView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Manage Categories',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddCategoryView(),
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
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('categories').orderBy('name').snapshots(),
        builder: (
          context,
          snapshot,
        ) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error ${snapshot.error}'),
            );
          }
          // if (snapshot.connectionState == ConnectionState.waiting) {
          //   return Center(
          //     child: CircularProgressIndicator(),
          //   );
          // }
          if (!snapshot.hasData) {
            return Center(
              child: Text('No categories found'),
            );
          }
          final categories = snapshot.data!.docs
              .map((doc) => Category.fromMap(
                    doc.id,
                    doc.data() as Map<String, dynamic>,
                  ))
              .toList();
          if (categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.category,
                    size: 64,
                    color: AppTheme.txtSecondaryColor,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No categories found',
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
                            builder: (context) {
                              return AddCategoryView();
                            },
                          ),
                        );
                      },
                      child: Text('Add Category')),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final Category category = categories[index];
              return Card(
                margin: EdgeInsets.only(bottom: 12),
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ManageQuizzesView(
                                  categoryId: category.id,
                                  categoryName: category.name,
                                )));
                  },
                  contentPadding: EdgeInsets.all(16),
                  leading: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withAlpha(45),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.category,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  title: Text(
                    category.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    category.description,
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: ListTile(
                          leading: Icon(
                            Icons.edit,
                            color: AppTheme.primaryColor,
                          ),
                          title: Text('Edit'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(
                            Icons.delete,
                            color: Colors.redAccent,
                          ),
                          title: Text('Delete'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      _handleCategoryAction(context, value, category);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _handleCategoryAction(
    context,
    String action,
    Category category,
  ) async {
    if (action == 'edit') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddCategoryView(category: category),
        ),
      );
    } else if (action == 'delete') {
      // await _firestore.collection('categories').doc(category.id).delete();
      final confirm = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Delete Category!'),
          content: Text('Are you sure you want to delete this category?'),
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
        await _firestore.collection('categories').doc(category.id).delete();
      }
    }
  }
}
