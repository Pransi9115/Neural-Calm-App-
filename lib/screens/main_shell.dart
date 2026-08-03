import 'package:flutter/material.dart';
import '../widgets/calm_nav_bar.dart';
import 'assessment/assessment_intro_screen.dart';
import 'body_screen.dart';
import 'chat_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  static const _tabs = [
    HomeScreen(),
    AssessmentIntroScreen(),
    ChatScreen(),
    BodyScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Rebuilds whenever any screen changes calmTabIndex.
    return ValueListenableBuilder<int>(
      valueListenable: calmTabIndex,
      builder: (context, index, _) => Scaffold(
        body: IndexedStack(index: index, children: _tabs),
        bottomNavigationBar: const CalmNavBar(),
      ),
    );
  }
}
