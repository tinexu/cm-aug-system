import 'package:flutter/material.dart';
import 'package:flutter_cm_aug_sys_application/ui_screens/map.dart';
import 'package:provider/provider.dart';
import '../providers/memory_provider_updated.dart';
import 'add_memory_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showMapView = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF667eea).withOpacity(0.1),
              Colors.white,
              Colors.white,
            ],
            stops: [0.0, 0.3, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              Container(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios, color: Color(0xFF667eea)),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        _showMapView ? 'Memory Map' : 'Your Memories',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2c3e50),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      icon: Icon(_showMapView ? Icons.list : Icons.map, color: Color(0xFF667eea)),
                      onPressed: () {
                        setState(() {
                          _showMapView = !_showMapView;
                        });
                      },
                      tooltip: _showMapView ? 'Switch to List View' : 'Switch to Map View',
                    ),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: Consumer<MemoryProvider>(
                  builder: (context, memoryProvider, child) {
                    final memories = memoryProvider.memories;
                    
                    if (memories.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.memory_outlined,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 24),
                            Text(
                              'No memories yet',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Start capturing your thoughts and experiences',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[500],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 32),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => AddMemoryScreen()),
                                );
                              },
                              icon: Icon(Icons.add),
                              label: Text('Add Your First Memory'),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    // Show Map View or List View based on toggle
                    return _showMapView ? _buildMapView(memories) : _buildListView(memories);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddMemoryScreen()),
          );
        },
        icon: Icon(Icons.add),
        label: Text('Add Memory'),
        backgroundColor: Color(0xFF667eea),
      ),
    );
  }
  
  Widget _buildListView(List<dynamic> memories) {
    return Column(
      children: [
        // Header Stats
        Container(
          margin: EdgeInsets.all(16),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(
                    '${memories.length}',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Memories',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
              Container(
                height: 40,
                width: 1,
                color: Colors.white.withOpacity(0.3),
              ),
              Column(
                children: [
                  Text(
                    '${_getLocationsCount(memories)}',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Locations',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Memories List
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: memories.length,
            itemBuilder: (context, index) {
              final memory = memories[index];
              return Card(
                margin: EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              memory.title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                          ),
                          if (memory.latitude != null)
                            Icon(
                              Icons.location_on,
                              size: 16,
                              color: Colors.grey[500],
                            ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        memory.content.length > 100 
                            ? '${memory.content.substring(0, 100)}...'
                            : memory.content,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            '${memory.createdAt.day}/${memory.createdAt.month}/${memory.createdAt.year}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                          Spacer(),
                          TextButton(
                            onPressed: () {
                              _showMemoryDetails(context, memory);
                            },
                            child: Text('View'),
                          ),
                          SizedBox(width: 8),
                          TextButton(
                            onPressed: () {
                              _showDeleteConfirmation(context, Provider.of<MemoryProvider>(context, listen: false), memory);
                            },
                            child: Text(
                              'Delete',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildMapView(List<dynamic> memories) {
    final memoriesWithLocation = memories.where((memory) => memory.latitude != null).toList();
    
    if (memoriesWithLocation.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off,
              size: 80,
              color: Colors.grey[400],
            ),
            SizedBox(height: 24),
            Text(
              'No memories with location',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Enable location when adding memories to see them on the map',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    return Column(
      children: [
        // Stats header
        Container(
          margin: EdgeInsets.all(16),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Icon(Icons.location_on, color: Colors.white, size: 28),
                  SizedBox(height: 8),
                  Text(
                    '${memoriesWithLocation.length}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Located',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
              Container(
                height: 40,
                width: 1,
                color: Colors.white.withOpacity(0.3),
              ),
              Column(
                children: [
                  Icon(Icons.explore, color: Colors.white, size: 28),
                  SizedBox(height: 8),
                  Text(
                    '${_getUniqueAreas(memoriesWithLocation)}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Areas',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Mini map preview
        Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  // Mock map background with memory locations
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFE3F2FD),
                          Color(0xFFBBDEFB),
                          Color(0xFF90CAF9),
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Decorative elements to make it look map-like
                        ...List.generate(8, (index) {
                          return Positioned(
                            left: (index * 47.0) % 300,
                            top: (index * 83.0) % 400,
                            child: Container(
                              width: 2,
                              height: 20,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                          );
                        }),
                        
                        // Memory markers
                        ...memoriesWithLocation.take(5).map((memory) {
                          final index = memoriesWithLocation.indexOf(memory);
                          return Positioned(
                            left: 50.0 + (index * 60.0),
                            top: 80.0 + (index * 40.0) % 200,
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Color(0xFF667eea),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFF667eea).withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.memory,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                  
                  // Overlay with info
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                        stops: [0.6, 1.0],
                      ),
                    ),
                  ),
                  
                  // Content overlay
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Memory Map',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Explore ${memoriesWithLocation.length} memories across different locations',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 16),
                        
                        // Recent memory locations
                        ...memoriesWithLocation.take(3).map((memory) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    memory.locationName ?? 'Unknown location',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        // Open full map button
        Container(
          margin: EdgeInsets.all(16),
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF667eea).withOpacity(0.4),
                blurRadius: 15,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => MemoryMapScreen()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.map, color: Colors.white),
                SizedBox(width: 12),
                Text(
                  'Open Full Map',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, color: Colors.white, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  int _getUniqueAreas(List<dynamic> memoriesWithLocation) {
    if (memoriesWithLocation.isEmpty) return 0;
    
    // Simple approximation - group by rough location areas
    final areas = <String>{};
    for (final memory in memoriesWithLocation) {
      if (memory.locationName != null) {
        // Extract city or area from location name
        final parts = memory.locationName!.split(',');
        if (parts.isNotEmpty) {
          areas.add(parts.last.trim());
        }
      }
    }
    return areas.length;
  }
  
  void _showMemoryDetails(BuildContext context, dynamic memory) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(memory.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (memory.locationName != null) ...[
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    SizedBox(width: 4),
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
                SizedBox(height: 8),
              ],
              Row(
                children: [
                  Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 4),
                  Text(
                    '${memory.createdAt.day}/${memory.createdAt.month}/${memory.createdAt.year} at ${memory.createdAt.hour}:${memory.createdAt.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                memory.content,
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
  
  void _showDeleteConfirmation(BuildContext context, dynamic provider, dynamic memory) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Memory'),
        content: Text('Are you sure you want to delete "${memory.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteMemory(memory.id);
              Navigator.of(ctx).pop();
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  
  int _getLocationsCount(List<dynamic> memories) {
    return memories.where((memory) => memory.latitude != null).length;
  }
}