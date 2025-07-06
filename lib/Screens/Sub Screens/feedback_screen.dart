import 'package:flutter/material.dart';
import '../../services/feedback_service.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _feedbackController = TextEditingController();
  final _emailController = TextEditingController();
  String _feedbackType = 'feedback';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _feedbackController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      await FeedbackService.submitFeedback(
        feedbackType: _feedbackType,
        message: _feedbackController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
      );

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (error) {
      if (mounted) {
        _showErrorDialog(error.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thank You!'),
        content: Text(
          _feedbackType == 'feedback'
              ? 'Your feedback has been submitted successfully. We appreciate your input!'
              : 'Your suggestion has been submitted successfully. We\'ll consider it for future updates!',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Go back to profile
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text('Failed to submit ${_feedbackType}: $error'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback & Suggestions'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.comment_outlined,
                            color: theme.colorScheme.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'We Value Your Input',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Help us improve the app by sharing your feedback or suggestions. Your input is important to us!',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withAlpha(180),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Feedback Type Selection
              Text(
                'Type',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DropdownButtonFormField<String>(
                    value: _feedbackType,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'feedback',
                        child: Row(
                          children: [
                            Icon(Icons.feedback_outlined),
                            SizedBox(width: 12),
                            Text('Feedback'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'suggestion',
                        child: Row(
                          children: [
                            Icon(Icons.lightbulb_outline),
                            SizedBox(width: 12),
                            Text('Suggestion'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'bug_report',
                        child: Row(
                          children: [
                            Icon(Icons.bug_report_outlined),
                            SizedBox(width: 12),
                            Text('Bug Report'),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _feedbackType = value!;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Email Field
              Text(
                'Email (Optional)',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: 'Your email address',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 16),
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                      }
                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Message Field
              Text(
                'Message',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextFormField(
                    controller: _feedbackController,
                    maxLines: 6,
                    decoration: InputDecoration(
                      hintText: _feedbackType == 'feedback'
                          ? 'Tell us about your experience with the app...'
                          : _feedbackType == 'suggestion'
                              ? 'Share your ideas for improvement...'
                              : 'Describe the bug you encountered...',
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your ${_feedbackType}';
                      }
                      if (value.trim().length < 10) {
                        return 'Please provide more detailed information (at least 10 characters)';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitFeedback,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Submit ${_feedbackType == 'feedback' ? 'Feedback' : _feedbackType == 'suggestion' ? 'Suggestion' : 'Bug Report'}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Privacy Note
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                      theme.colorScheme.surfaceContainerHighest.withAlpha(100),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.outline.withAlpha(100),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.privacy_tip_outlined,
                      size: 20,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your feedback is valuable to us. We respect your privacy and will only use this information to improve our app.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
