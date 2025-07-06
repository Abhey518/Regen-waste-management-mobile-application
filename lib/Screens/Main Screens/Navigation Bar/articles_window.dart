import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ArticlesWindow extends StatefulWidget {
  const ArticlesWindow({super.key});

  @override
  State<ArticlesWindow> createState() => _ArticlesWindowState();
}

class _ArticlesWindowState extends State<ArticlesWindow> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Article> _articles = [];
  List<Article> _filteredArticles = [];
  String _selectedCategory = 'All';
  final Set<String> _savedArticles = {};
  final Set<String> _likedArticles = {};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  Future<void> _loadArticles() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final response = await _supabase
          .from('articles')
          .select()
          .order('created_at', ascending: false);

      final articles =
          (response as List).map((data) => Article.fromJson(data)).toList();

      setState(() {
        _articles = articles;
        _filteredArticles = articles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load articles. Please try again later.';
        _isLoading = false;
      });
      debugPrint('Error loading articles: $e');
    }
  }

  void _filterArticles(String category) {
    setState(() {
      _selectedCategory = category;
      if (category == 'Saved') {
        _filteredArticles = _articles
            .where((article) => _savedArticles.contains(article.id))
            .toList();
      } else if (category == 'All') {
        _filteredArticles = _articles;
      } else {
        _filteredArticles =
            _articles.where((article) => article.category == category).toList();
      }
    });
  }

  void _toggleSaveArticle(String articleId) {
    setState(() {
      if (_savedArticles.contains(articleId)) {
        _savedArticles.remove(articleId);
      } else {
        _savedArticles.add(articleId);
      }

      if (_selectedCategory == 'Saved') {
        _filteredArticles = _articles
            .where((article) => _savedArticles.contains(article.id))
            .toList();
      }
    });
  }

  void _toggleLikeArticle(String articleId) {
    setState(() {
      if (_likedArticles.contains(articleId)) {
        _likedArticles.remove(articleId);
      } else {
        _likedArticles.add(articleId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Environment Articles', textAlign: TextAlign.center),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: _filterArticles,
            itemBuilder: (BuildContext context) {
              // Fixed categories only
              final allChoices = [
                'All',
                'Saved',
                'Informative',
                'Laws',
                'Sustainability',
              ];

              return allChoices.map((String choice) {
                IconData getIconForChoice(String choice) {
                  switch (choice.toLowerCase()) {
                    case 'all':
                      return Icons.apps;
                    case 'saved':
                      return Icons.bookmark;
                    case 'recycling':
                    case 'waste':
                      return Icons.recycling;
                    case 'environment':
                    case 'nature':
                      return Icons.nature;
                    case 'climate':
                    case 'weather':
                      return Icons.cloud;
                    case 'energy':
                      return Icons.bolt;
                    case 'water':
                      return Icons.water_drop;
                    case 'sustainability':
                      return Icons.eco;
                    case 'tips':
                    case 'advice':
                      return Icons.lightbulb;
                    case 'news':
                      return Icons.newspaper;
                    case 'technology':
                    case 'tech':
                      return Icons.settings;
                    case 'law':
                    case 'laws':
                    case 'legal':
                    case 'legislation':
                    case 'policy':
                    case 'regulation':
                      return Icons.gavel;
                    case 'informative':
                    case 'information':
                    case 'info':
                      return Icons.info;
                    case 'education':
                    case 'educational':
                      return Icons.school;
                    case 'research':
                      return Icons.science;
                    case 'guide':
                    case 'guidelines':
                      return Icons.map;
                    default:
                      return Icons.article;
                  }
                }

                return PopupMenuItem<String>(
                  value: choice,
                  child: Row(
                    children: [
                      Icon(
                        getIconForChoice(choice),
                        size: 20,
                        color: _selectedCategory == choice
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(choice)),
                      if (_selectedCategory == choice) ...[
                        const SizedBox(width: 8),
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
        onRefresh: _loadArticles,
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
                          onPressed: _loadArticles,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : _filteredArticles.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _selectedCategory == 'Saved'
                                  ? Icons.bookmark_border
                                  : Icons.article_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _selectedCategory == 'Saved'
                                  ? 'No saved articles yet'
                                  : _selectedCategory == 'All'
                                      ? 'No articles available'
                                      : 'No articles in $_selectedCategory',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _selectedCategory == 'Saved'
                                  ? 'Save articles by tapping the bookmark icon'
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
                        itemCount: _filteredArticles.length,
                        itemBuilder: (context, index) {
                          final article = _filteredArticles[index];
                          return _buildArticleCard(article);
                        },
                      ),
      ),
    );
  }

  Widget _buildArticleCard(Article article) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 3.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Article Image
          Image.network(
            article.imageUrl,
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

          // Article Title and Date
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  article.formattedDate,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Article Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(
              article.content,
              style: const TextStyle(fontSize: 14),
            ),
          ),

          // Like and Save buttons
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Like button (tree icon)
                InkWell(
                  onTap: () => _toggleLikeArticle(article.id),
                  child: Row(
                    children: [
                      Icon(
                        _likedArticles.contains(article.id)
                            ? Icons.nature
                            : Icons.nature_outlined,
                        color: _likedArticles.contains(article.id)
                            ? Colors.green
                            : Colors.grey,
                        size: 28,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _likedArticles.contains(article.id) ? 'Liked' : 'Like',
                        style: TextStyle(
                          color: _likedArticles.contains(article.id)
                              ? Colors.green
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                // Save button
                InkWell(
                  onTap: () => _toggleSaveArticle(article.id),
                  child: Row(
                    children: [
                      Icon(
                        _savedArticles.contains(article.id)
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                        color: _savedArticles.contains(article.id)
                            ? Colors.blue
                            : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _savedArticles.contains(article.id) ? 'Saved' : 'Save',
                        style: TextStyle(
                          color: _savedArticles.contains(article.id)
                              ? Colors.blue
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Article {
  final String id;
  final String title;
  final String imageUrl;
  final String content;
  final String category;
  final DateTime createdAt;

  Article({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.content,
    required this.category,
    required this.createdAt,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] as String,
      title: json['title'] as String,
      imageUrl: json['image_url'] as String,
      content: json['content'] as String,
      category: json['category'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  String get formattedDate {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }
}
