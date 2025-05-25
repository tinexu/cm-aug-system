import 'package:flutter/material.dart';
import '../models/memory_item.dart';
import 'package:provider/provider.dart';
import '../providers/memory_provider_updated.dart';

class MemoryDetailScreen extends StatelessWidget {
  final MemoryItem memory;
  
  const MemoryDetailScreen({Key? key, required this.memory}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Memory Details'),
        actions: [
          // In your memory list item or memory detail screen
IconButton(
  icon: Icon(Icons.delete),
  onPressed: () {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Memory'),
        content: Text('Are you sure you want to delete this memory?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              
              // Delete memory
              Provider.of<MemoryProvider>(context, listen: false)
                  .deleteMemory(memory.id);
              
              // If in detail view, close it
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  },
),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              memory.title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            
            // Date and time
            Text(
              'Created on: ${_formatDate(memory.createdAt)}',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 24),
            
            // Content
            Container(
              padding: EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                memory.content,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
  
  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Memory'),
        content: Text('Are you sure you want to delete this memory?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Delete the memory
              Provider.of<MemoryProvider>(context, listen: false)
                  .deleteMemory(memory.id);
              
              // Close dialog and go back to home screen
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}