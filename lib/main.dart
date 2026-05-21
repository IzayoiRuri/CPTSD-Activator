import 'package:flutter/material.dart';
import 'models/task.dart';
import 'services/storage.dart';
import 'screens/home_screen.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.instance.init();
  runApp(const ActivateApp());
}

class ActivateApp extends StatelessWidget {
  const ActivateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '启动',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'system-ui',
        scaffoldBackgroundColor: AppTheme.backgroundForMode(AppMode.daily),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppTheme.accentForMode(AppMode.daily),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
