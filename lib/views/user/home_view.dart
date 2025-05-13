import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_quiz_app/models/category.dart';
import 'package:smart_quiz_app/models/game.dart';
import 'package:smart_quiz_app/services/auth_services.dart';
import 'package:smart_quiz_app/theme/theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:smart_quiz_app/views/games_screens/flappy_bird.dart';
import 'package:smart_quiz_app/views/games_screens/snake_game.dart';
import 'package:smart_quiz_app/views/games_screens/xo_game.dart';
import 'package:smart_quiz_app/views/login_view.dart';
import 'package:smart_quiz_app/views/user/category_view.dart';

final AuthService _authService = AuthService();

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final TextEditingController _searchController = TextEditingController();
  List<Category> _allCategories = [];
  List<Category> _filteredCategories = [];
  final List<GameModel> _games = [
    GameModel(
        "Snake Game",
        "Eat the food and grow your snake, but don’t hit the walls or yourself!",
        "assets/games/snake.png"),
    GameModel("fluby bird", "Tap to fly and dodge the pipes to keep going!",
        "assets/games/flappy_bird.png"),
    GameModel("Xo Game", "Take turns placing X or O to get three in a row!",
        "assets/games/xo game.png"),
  ];
  List<String> _categoryFilters = ['All'];
  String _selectedFilter = 'All';
  @override
  void initState() {
    _fetchCategories();
    super.initState();
  }

  Future<void> _fetchCategories() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('categories')
        .orderBy('createdAt', descending: true)
        .get();

    setState(() {
      _allCategories = snapshot.docs
          .map((doc) => Category.fromMap(doc.id, doc.data()))
          .toList();

      _categoryFilters = ['All'] +
          _allCategories.map((category) => category.name).toSet().toList();

      _filteredCategories = _allCategories;
    });
  }

  void _filterCategories(String query, {String? categoryFilter}) {
    setState(() {
      _filteredCategories = _allCategories.where((category) {
        final matchesSearch = category.name
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            category.description.toLowerCase().contains(query.toLowerCase());

        final matchesCategory = categoryFilter == null ||
            categoryFilter == "All" ||
            category.name.toLowerCase() == categoryFilter.toLowerCase();

        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.txtSecondaryColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 235,
            centerTitle: true,
            pinned: true,
            floating: true,
            backgroundColor: AppTheme.primaryColor,
            elevation: 100,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            title: Text(
              'Edu Game',
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: SafeArea(
                child: Column(
                  children: [
                    SizedBox(height: kToolbarHeight + 16),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome, Learner!',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            // ignore: unnecessary_string_escapes
                            "Let\s test your knowledge today!",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white70,
                            ),
                          ),
                          SizedBox(height: 16),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black45,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _searchController,
                              onChanged: (value) => _filterCategories(value),
                              decoration: InputDecoration(
                                hintText: 'Search categories ...',
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: AppTheme.primaryColor,
                                ),
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                        onPressed: () {
                                          _searchController.clear();
                                          _filterCategories('');
                                        },
                                        icon: Icon(Icons.clear),
                                        color: AppTheme.primaryColor)
                                    : null,
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              collapseMode: CollapseMode.pin,
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.all(16),
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _categoryFilters.length,
                itemBuilder: (context, index) {
                  final filter = _categoryFilters[index];
                  return Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        filter,
                        style: TextStyle(
                            color: _selectedFilter == filter
                                ? Colors.white
                                : AppTheme.primaryColor),
                      ),
                      selected: _selectedFilter == filter,
                      selectedColor: AppTheme.primaryColor,
                      backgroundColor: Colors.white,
                      onSelected: (bool selected) {
                        setState(
                          () {
                            _selectedFilter = filter;
                            _filterCategories(_searchController.text,
                                categoryFilter: filter);
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.all(16),
            sliver: _filteredCategories.isEmpty
                ? SliverToBoxAdapter(
                    child: Center(
                      child: Text(
                        'No categories found.',
                        style: TextStyle(color: AppTheme.txtSecondaryColor),
                      ),
                    ),
                  )
                : SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 500.0,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _filteredCategories.length,
                            itemBuilder: (context, index) => _buildCategoryCard(
                                _filteredCategories[index], index),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "Games Section",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          height: 500.0,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _games.length,
                            itemBuilder: (context, index) =>
                                _buildGameCard(_games[index], index),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(22),
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(Category category, int index) {
    return Card(
      color: Colors.orange,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoryView(category: category),
            ),
          );
        },
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withAlpha(45),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: index == 0
                    ? Image.network(
                        "assets/science.png",
                        height: 300,
                        width: 300,
                      )
                    : index == 1
                        ? Image.network("assets/ict.png",
                            height: 300, width: 300)
                        : index == 2
                            ? Image.network("assets/english.png",
                                height: 300, width: 300)
                            : index == 3
                                ? Image.network(
                                    "assets/math.png",
                                    height: 300,
                                    width: 300,
                                  )
                                : null,
              ),
              SizedBox(height: 16),
              Text(
                category.name,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                category.description,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
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
        .slideY(begin: 0.5, end: 0, duration: Duration(milliseconds: 300))
        .fadeIn();
  }

  Widget _buildGameCard(GameModel category, int index) {
    return Card(
      color: Colors.orange,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SnakeGame(),
              ),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FlappyBirdPage(),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TicTacToeGame(),
              ),
            );
          }
        },
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withAlpha(45),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.network(
                  category.image,
                  height: 300,
                  width: 300,
                ),
              ),
              SizedBox(height: 16),
              Text(
                category.name,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                category.description,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
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
        .slideY(begin: 0.5, end: 0, duration: Duration(milliseconds: 300))
        .fadeIn();
  }
}
