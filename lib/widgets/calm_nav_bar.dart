import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_colors.dart';

/// Which tab the shell is currently showing.
/// Lives outside the widget tree so ANY screen can change it,
/// including full-screen pages pushed on top of MainShell.
final ValueNotifier<int> calmTabIndex = ValueNotifier<int>(0);

/// The app's bottom navigation bar.
///
/// Used by MainShell AND by pages that are pushed over it
/// (assessment, report), so navigation is available everywhere.
class CalmNavBar extends StatelessWidget {
  const CalmNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: calmTabIndex,
      builder: (context, index, _) => BottomNavigationBar(
        currentIndex: index,
        onTap: (i) {
          calmTabIndex.value = i;
          // If this bar is on a pushed page, go back to the shell first.
          Navigator.of(context).popUntil((r) => r.isFirst);
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.navy,
        selectedItemColor: Colors.white,
        unselectedItemColor: AppColors.onNavy,
        // 10px so the longer labels fit on narrow phones.
        selectedFontSize: 10,
        unselectedFontSize: 10,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(LucideIcons.house), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(LucideIcons.clipboardList), label: 'Assess'),
          BottomNavigationBarItem(
              icon: Icon(LucideIcons.messageCircle), label: 'Calm Coach'),
          BottomNavigationBarItem(
              icon: Icon(LucideIcons.heartPulse), label: 'Monitoring'),
          BottomNavigationBarItem(
              icon: Icon(LucideIcons.user), label: 'Profile'),
        ],
      ),
    );
  }
}
