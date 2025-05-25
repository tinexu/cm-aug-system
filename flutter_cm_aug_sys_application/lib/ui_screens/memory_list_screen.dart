import 'package:flutter/material.dart';
import 'package:flutter_cm_aug_sys_application/ui_screens/add_memory_screen.dart';
import 'package:flutter_cm_aug_sys_application/ui_screens/memory_dialogs.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/memory_provider_updated.dart';
import '../models/memory_item.dart';

class MemoryListScreen extends StatefulWidget {
  @override
  _MemoryListScreenState createState() => _MemoryListScreenState();
}

class _MemoryListScreenState extends State<MemoryListScreen> {
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _refreshMemories();
  }
  
  Future<void> _refreshMemories() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      Provider.of<MemoryProvider>(context, listen: false).refreshMemories();
    } catch (e) {
      print("Error refreshing memories: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Memories'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshMemories,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshMemories,
              child: Consumer<MemoryProvider>(
                builder: (context, memoryProvider, child) {
                  final memories = memoryProvider.memories;
                  
                  if (memories.isEmpty) {
                    return Center(
                      child: Text('No memories yet. Add your first memory!'),
                    );
                  }
                  
                  return ListView.builder(
                    itemCount: memories.length,
                    itemBuilder: (context, index) {
                      final memory = memories[index];
                      return Dismissible(
                        key: Key(memory.id),
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.only(right: 20),
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (direction) async {
                          return await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Delete Memory'),
                              content: Text('Are you sure you want to delete this memory?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text('Delete'),
                                ),
                              ],
                            ),
                          );
                        },
                        onDismissed: (direction) {
                          Provider.of<MemoryProvider>(context, listen: false)
                              .deleteMemory(memory.id);
                        },
                        child: ListTile(
                          title: Text(memory.title),
                          subtitle: Text(
                            memory.content.length > 50 
                                ? '${memory.content.substring(0, 50)}...'
                                : memory.content
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (memory.locationName != null)
                                Icon(Icons.location_on, size: 16, color: Colors.grey),
                              SizedBox(width: 8),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
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
                                            Navigator.pop(context);
                                            Provider.of<MemoryProvider>(context, listen: false)
                                                .deleteMemory(memory.id);
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
                          onTap: () => showMemoryDetail(context, memory),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddMemoryScreen()),
          );
          
          // Force refresh when returning from Add Memory screen
          _refreshMemories();
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _showMemoryDetail(MemoryItem memory) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 20),
            
            // Memory details
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(0xFF667eea).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.memory, color: Color(0xFF667eea)),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    memory.title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2c3e50),
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16),
            
            if (memory.locationName != null) ...[
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      memory.locationName!,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
            ],
            
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                SizedBox(width: 8),
                Text(
                  '${memory.createdAt.month}/${memory.createdAt.day}/${memory.createdAt.year} at ${memory.createdAt.hour}:${memory.createdAt.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16),
            
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              width: double.infinity,
              child: Text(
                memory.content,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: Color(0xFF2c3e50),
                ),
              ),
            ),
            
            SizedBox(height: 20),
            
            // Close button
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF667eea),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Close',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            
            // Add bottom padding for safe area
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }
}

class SingleMemoryMapScreen extends StatelessWidget {
  final MemoryItem memory;
  
  const SingleMemoryMapScreen({Key? key, required this.memory}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Memory Location'),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(memory.latitude!, memory.longitude!),
          zoom: 15,
        ),
        markers: {
          Marker(
            markerId: MarkerId('memory_location'),
            position: LatLng(memory.latitude!, memory.longitude!),
            infoWindow: InfoWindow(
              title: memory.title,
              snippet: memory.locationName ?? 'Memory location',
            ),
          ),
        },
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}
