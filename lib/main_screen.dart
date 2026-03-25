import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'core/theme/app_colors.dart';
import 'features/history/presentation/screens/history_screen.dart';
import 'features/magic_post/presentation/screens/magic_generator_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const MagicGeneratorScreen(),
    const HistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.white54,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.wand2),
            label: 'Magic',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.history),
            label: 'History',
          ),
        ],
      ),
    );
  }
}
