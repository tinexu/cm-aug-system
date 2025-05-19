import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'models/memory_item.dart';
import 'providers/memory_provider.dart';
import 'ui_screens/home.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register Hive adapters
  Hive.registerAdapter(MemoryItemAdapter());
  
  // Open Hive boxes
  await Hive.openBox<MemoryItem>('memories');
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MemoryProvider>(
      create: (context) => MemoryProvider(),
      child: MaterialApp(
        title: 'Memory Augment',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          useMaterial3: true,
        ),
        home: HomeScreen(),
      ),
    );
  }
}