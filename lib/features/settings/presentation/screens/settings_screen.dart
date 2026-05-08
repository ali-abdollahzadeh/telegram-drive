import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../services/platform/native_telegram_channel.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final userProfileAsync = ref.watch(userProfileProvider);
    final downloadLocation = ref.watch(downloadLocationProvider);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF2F2F7),
      body: SafeArea(
        child: Stack(
          children: [
            userProfileAsync.when(
              data: (profile) {
                final firstName = profile['firstName'] as String?;
                final lastName = profile['lastName'] as String?;
                final phoneNumber = profile['phoneNumber'] as String?;
                final username = profile['username'] as String?;
                final photoPath = profile['photoPath'] as String?;

                final fullName = '${firstName ?? ''} ${lastName ?? ''}'.trim();
                final displayName =
                    fullName.isNotEmpty ? fullName : 'Telegram User';

                final phoneText = phoneNumber != null && phoneNumber.isNotEmpty
                    ? '+$phoneNumber'
                    : '';

                final usernameText =
                    username != null && username.isNotEmpty ? '@$username' : '';

                final subtitle = phoneText.isNotEmpty && usernameText.isNotEmpty
                    ? '$phoneText • $usernameText'
                    : phoneText.isNotEmpty
                        ? phoneText
                        : usernameText;

                return ListView(
                  padding: const EdgeInsets.fromLTRB(12, 50, 12, 120),
                  children: [
                    _ProfileHeader(
                      name: displayName,
                      subtitle: subtitle,
                      imagePath: photoPath,
                    ),
                    const SizedBox(height: 32),
                    _SettingsCard(
                      children: [
                        _TelegramSettingsTile(
                          icon: Icons.laptop_mac,
                          iconBackground: const Color(0xFFFFA000),
                          title: 'Theme',
                          subtitle: 'Choose your theme',
                          trailing: DropdownButtonHideUnderline(
                            child: DropdownButton<ThemeMode>(
                              value: themeMode,
                              dropdownColor: isDark
                                  ? const Color(0xFF1C1C1E)
                                  : Colors.white,
                              style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black),
                              iconEnabledColor:
                                  isDark ? Colors.white54 : Colors.black54,
                              onChanged: (value) async {
                                if (value == null) return;

                                ref.read(themeModeProvider.notifier).state =
                                    value;
                                await SettingsService.saveTheme(value);
                              },
                              items: const [
                                DropdownMenuItem(
                                  value: ThemeMode.system,
                                  child: Text('System'),
                                ),
                                DropdownMenuItem(
                                  value: ThemeMode.dark,
                                  child: Text('Dark'),
                                ),
                                DropdownMenuItem(
                                  value: ThemeMode.light,
                                  child: Text('Light'),
                                ),
                              ],
                            ),
                          ),
                        ),
                        _TelegramSettingsTile(
                          icon: Icons.lock_rounded,
                          iconBackground: const Color(0xFF31C754),
                          title: 'Privacy & Security',
                          subtitle: 'Session, Devices, Local Data',
                          onTap: () => _showClearSessionDialog(context, ref),
                        ),
                        _TelegramSettingsTile(
                          icon: Icons.storage_rounded,
                          iconBackground: const Color(0xFF4A74F5),
                          title: 'Data and Storage',
                          subtitle: 'Clear TDLib cache',
                          onTap: () async {
                            try {
                              await NativeTelegramChannel.optimizeStorage();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Cache cleared successfully'),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e')),
                                );
                              }
                            }
                          },
                        ),
                        _TelegramSettingsTile(
                          icon: Icons.folder_rounded,
                          iconBackground: const Color(0xFF22AEEA),
                          title: 'Download Location',
                          subtitle: downloadLocation,
                          onTap: () async {
                            final result =
                                await FilePicker.platform.getDirectoryPath();
                            if (result != null) {
                              ref
                                  .read(downloadLocationProvider.notifier)
                                  .state = result;
                              await SettingsService.saveDownloadLocation(
                                  result);
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _SettingsCard(
                      children: [
                        _TelegramSettingsTile(
                          icon: Icons.privacy_tip_rounded,
                          iconBackground: const Color(0xFFB8860B),
                          title: 'Privacy Policy',
                          subtitle: 'All data stays on your device',
                          onTap: () {
                            context.push(AppRoutes.privacyPolicy);
                          },
                        ),
                        _TelegramSettingsTile(
                          icon: Icons.code_rounded,
                          iconBackground: const Color(0xFF64748B),
                          title: 'Open Source Licenses',
                          subtitle: 'Flutter and package licenses',
                          onTap: () {
                            showLicensePage(
                              context: context,
                              applicationName: AppConstants.appName,
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _SettingsCard(
                      children: [
                        _TelegramSettingsTile(
                          icon: Icons.logout_rounded,
                          iconBackground: AppColors.error,
                          title: 'Log Out',
                          subtitle: 'Remove session from this device',
                          titleColor: AppColors.error,
                          onTap: () => _showLogoutDialog(context, ref),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'TeleDrive for Android  v${AppConstants.appVersion}\n Telegram Database Library (TDLib) integrated',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isDark ? Colors.white38 : Colors.black45,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (e, st) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Error loading profile\n$e',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black87),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              left: 8,
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: isDark ? Colors.white : Colors.black,
                ),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text(
          'Are you sure you want to log out? Your session will be removed from this device.',
        ),
        actionsAlignment: MainAxisAlignment.end,
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: isDark
                  ? Colors.white
                  : Colors.black, // cancel button text color
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              minimumSize: const Size(90, 40),
            ),
            onPressed: () async {
              Navigator.pop(context);

              await ref.read(authProvider.notifier).logout();

              if (context.mounted) {
                context.go(AppRoutes.welcome);
              }
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  void _showClearSessionDialog(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear Local Session'),
        content: const Text(
          'This will remove your local session data. You will need to log in again.',
        ),
        actionsAlignment: MainAxisAlignment.end,
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: isDark
                  ? Colors.white
                  : Colors.black, // cancel button text color
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(90, 40),
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              context.go(AppRoutes.welcome);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String name;
  final String subtitle;
  final String? imagePath;

  const _ProfileHeader({
    required this.name,
    required this.subtitle,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imagePath != null && imagePath!.isNotEmpty;
    final imageFile = hasImage ? File(imagePath!) : null;
    final imageExists = imageFile != null && imageFile.existsSync();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              radius: 58,
              backgroundColor:
                  isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA),
              backgroundImage: imageExists ? FileImage(imageFile) : null,
              child: imageExists
                  ? null
                  : Icon(
                      Icons.person_rounded,
                      size: 64,
                      color: isDark ? Colors.white70 : Colors.black45,
                    ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          name,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isDark ? Colors.white38 : Colors.black54,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

class _TelegramSettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconBackground;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? titleColor;

  const _TelegramSettingsTile({
    required this.icon,
    required this.iconBackground,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 0,
      ),
      leading: Container(
        width: 25,
        height: 25,
        decoration: BoxDecoration(
          color: iconBackground,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 15,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor ?? (isDark ? Colors.white : Colors.black),
          fontSize: 16,
          fontWeight: FontWeight.w800,
          height: 0.1,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Text(
          subtitle,
          style: TextStyle(
            color: isDark ? Colors.white38 : Colors.black54,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
