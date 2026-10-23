import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'providers/app_state.dart';
import 'screens/how_it_works_screen.dart';
import 'screens/price_trends_screen.dart';
import 'screens/scan_screen.dart';
import 'screens/today_screen.dart';
import 'screens/what_to_do_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const KalakalVisionApp());
}

class KalakalVisionApp extends StatefulWidget {
  const KalakalVisionApp({super.key});

  @override
  State<KalakalVisionApp> createState() => _KalakalVisionAppState();
}

class _KalakalVisionAppState extends State<KalakalVisionApp> {
  final AppState _appState = AppState();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _appState,
      builder: (context, child) {
        return MaterialApp(
          title: 'KalakalVision',
          debugShowCheckedModeBanner: false,
          themeMode: _appState.themeMode,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: MainNavigationShell(appState: _appState),
        );
      },
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  final AppState appState;

  const MainNavigationShell({super.key, required this.appState});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  void _navigateToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final pages = [
      TodayScreen(appState: widget.appState, onNavigateTab: _navigateToTab),
      ScanScreen(appState: widget.appState),
      WhatToDoScreen(appState: widget.appState),
      PriceTrendsScreen(appState: widget.appState),
      HowItWorksScreen(appState: widget.appState),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _navigateToTab,
        elevation: 8,
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        indicatorColor: AppColors.primary.withAlpha(40),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.today_outlined),
            selectedIcon: Icon(Icons.today_rounded, color: AppColors.primary),
            label: 'Today',
          ),
          NavigationDestination(
            icon: Icon(Icons.camera_alt_outlined),
            selectedIcon: Icon(Icons.camera_alt_rounded, color: AppColors.primary),
            label: 'Scan',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights_rounded, color: AppColors.primary),
            label: 'What to Do',
          ),
          NavigationDestination(
            icon: Icon(Icons.trending_up_outlined),
            selectedIcon: Icon(Icons.trending_up_rounded, color: AppColors.primary),
            label: 'Price Trends',
          ),
          NavigationDestination(
            icon: Icon(Icons.schema_outlined),
            selectedIcon: Icon(Icons.schema_rounded, color: AppColors.primary),
            label: 'How It Works',
          ),
        ],
      ),
    );
  }
}
