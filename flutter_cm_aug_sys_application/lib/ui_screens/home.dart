import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_cm_aug_sys_application/providers/memory_provider.dart';
import 'package:flutter_cm_aug_sys_application/models/memory_item.dart';
import 'add_memory_screen.dart';
import 'memory_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Memory Augment'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // TODO: Navigate to settings screen
            },
          ),
        ],
      ),
      body: Consumer<MemoryProvider>(
        builder: (context, memoryProvider, child) {
          final memories = memoryProvider.memories;
          
          if (memories.isEmpty) {
            return Center(
              child: Text(
                'No memories yet. Tap + to add one!',
                style: TextStyle(fontSize: 18),
              ),
            );
          }
          
          return ListView.builder(
            itemCount: memories.length,
            itemBuilder: (context, index) {
              final memory = memories[index];
              return MemoryListItem(memory: memory);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddMemoryScreen()),
          );
        },
      ),
    );
  }
}

class MemoryListItem extends StatelessWidget {
  final MemoryItem memory;
  
  const MemoryListItem({Key? key, required this.memory}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(memory.title),
        subtitle: Text(
          memory.content,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          '${memory.createdAt.day}/${memory.createdAt.month}/${memory.createdAt.year}',
          style: TextStyle(color: Colors.grey),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MemoryDetailScreen(memory: memory),
            ),
          );
        },
      ),
    );
  }
}