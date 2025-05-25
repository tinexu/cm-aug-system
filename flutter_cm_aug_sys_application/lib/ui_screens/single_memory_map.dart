import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/memory_item.dart';

class SingleMemoryMapScreen extends StatelessWidget {
  final MemoryItem memory;
  
  const SingleMemoryMapScreen({super.key, required this.memory});
  
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