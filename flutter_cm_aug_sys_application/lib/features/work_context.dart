import 'dart:io';
import 'package:device_apps/device_apps.dart';
import 'package:url_launcher/url_launcher.dart';

class WorkContextService {
  
  // Detect what app is currently active (Android only - iOS is restricted)
  Future<String?> getCurrentApp() async {
    try {
      if (Platform.isAndroid) {
        // This would require additional permissions and native code
        // For now, we'll simulate or use app usage stats
        return 'unknown'; // Placeholder
      }
      return null;
    } catch (e) {
      print('Error detecting current app: $e');
      return null;
    }
  }
  
  // Detect work vs personal context based on time and patterns
  Map<String, dynamic> getWorkContext() {
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
      'isWorkDay': isWeekday,
      'isWorkHours': isWorkHours,
      'timeOfDay': _getTimeOfDay(hour),
      'productivityZone': _getProductivityZone(hour),
    };
  }
  
  String _getTimeOfDay(int hour) {
    if (hour >= 6 && hour < 12) return 'morning';
    if (hour >= 12 && hour < 17) return 'afternoon';
    if (hour >= 17 && hour < 21) return 'evening';
    return 'night';
  }
  
  String _getProductivityZone(int hour) {
    // Based on common productivity patterns
    if (hour >= 9 && hour <= 11) return 'peak_morning';
    if (hour >= 14 && hour <= 16) return 'peak_afternoon';
    if (hour >= 19 && hour <= 21) return 'evening_focus';
    return 'low_energy';
  }
  
  // Detect project context (this would integrate with your file system)
  Future<Map<String, dynamic>> getProjectContext() async {
    // This is where you'd detect:
    // - Git repository
    // - Project folder
    // - Recent files
    // - Current branch
    
    return {
      'projectName': null, // Would detect from git or folder structure
      'projectType': null, // Flutter, React, Python, etc.
      'gitBranch': null,   // Current git branch
      'recentFiles': [],   // Recently accessed files
    };
  }
  
  // Enhanced context that combines everything
  Future<Map<String, dynamic>> getEnhancedWorkContext() async {
    final workContext = getWorkContext();
    final projectContext = await getProjectContext();
    final currentApp = await getCurrentApp();
    
    return {
      ...workContext,
      ...projectContext,
      'currentApp': currentApp,
      'contextType': _determineContextType(workContext, currentApp),
    };
  }
  
  String _determineContextType(Map<String, dynamic> workContext, String? currentApp) {
    if (workContext['workState'] == 'personal') {
      return 'personal';
    }
    
    // Could expand this based on detected apps
    if (currentApp?.contains('code') == true || 
        currentApp?.contains('terminal') == true) {
      return 'coding';
    }
    
    if (currentApp?.contains('browser') == true) {
      return 'research';
    }
    
    if (currentApp?.contains('slack') == true || 
        currentApp?.contains('teams') == true) {
      return 'communication';
    }
    
    return 'work_general';
  }
}