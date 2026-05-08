import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../services/platform/native_telegram_channel.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);
final defaultViewModeProvider = StateProvider<String>((ref) => 'grid');
final downloadLocationProvider = StateProvider<String>((ref) => '/storage/emulated/0/Download');

/// Fetches the real Telegram user profile (ID, phone number, name)
final userProfileProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  try {
    var profile = await NativeTelegramChannel.getMe();

    final photoPath = profile['photoPath'] as String?;
    final photoFileId = profile['photoFileId'];
    final photoDownloaded = profile['photoDownloaded'] as bool? ?? false;

    if ((photoPath == null || photoPath.isEmpty || !photoDownloaded) && photoFileId != null) {
      final downloadedFile = await NativeTelegramChannel.downloadFile(
        fileId: photoFileId is int
            ? photoFileId
            : int.parse(photoFileId.toString()),
        synchronous: true,
      );

      profile = {
        ...profile,
        'photoPath': downloadedFile['localPath'],
      };
    }

    return {
      'id': profile['id'],
      'phoneNumber': profile['phoneNumber'],
      'firstName': profile['firstName'],
      'lastName': profile['lastName'],
      'photoPath': profile['photoPath'],
      'photoFileId': profile['photoFileId'],
    };
  } catch (e) {
    return {
      'phoneNumber': 'Unknown',
      'firstName': 'Error',
      'photoPath': null,
      'photoFileId': null,
    };
  }
});

/// Loads persisted settings at startup
class SettingsService {
  static Future<void> load(WidgetRef ref) async {
    final prefs = await SharedPreferences.getInstance();
    final theme = prefs.getString(StorageKeys.themeMode) ?? 'dark';
    final view = prefs.getString(StorageKeys.viewMode) ?? 'grid';
    final dlPath = prefs.getString(StorageKeys.downloadPath) ?? '/storage/emulated/0/Download';

    final themeMode = theme == 'light'
        ? ThemeMode.light
        : theme == 'system'
            ? ThemeMode.system
            : ThemeMode.dark;

    ref.read(themeModeProvider.notifier).state = themeMode;
    ref.read(defaultViewModeProvider.notifier).state = view;
    ref.read(downloadLocationProvider.notifier).state = dlPath;
  }

  static Future<void> saveTheme(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    final label = mode == ThemeMode.light
        ? 'light'
        : mode == ThemeMode.system
            ? 'system'
            : 'dark';
    await prefs.setString(StorageKeys.themeMode, label);
  }

  static Future<void> saveViewMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageKeys.viewMode, mode);
  }

  static Future<void> saveDownloadLocation(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageKeys.downloadPath, path);
  }
}
