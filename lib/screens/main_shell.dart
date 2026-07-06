import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_colors.dart';
import 'assessment/assessment_intro_screen.dart';
import 'body_screen.dart';
import 'chat_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';

/// The 5-tab shell: Home, Assess, Marcus, Body, Profile.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _tabs = [
    HomeScreen(),
    AssessmentIntroScreen(),
    ChatScreen(),
    BodyScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.inkMuted,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(LucideIcons.house), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(LucideIcons.clipboardList), label: 'Assess'),
          BottomNavigationBarItem(
              icon: Icon(LucideIcons.messageCircle), label: 'Marcus'),
          BottomNavigationBarItem(
              icon: Icon(LucideIcons.heartPulse), label: 'Body'),
          BottomNavigationBarItem(
              icon: Icon(LucideIcons.user), label: 'Profile'),
        ],
      ),
    );
  }
}
