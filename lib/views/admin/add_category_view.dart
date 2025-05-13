import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_quiz_app/models/category.dart';
import 'package:smart_quiz_app/theme/theme.dart';

class AddCategoryView extends StatefulWidget {
  final Category? category;
  const AddCategoryView({super.key, this.category});

  @override
  State<AddCategoryView> createState() => _AddCategoryViewState();
}

class _AddCategoryViewState extends State<AddCategoryView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name);
    _descriptionController =
        TextEditingController(text: widget.category?.description);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.category != null) {
        final updatedCategory = widget.category!.copyWith(
          name: _nameController.text.trim(),
        );

        await _firestore
            .collection('categories')
            .doc(widget.category!.id)
            .update(updatedCategory.toMap());

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Category updated successfully'),
          ),
        );
      } else {
        await _firestore.collection('categories').add(Category(
              id: _firestore.collection('categories').doc().id,
              name: _nameController.text.trim(),
              description: _descriptionController.text.trim(),
              createdAt: DateTime.now(),
            ).toMap());

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Category added successfully'),
        ));
      }
      Navigator.pop(context);
    } catch (e) {
      print('Errpr $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> _onWillPop() async {
    if (_nameController.text.isEmpty || _descriptionController.text.isEmpty) {
      return await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Discard Changes'),
              content: Text('Are you sure you want to discard changes?'),
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
                    'Discard',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),
              ],
            ),
          ) ??
          false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppTheme.backgroundColor,
          title: Text(
            widget.category != null ? 'Edit Category' : 'Add Category',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Category Details',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: AppTheme.txtPrimaryColor),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Create a new category',
                    style: TextStyle(
                        fontSize: 14, color: AppTheme.txtSecondaryColor),
                  ),
                  SizedBox(height: 18),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(vertical: 18),
                      labelText: 'Category Name',
                      hintText: 'Enter category name',
                      prefixIcon: Icon(
                        Icons.category,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Enter category name' : null,
                    textInputAction: TextInputAction.next,
                  ),
                  SizedBox(height: 18),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      labelText: 'Description',
                      hintText: 'Enter category description',
                      prefixIcon: Icon(
                        Icons.description,
                        color: AppTheme.primaryColor,
                      ),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 3,
                    validator: (value) =>
                        value!.isEmpty ? 'Enter category description' : null,
                    textInputAction: TextInputAction.next,
                  ),
                  SizedBox(height: 24),
                  SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveCategory,
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
                              widget.category != null
                                  ? 'Update Category'
                                  : 'Add Category',
                              style: TextStyle(fontSize: 16,
                              fontWeight: FontWeight.bold
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
