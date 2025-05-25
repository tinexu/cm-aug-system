import 'package:flutter/material.dart';
import 'package:flutter_cm_aug_sys_application/ui_screens/home.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'models/memory_item.dart';
import 'providers/memory_provider_updated.dart';
import 'ui_screens/add_memory_screen.dart';
import 'ui_screens/memory_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(MemoryItemAdapter());
  await Hive.openBox<MemoryItem>('memories');
  
  runApp(
    ChangeNotifierProvider(
      create: (context) => MemoryProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memory Augment',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      home: NewHomeScreen(),
    );
  }
}

// Brand new home screen defined directly in main.dart
class NewHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
              Color(0xFFf093fb),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Spacer(flex: 1),
                
                // Main Title with Animation
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.psychology,
                        size: 64,
                        color: Colors.white,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'fluffi',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Your intelligent memory companion',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w300,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                Spacer(flex: 1),
                
                // Stats Card
                Consumer<MemoryProvider>(
                  builder: (context, provider, child) {
                    return Container(
                      padding: EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                            icon: Icons.memory,
                            label: 'Memories',
                            value: '${provider.memories.length}',
                            color: Color(0xFF667eea),
                          ),
                          Container(
                            height: 40,
                            width: 1,
                            color: Colors.grey.withOpacity(0.3),
                          ),
                          _buildStatItem(
                            icon: Icons.timeline,
                            label: 'Contexts',
                            value: '${_getUniqueContexts(provider)}',
                            color: Color(0xFF764ba2),
                          ),
                          Container(
                            height: 40,
                            width: 1,
                            color: Colors.grey.withOpacity(0.3),
                          ),
                          _buildStatItem(
                            icon: Icons.flash_on,
                            label: 'Active',
                            value: _getActiveStatus(),
                            color: Color(0xFFf093fb),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                
                Spacer(flex: 1),
                
                // Action Buttons
                Column(
                  children: [
                    // Primary Action - Add Memory
                    Container(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => AddMemoryScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Color(0xFF667eea),
                          elevation: 8,
                          shadowColor: Colors.black.withOpacity(0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_circle_outline, size: 24),
                            SizedBox(width: 12),
                            Text(
                              'Capture Memory',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 16),
                    
                    // Secondary Action - View Memories
                    Container(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => HomeScreen()),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(color: Colors.white.withOpacity(0.7), width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.explore, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Explore Memories',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                
                Spacer(flex: 1),
                
                // Footer
                Text(
                  'Powered by contextual intelligence',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
  
  int _getUniqueContexts(MemoryProvider provider) {
    // This would calculate unique contexts - for now just return a sample
    return provider.memories.length > 0 ? (provider.memories.length / 2).ceil() : 0;
  }
  
  String _getActiveStatus() {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 12) return "Morning";
    if (hour >= 12 && hour < 17) return "Day";
    if (hour >= 17 && hour < 21) return "Evening";
    return "Night";
  }
}