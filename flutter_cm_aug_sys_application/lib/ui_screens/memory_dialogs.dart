import 'package:flutter/material.dart';
import 'package:flutter_cm_aug_sys_application/ui_screens/memory_list_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import '../models/memory_item.dart';
import '../ui_screens/single_memory_map.dart' as prefix;

void showMemoryDetail(BuildContext context, MemoryItem memory) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(memory.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(memory.content),
            SizedBox(height: 16),
            Text(
              'Created on: ${DateFormat('MMM dd, yyyy - HH:mm').format(memory.createdAt)}',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            if (memory.latitude != null && memory.longitude != null) ...[
              SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      memory.locationName ?? 'Location added',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Container(
                height: 180,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(memory.latitude!, memory.longitude!),
                      zoom: 15,
                    ),
                    markers: {
                      Marker(
                        markerId: MarkerId('memory_location'),
                        position: LatLng(memory.latitude!, memory.longitude!),
                      ),
                    },
                    myLocationEnabled: false,
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                    scrollGesturesEnabled: false,
                    zoomGesturesEnabled: false,
                    tiltGesturesEnabled: false,
                    rotateGesturesEnabled: false,
                    liteModeEnabled: true,
                  ),
                ),
              ),
              SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  icon: Icon(Icons.open_in_new, size: 16),
                  label: Text('View Full Map'),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    textStyle: TextStyle(fontSize: 12),
                  ),
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    
                    // Navigate to map screen focused on this memory
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SingleMemoryMapScreen(memory: memory),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Close'),
        ),
      ],
    ),
  );
}