import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class KidsWindow extends StatefulWidget {
  const KidsWindow({super.key});

  @override
  State<KidsWindow> createState() => _KidsWindowState();
}

class _KidsWindowState extends State<KidsWindow> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<KidsPost> _posts = [];
  List<KidsPost> _filteredPosts = [];
  String _selectedFilter = 'All';
  final Set<String> _completedQuizzes = {};
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  bool _isLoading = true;
  String? _errorMessage;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    // Get the current user ID
    final user = _supabase.auth.currentUser;
    if (user == null) {
      setState(() {
        _errorMessage = 'Please sign in to track your progress';
        _isLoading = false;
      });
      return;
    }

    _userId = user.id;
    await _loadPosts();
    await _loadCompletedQuizzes();
  }

  Future<void> _loadPosts() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final response = await _supabase
          .from('kids_posts')
          .select()
          .order('created_at', ascending: false);

      final posts =
          (response as List).map((data) => KidsPost.fromJson(data)).toList();

      setState(() {
        _posts = posts;
        _filteredPosts = posts;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load posts. Please try again later.';
        _isLoading = false;
      });
      debugPrint('Error loading kids posts: $e');
    }
  }

  Future<void> _loadCompletedQuizzes() async {
    if (_userId == null) return;

    try {
      final response = await _supabase
          .from('kids_quiz_completions')
          .select('post_id')
          .eq('user_id', _userId!);

      final completedIds =
          (response as List).map((data) => data['post_id'] as String).toList();

      setState(() {
        _completedQuizzes.addAll(completedIds);
        _isLoading = false;
        _applyFilter(); // Apply the current filter after loading data
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load your progress';
        _isLoading = false;
      });
      debugPrint('Error loading completed quizzes: $e');
    }
  }

  Future<void> _refreshData() async {
    await _loadPosts();
    if (_userId != null) {
      await _loadCompletedQuizzes();
    }
  }

  Future<void> _markQuizAsComplete(String postId) async {
    if (_userId == null) return;

    try {
      await _supabase.from('kids_quiz_completions').upsert({
        'user_id': _userId,
        'post_id': postId,
      });

      setState(() {
        _completedQuizzes.add(postId);
        _applyFilter(); // Update filtered list when quiz is completed
      });
    } catch (e) {
      debugPrint('Error marking quiz as complete: $e');
      // Show error to user if needed
    }
  }

  void _showQuizDialog(BuildContext context, KidsPost post) {
    int? selectedAnswerIndex;
    bool showResult = false;
    bool isCorrect = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (_, dialogSetState) {
            Future<void> handleQuizSubmission() async {
              final correct = selectedAnswerIndex == post.correctAnswerIndex;
              dialogSetState(() {
                showResult = true;
                isCorrect = correct;
              });

              if (correct) {
                await Future.delayed(const Duration(seconds: 1));
                if (!mounted) return;
                Navigator.pop(dialogContext);
                if (!mounted) return;

                await _markQuizAsComplete(post.id);

                _scaffoldMessengerKey.currentState?.showSnackBar(
                  const SnackBar(
                    content: Text('Great job! You earned a star!'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            }

            return AlertDialog(
              title: const Text('Quiz Time!'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(post.quizQuestion),
                  const SizedBox(height: 16),
                  ...post.quizOptions.asMap().entries.map((entry) {
                    final index = entry.key;
                    final option = entry.value;
                    return RadioListTile<int>(
                      title: Text(option),
                      value: index,
                      groupValue: selectedAnswerIndex,
                      onChanged: (value) {
                        dialogSetState(() {
                          selectedAnswerIndex = value;
                        });
                      },
                    );
                  }),
                  if (showResult)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        isCorrect ? 'Correct! 🎉' : 'Oops! Try again!',
                        style: TextStyle(
                          color: isCorrect ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Close'),
                ),
                if (!showResult)
                  ElevatedButton(
                    onPressed: selectedAnswerIndex == null
                        ? null
                        : handleQuizSubmission,
                    child: const Text('Submit'),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  void _filterPosts(String filter) {
    setState(() {
      _selectedFilter = filter;
      _applyFilter();
    });
  }

  void _applyFilter() {
    switch (_selectedFilter) {
      case 'Completed':
        _filteredPosts = _posts
            .where((post) => _completedQuizzes.contains(post.id))
            .toList();
        break;
      case 'Pending':
        _filteredPosts = _posts
            .where((post) => !_completedQuizzes.contains(post.id))
            .toList();
        break;
      case 'All':
      default:
        _filteredPosts = _posts;
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Eco Kids Corner'),
          centerTitle: true,
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.filter_list),
              onSelected: _filterPosts,
              itemBuilder: (BuildContext context) {
                return [
                  'All',
                  'Completed',
                  'Pending',
                ].map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Row(
                      children: [
                        Icon(
                          choice == 'All'
                              ? Icons.apps
                              : choice == 'Completed'
                                  ? Icons.check_circle
                                  : Icons.pending,
                          size: 20,
                          color: _selectedFilter == choice
                              ? Theme.of(context).colorScheme.primary
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Text(choice),
                        if (_selectedFilter == choice) ...[
                          const Spacer(),
                          Icon(
                            Icons.check,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ],
                      ],
                    ),
                  );
                }).toList();
              },
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _refreshData,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_errorMessage!),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _initializeUser,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : _filteredPosts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _selectedFilter == 'Completed'
                                    ? Icons.check_circle_outline
                                    : _selectedFilter == 'Pending'
                                        ? Icons.pending_outlined
                                        : Icons.quiz_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _selectedFilter == 'Completed'
                                    ? 'No completed quizzes yet'
                                    : _selectedFilter == 'Pending'
                                        ? 'No pending quizzes'
                                        : 'No quizzes available',
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _selectedFilter == 'Completed'
                                    ? 'Complete some quizzes to earn stars!'
                                    : _selectedFilter == 'Pending'
                                        ? 'Great job! You\'ve completed all quizzes!'
                                        : 'Check back later for new content',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: _filteredPosts.length,
                          itemBuilder: (context, index) {
                            final post = _filteredPosts[index];
                            return _buildPostCard(context, post);
                          },
                        ),
        ),
      ),
    );
  }

  Widget _buildPostCard(BuildContext context, KidsPost post) {
    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Image.network(
            post.imageUrl,
            height: 200,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return SizedBox(
                height: 200,
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 200,
                color: Colors.grey[300],
                child: const Icon(Icons.broken_image,
                    size: 50, color: Colors.grey),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  post.category,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              post.content,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _showQuizDialog(context, post),
                  icon: const Icon(Icons.quiz, color: Colors.orange),
                  label: const Text(
                    'Take Quiz',
                    style: TextStyle(color: Colors.orange),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[50],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                if (_completedQuizzes.contains(post.id))
                  Row(
                    children: const [
                      Icon(Icons.star, color: Colors.amber),
                      SizedBox(width: 4),
                      Text(
                        'Completed',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class KidsPost {
  final String id;
  final String title;
  final String imageUrl;
  final String content;
  final String category;
  final String quizQuestion;
  final List<String> quizOptions;
  final int correctAnswerIndex;
  final DateTime createdAt;

  KidsPost({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.content,
    required this.category,
    required this.quizQuestion,
    required this.quizOptions,
    required this.correctAnswerIndex,
    required this.createdAt,
  });

  factory KidsPost.fromJson(Map<String, dynamic> json) {
    return KidsPost(
      id: json['id'] as String,
      title: json['title'] as String,
      imageUrl: json['image_url'] as String,
      content: json['content'] as String,
      category: json['category'] as String,
      quizQuestion: json['quiz_question'] as String,
      quizOptions: List<String>.from(json['quiz_options'] as List),
      correctAnswerIndex: json['correct_answer_index'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
