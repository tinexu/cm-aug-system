import 'package:sensors_plus/sensors_plus.dart';
import '../features/location.dart';
import 'dart:math' as math;

import 'work_context.dart';

class ContextDetectionService {
  final LocationService _locationService = LocationService();
  final WorkContextService _workContextService = WorkContextService();

  Future<String> detectActivity() async {
  try {
    final accelerometerEvent = await accelerometerEvents.first.timeout(Duration(seconds: 2));
    
    double magnitude = math.sqrt(
      accelerometerEvent.x * accelerometerEvent.x +
      accelerometerEvent.y * accelerometerEvent.y +
      accelerometerEvent.z * accelerometerEvent.z
    );
    
    // Very basic activity detection
    if (magnitude > 15) {
      return 'moving';
    } else if (magnitude > 10) {
      return 'walking';
    } else {
      return 'stationary';
    }
  } catch (e) {
    print('Error detecting activity: $e');
    return 'unknown'; // Fallback value
  }
}

Map<String, dynamic> _getWorkContext() {
  final now = DateTime.now();
  final hour = now.hour;
  final isWeekday = now.weekday >= 1 && now.weekday <= 5;
  final isWorkHours = hour >= 9 && hour <= 17;
  
  String workState = 'personal';
  if (isWeekday && isWorkHours) {
    workState = 'work';
  } else if (isWeekday && (hour >= 18 && hour <= 22)) {
    workState = 'overtime';
  } else if (!isWeekday && isWorkHours) {
    workState = 'weekend_work';
  }
  
  return {
    'workState': workState,
    'contextType': _determineContextType(workState, hour),
    'productivityZone': _getProductivityZone(hour),
  };
}

String _determineContextType(String workState, int hour) {
  if (workState == 'personal') return 'personal';
  
  if (hour >= 9 && hour <= 11) return 'morning_focus';
  if (hour >= 14 && hour <= 16) return 'afternoon_work';
  if (hour >= 19 && hour <= 21) return 'evening_coding';
  
  return 'work_general';
}

String _getProductivityZone(int hour) {
  if (hour >= 9 && hour <= 11) return 'peak_morning';
  if (hour >= 14 && hour <= 16) return 'peak_afternoon';
  if (hour >= 19 && hour <= 21) return 'evening_focus';
  return 'low_energy';
}
  
  Future<Map<String, dynamic>> getCurrentContext() async {
  final timestamp = DateTime.now();
  final position = await _locationService.getCurrentPosition();
  final activity = await detectActivity();
  final workContext = _getWorkContext();
  
  String? locationName;
  if (position != null) {
    locationName = await _locationService.getAddressFromCoordinates(
      position.latitude,
      position.longitude
    );
  }
  
  return {
  'timestamp': timestamp,
  'location': position != null ? {
    'latitude': position.latitude,
    'longitude': position.longitude,
    'address': locationName,
  } : null,
  'activity': activity,
  'timeContext': {
    'hour': timestamp.hour,
    'isWorkHours': timestamp.hour >= 9 && timestamp.hour <= 17 && 
                 timestamp.weekday >= 1 && timestamp.weekday <= 5,
    'isWeekend': timestamp.weekday == 6 || timestamp.weekday == 7,
  },
  'workContext': workContext, 
};
}
}