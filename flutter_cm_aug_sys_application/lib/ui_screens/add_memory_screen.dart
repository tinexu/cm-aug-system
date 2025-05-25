import 'package:flutter/material.dart';
import 'package:flutter_cm_aug_sys_application/features/context.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../providers/memory_provider_updated.dart';
import '../ui_screens/location_selection.dart';
import '../features/memory_service.dart';

class AddMemoryScreen extends StatefulWidget {
  @override
  _AddMemoryScreenState createState() => _AddMemoryScreenState();
}

class _AddMemoryScreenState extends State<AddMemoryScreen> with TickerProviderStateMixin {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final MemoryService _memoryService = MemoryService();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isLocationEnabled = false;
  String _currentLocation = 'No location selected';
  double? _latitude;
  double? _longitude;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      
      String address = 'Current location';
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        address = [
          place.street,
          place.locality,
          place.administrativeArea,
          place.country,
        ].where((element) => element != null && element.isNotEmpty)
            .join(', ');
      }
      
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _currentLocation = address;
        _isLocationEnabled = true;
      });
      
      _showSuccessSnackBar('Location captured successfully!');
    } catch (e) {
      _showErrorSnackBar('Could not get current location: $e');
    }
  }

  Future<void> _selectLocation() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => LocationSelectionScreen(
          initialLatitude: _latitude,
          initialLongitude: _longitude,
        ),
      ),
    );
    
    if (result != null) {
      setState(() {
        _latitude = result['latitude'];
        _longitude = result['longitude'];
        _currentLocation = result['address'];
        _isLocationEnabled = true;
      });
      _showSuccessSnackBar('Location selected!');
    }
  }

  void _saveMemory() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    
    if (title.isEmpty || content.isEmpty) {
      _showErrorSnackBar('Title and content are required');
      return;
    }
    
    setState(() {
      _isSaving = true;
    });
    
    try {
      // Save to your existing provider (for UI/storage)
      if (_isLocationEnabled && _latitude != null && _longitude != null) {
        Provider.of<MemoryProvider>(context, listen: false).addMemory(
          title,
          content,
          [],
          latitude: _latitude,
          longitude: _longitude,
          locationName: _currentLocation,
        );
        
        // Also save to context index with location data
        await _memoryService.saveMemoryWithContext(
          title,
          content,
          [],
          latitude: _latitude,
          longitude: _longitude,
          locationName: _currentLocation,
        );
      } else {
        Provider.of<MemoryProvider>(context, listen: false).addMemory(
          title,
          content,
          [],
        );
        
        // Save to context index without specific location
        await _memoryService.saveMemoryWithContext(title, content, []);
      }
      
      _showSuccessSnackBar('Memory saved successfully!');
      await Future.delayed(Duration(milliseconds: 500));
      Navigator.pop(context);
    } catch (e) {
      _showErrorSnackBar('Error saving memory: $e');
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _showCurrentContext() async {
    final contextService = ContextDetectionService();
    final currentContext = await contextService.getCurrentContext();
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.info_outline, color: Color(0xFF667eea)),
            SizedBox(width: 8),
            Text('Current Context'),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          height: 400,
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                currentContext.toString()
                  .replaceAll(', ', ',\n')
                  .replaceAll('{', '{\n  ')
                  .replaceAll('}', '\n}'),
                style: TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Close', style: TextStyle(color: Color(0xFF667eea))),
          ),
        ],
      ),
    );
  }

  void _showRelevantMemories() async {
    final relevantMemories = await _memoryService.getRelevantMemories();
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.psychology, color: Color(0xFF764ba2)),
            SizedBox(width: 8),
            Text('Relevant Memories'),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          height: 300,
          child: relevantMemories.isEmpty
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lightbulb_outline, size: 48, color: Colors.grey[400]),
                    SizedBox(height: 16),
                    Text(
                      'No relevant memories found',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Save some memories first!',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                )
              : ListView.builder(
                  itemCount: relevantMemories.length,
                  itemBuilder: (context, index) {
                    final memory = relevantMemories[index];
                    return Card(
                      margin: EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Color(0xFF667eea),
                          child: Text('${index + 1}'),
                        ),
                        title: Text(
                          memory.content.length > 50 
                              ? '${memory.content.substring(0, 50)}...'
                              : memory.content,
                          style: TextStyle(fontSize: 14),
                        ),
                        subtitle: Text(
                          '${memory.timestamp}',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Close', style: TextStyle(color: Color(0xFF764ba2))),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

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
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
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
                            'Capture Memory',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2c3e50),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.psychology, color: Color(0xFF764ba2)),
                              onPressed: _showRelevantMemories,
                              tooltip: 'Show relevant memories',
                            ),
                            IconButton(
                              icon: Icon(Icons.info_outline, color: Color(0xFF667eea)),
                              onPressed: _showCurrentContext,
                              tooltip: 'Show current context',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title Field
                          _buildTextField(
                            controller: _titleController,
                            label: 'Title',
                            hint: 'What happened?',
                            icon: Icons.title,
                            maxLines: 1,
                          ),
                          
                          SizedBox(height: 20),
                          
                          // Content Field
                          _buildTextField(
                            controller: _contentController,
                            label: 'Memory',
                            hint: 'Describe your experience in detail...',
                            icon: Icons.edit_note,
                            maxLines: 6,
                          ),
                          
                          SizedBox(height: 24),
                          
                          // Location Section
                          _buildLocationCard(),
                          
                          SizedBox(height: 32),
                          
                          // Save Button
                          _buildSaveButton(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required int maxLines,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: TextStyle(fontSize: 16, height: 1.4),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: Color(0xFF667eea)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Color(0xFF667eea), width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.all(20),
          labelStyle: TextStyle(color: Color(0xFF667eea)),
          hintStyle: TextStyle(color: Colors.grey[400]),
        ),
      ),
    );
  }

  Widget _buildLocationCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(0xFF667eea).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.location_on, color: Color(0xFF667eea)),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Location',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Color(0xFF2c3e50),
                        ),
                      ),
                      Text(
                        'Add context to your memory',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Transform.scale(
                  scale: 1.2,
                  child: Switch(
                    value: _isLocationEnabled,
                    activeColor: Color(0xFF667eea),
                    onChanged: (value) {
                      setState(() {
                        _isLocationEnabled = value;
                        if (!value) {
                          _latitude = null;
                          _longitude = null;
                          _currentLocation = 'No location selected';
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
            
            if (_isLocationEnabled) ...[
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFF667eea).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Color(0xFF667eea).withOpacity(0.2),
                    width: 1,
                  ),
                ),
                width: double.infinity,
                child: Row(
                  children: [
                    Icon(Icons.place, color: Color(0xFF667eea), size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _currentLocation,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF2c3e50),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.my_location, size: 20),
                      label: Text('Use Current'),
                      onPressed: _getCurrentLocation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF667eea),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: Icon(Icons.map, size: 20),
                      label: Text('Select on Map'),
                      onPressed: _selectLocation,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Color(0xFF667eea),
                        padding: EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Color(0xFF667eea), width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
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
        onPressed: _isSaving ? null : _saveMemory,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isSaving
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Saving Memory...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.save, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Save Memory',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}