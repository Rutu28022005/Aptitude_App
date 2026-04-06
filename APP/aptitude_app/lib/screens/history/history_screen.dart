import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/analytics_provider.dart';
import '../../models/result_model.dart';
import '../../utils/constants.dart';
import 'history_review_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    _loadResults();
  }
  
  Future<void> _loadResults() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final analyticsProvider = Provider.of<AnalyticsProvider>(context, listen: false);
    
    if (authProvider.currentUser != null) {
      await analyticsProvider.loadResults(authProvider.currentUser!.uid);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz History'),
      ),
      body: Consumer<AnalyticsProvider>(
        builder: (context, analyticsProvider, _) {
          if (analyticsProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (analyticsProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(analyticsProvider.errorMessage!),
                ],
              ),
            );
          }
          
          if (analyticsProvider.allResults.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.history,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No quiz history yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Take your first quiz to see results here',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }
          
          return RefreshIndicator(
            onRefresh: _loadResults,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: analyticsProvider.allResults.length,
              itemBuilder: (context, index) {
                final result = analyticsProvider.allResults[index];
                return _buildResultCard(result);
              },
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildResultCard(QuizResult result) {
    final color = result.accuracy >= AppConstants.excellentThreshold
        ? AppConstants.successColor
        : result.accuracy >= AppConstants.goodThreshold
            ? AppConstants.accentColor
            : result.accuracy >= AppConstants.averageThreshold
                ? AppConstants.warningColor
                : AppConstants.errorColor;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          _showDetailDialog(result);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Score circle
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.2),
                ),
                child: Center(
                  child: Text(
                    '${result.accuracy.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('MMM d, y • h:mm a').format(result.completedAt),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${result.score} correct answers',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      children: result.subjectWiseBreakdown.keys.map((subject) {
                        return Chip(
                          label: Text(
                            _abbreviateSubject(subject),
                            style: const TextStyle(fontSize: 10),
                          ),
                          visualDensity: VisualDensity.compact,
                          backgroundColor: AppConstants.getSubjectColor(subject)
                              .withOpacity(0.2),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showDetailDialog(QuizResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quiz Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Date', DateFormat('MMM d, y').format(result.completedAt)),
              _buildDetailRow('Time', DateFormat('h:mm a').format(result.completedAt)),
              _buildDetailRow('Score', '${result.score} correct'),
              _buildDetailRow('Accuracy', '${result.accuracy.toStringAsFixed(1)}%'),
              _buildDetailRow('Time Taken', '${result.timeTaken ~/ 60}m ${result.timeTaken % 60}s'),
              
              const SizedBox(height: 16),
              const Text(
                'Subject-wise Performance:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              
              ...result.subjectWiseBreakdown.entries.map((entry) {
                final subject = entry.key;
                final data = entry.value;
                final correct = data['correct'] ?? 0;
                final total = data['total'] ?? 0;
                final percentage = total > 0 ? (correct / total) * 100 : 0.0;
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_abbreviateSubject(subject)),
                      Text('$correct/$total (${percentage.toStringAsFixed(0)}%)'),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      HistoryReviewScreen(result: result),
                ),
              );
            },
            child: const Text('View Questions'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }
  
  String _abbreviateSubject(String subject) {
    if (subject.contains('Mathematics')) return 'Math';
    if (subject.contains('Logical')) return 'Reasoning';
    if (subject.contains('Verbal Ability')) return 'Verbal Ability';
    return subject;
  }
}
