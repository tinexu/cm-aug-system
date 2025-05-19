import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/memory_item.dart';
import '../providers/memory_provider.dart';

class MemoryDetailScreen extends StatelessWidget {
  final MemoryItem memory;
  
  const MemoryDetailScreen({Key? key, required this.memory}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Memory Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text('Delete Memory'),
                  content: Text('Are you sure you want to delete this memory?'),
                  actions: [
                    TextButton(
                      child: Text('Cancel'),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                    ),
                    TextButton(
                      child: Text('Delete'),
                      onPressed: () {
                        Provider.of<MemoryProvider>(context, listen: false)
                            .deleteMemory(memory.id);
                        Navigator.of(ctx).pop();
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              memory.title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '${memory.createdAt.day}/${memory.createdAt.month}/${memory.createdAt.year} ${memory.createdAt.hour}:${memory.createdAt.minute.toString().padLeft(2, '0')}',
              style: TextStyle(color: Colors.grey),
            ),
            if (memory.latitude != null && memory.longitude != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Location: ${memory.latitude!.toStringAsFixed(6)}, ${memory.longitude!.toStringAsFixed(6)}',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            Divider(height: 32),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  memory.content,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}