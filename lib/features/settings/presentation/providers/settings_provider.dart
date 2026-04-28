import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);
final defaultViewModeProvider = StateProvider<String>((ref) => 'grid');

/// Loads persisted settings at startup
class SettingsService {
  static Future<void> load(WidgetRef ref) async {
    final prefs = await SharedPreferences.getInstance();
    final theme = prefs.getString(StorageKeys.themeMode) ?? 'dark';
    final view = prefs.getString(StorageKeys.viewMode) ?? 'grid';

    final themeMode = theme == 'light'
        ? ThemeMode.light
        : theme == 'system'
            ? ThemeMode.system
            : ThemeMode.dark;

    ref.read(themeModeProvider.notifier).state = themeMode;
    ref.read(defaultViewModeProvider.notifier).state = view;
  }

  static Future<void> saveTheme(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    final label = mode == ThemeMode.light ? 'light' : mode == ThemeMode.system ? 'system' : 'dark';
    await prefs.setString(StorageKeys.themeMode, label);
  }

  static Future<void> saveViewMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageKeys.viewMode, mode);
  }
}
