import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/memory_provider_updated.dart';
import '../models/memory_item.dart';

class MemoryMapScreen extends StatefulWidget {
  @override
  _MemoryMapScreenState createState() => _MemoryMapScreenState();
}

class _MemoryMapScreenState extends State<MemoryMapScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  bool _isMapLoading = true;
  
  @override
  void initState() {
    super.initState();
    _setupMarkers();
  }
  
  Future<void> _setupMarkers() async {
    setState(() {
      _isMapLoading = true;
    });
    
    // Get all memories from provider
    final memories = Provider.of<MemoryProvider>(context, listen: false).memories;
    
    // Create a marker for each memory with location data
    final newMarkers = <Marker>{};
    for (final memory in memories) {
      if (memory.latitude != null && memory.longitude != null) {
        newMarkers.add(
          Marker(
            markerId: MarkerId(memory.id),
            position: LatLng(memory.latitude!, memory.longitude!),
            onTap: () {
              _showMemoryDetail(memory);
            },
            // Remove infoWindow to prevent Google's default popup
          ),
        );
      }
    }
    
    setState(() {
      _markers = newMarkers;
      _isMapLoading = false;
    });
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
                  '${memory.createdAt.day}/${memory.createdAt.month}/${memory.createdAt.year} at ${memory.createdAt.hour}:${memory.createdAt.minute.toString().padLeft(2, '0')}',
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
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _getMapCenter(),
              zoom: 12,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
              setState(() {
                _isMapLoading = false;
              });
            },
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            mapToolbarEnabled: false,
            zoomControlsEnabled: false,
            style: '''
            [
              {
                "featureType": "poi",
                "elementType": "labels",
                "stylers": [{"visibility": "off"}]
              }
            ]
            ''',
          ),
          
          // Custom App Bar
          SafeArea(
            child: Container(
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios, color: Color(0xFF667eea)),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        'Memory Map',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2c3e50),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Color(0xFF667eea).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_markers.length}',
                        style: TextStyle(
                          color: Color(0xFF667eea),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Loading indicator
          if (_isMapLoading)
            Container(
              color: Colors.white.withOpacity(0.9),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Loading your memories...',
                      style: TextStyle(
                        color: Color(0xFF667eea),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
          // No locations message
          if (!_isMapLoading && _markers.isEmpty)
            Center(
              child: Container(
                margin: EdgeInsets.all(32),
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_off,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 20),
                    Text(
                      'No memories with locations yet',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2c3e50),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Add memories with location data to see them plotted here',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      
      // Custom floating action buttons - positioned to avoid Google's buttons
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 160), // Move up to avoid Google's buttons
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Refresh button
            FloatingActionButton(
              heroTag: "refresh",
              onPressed: _setupMarkers,
              backgroundColor: Colors.white,
              child: Icon(Icons.refresh, color: Color(0xFF667eea)),
              mini: true,
            ),
            SizedBox(height: 16),
            
            // Center on memories button
            if (_markers.isNotEmpty)
              FloatingActionButton(
                heroTag: "center",
                onPressed: _centerOnMemories,
                backgroundColor: Color(0xFF667eea),
                child: Icon(Icons.center_focus_strong, color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }
  
  void _centerOnMemories() {
    if (_markers.isEmpty || _mapController == null) return;
    
    if (_markers.length == 1) {
      // If only one marker, center on it
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(_markers.first.position, 15),
      );
    } else {
      // If multiple markers, show them all
      double minLat = _markers.map((m) => m.position.latitude).reduce((a, b) => a < b ? a : b);
      double maxLat = _markers.map((m) => m.position.latitude).reduce((a, b) => a > b ? a : b);
      double minLng = _markers.map((m) => m.position.longitude).reduce((a, b) => a < b ? a : b);
      double maxLng = _markers.map((m) => m.position.longitude).reduce((a, b) => a > b ? a : b);
      
      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(minLat, minLng),
            northeast: LatLng(maxLat, maxLng),
          ),
          100.0, // padding
        ),
      );
    }
  }
  
  LatLng _getMapCenter() {
    if (_markers.isNotEmpty) {
      // Center on the first marker
      return _markers.first.position;
    }
    
    // Default to Katy, Texas (your location!)
    return LatLng(29.7858, -95.8244);
  }
}