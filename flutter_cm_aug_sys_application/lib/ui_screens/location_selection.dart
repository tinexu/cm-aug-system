import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationSelectionScreen extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;

  const LocationSelectionScreen({
    Key? key,
    this.initialLatitude,
    this.initialLongitude,
  }) : super(key: key);

  @override
  _LocationSelectionScreenState createState() => _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  String _addressText = 'Tap on the map to select a location';
  Marker? _marker;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // If initial location provided, use it
      if (widget.initialLatitude != null && widget.initialLongitude != null) {
        _selectedLocation = LatLng(widget.initialLatitude!, widget.initialLongitude!);
        _updateMarker(_selectedLocation!);
        _updateAddressFromLatLng(_selectedLocation!);
      } else {
        // Try to get current location
        try {
          final position = await Geolocator.getCurrentPosition();
          _selectedLocation = LatLng(position.latitude, position.longitude);
          _updateMarker(_selectedLocation!);
          _updateAddressFromLatLng(_selectedLocation!);
        } catch (e) {
          print("Location initialization error: $e");
          // Set default location if we can't get current location
          _selectedLocation = LatLng(37.7749, -122.4194); // San Francisco
          _updateMarker(_selectedLocation!);
          _addressText = 'Location services disabled. Tap to select location.';
        }
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _updateMarker(LatLng position) {
    setState(() {
      _marker = Marker(
        markerId: MarkerId('selected_location'),
        position: position,
        draggable: true,
        onDragEnd: (newPosition) {
          _selectedLocation = newPosition;
          _updateAddressFromLatLng(newPosition);
        },
      );
    });
  }

  Future<void> _updateAddressFromLatLng(LatLng position) async {
    setState(() {
      _addressText = 'Finding address...';
    });

    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        setState(() {
          _addressText = [
            place.street,
            place.locality,
            place.administrativeArea,
            place.country,
          ].where((element) => element != null && element.isNotEmpty)
              .join(', ');
        });
      } else {
        setState(() {
          _addressText = 'Address not found for this location';
        });
      }
    } catch (e) {
      setState(() {
        _addressText = 'Could not determine address';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Location'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: _selectedLocation == null
                ? null
                : () {
                    // Return the selected location and address
                    Navigator.pop(
                      context,
                      {
                        'latitude': _selectedLocation!.latitude,
                        'longitude': _selectedLocation!.longitude,
                        'address': _addressText,
                      },
                    );
                  },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Map
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _selectedLocation ?? LatLng(37.7749, -122.4194),
                    zoom: 15,
                  ),
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  markers: _marker != null ? {_marker!} : {},
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  onTap: (position) {
                    setState(() {
                      _selectedLocation = position;
                    });
                    _updateMarker(position);
                    _updateAddressFromLatLng(position);
                  },
                ),
          
          // Address display at bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selected Location:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(_addressText),
                  SizedBox(height: 8),
                  Text(
                    _selectedLocation != null
                        ? 'Coordinates: ${_selectedLocation!.latitude.toStringAsFixed(6)}, ${_selectedLocation!.longitude.toStringAsFixed(6)}'
                        : 'No location selected',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}