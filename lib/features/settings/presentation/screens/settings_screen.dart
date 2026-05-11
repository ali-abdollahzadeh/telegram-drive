import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../services/platform/native_telegram_channel.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common_widgets.dart';
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
                    fullName.isNotEmpty ? fullName : AppText.telegramUser;

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
                    AppSpacing.gapXXL,
                    _SettingsCard(
                      children: [
                        _TelegramSettingsTile(
                          icon: Icons.laptop_mac,
                          iconBackground: const Color(0xFFFFA000),
                          title: AppText.settingsTitleTheme,
                          subtitle: AppText.settingsSubtitleTheme,
                          trailing: DropdownButtonHideUnderline(
                            child: DropdownButton<ThemeMode>(
                              value: themeMode,
                              dropdownColor:
                                  isDark ? AppColors.cardDark : Colors.white,
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
                                  child: Text(AppText.themeSystem),
                                ),
                                DropdownMenuItem(
                                  value: ThemeMode.dark,
                                  child: Text(AppText.themeDark),
                                ),
                                DropdownMenuItem(
                                  value: ThemeMode.light,
                                  child: Text(AppText.themeLight),
                                ),
                              ],
                            ),
                          ),
                        ),
                        _TelegramSettingsTile(
                          icon: Icons.lock_rounded,
                          iconBackground: const Color(0xFF31C754),
                          title: AppText.settingsTitlePrivacy,
                          subtitle: AppText.settingsSubtitlePrivacy,
                          onTap: () => _showClearSessionDialog(context, ref),
                        ),
                        _TelegramSettingsTile(
                          icon: Icons.storage_rounded,
                          iconBackground: const Color(0xFF4A74F5),
                          title: AppText.settingsTitleDataStorage,
                          subtitle: AppText.settingsSubtitleDataStorage,
                          onTap: () async {
                            try {
                              await NativeTelegramChannel.optimizeStorage();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(AppText.cacheCleared),
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
                          title: AppText.settingsTitleDownloadLocation,
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
                    AppSpacing.gapXL,
                    _SettingsCard(
                      children: [
                        _TelegramSettingsTile(
                          icon: Icons.privacy_tip_rounded,
                          iconBackground: const Color(0xFFB8860B),
                          title: AppText.settingsTitlePrivacyPolicy,
                          subtitle: AppText.settingsSubtitlePrivacyPolicy,
                          onTap: () {
                            context.push(AppRoutes.privacyPolicy);
                          },
                        ),
                        _TelegramSettingsTile(
                          icon: Icons.code_rounded,
                          iconBackground: const Color(0xFF64748B),
                          title: AppText.settingsTitleLicenses,
                          subtitle: AppText.settingsSubtitleLicenses,
                          onTap: () {
                            showLicensePage(
                              context: context,
                              applicationName: AppConstants.appName,
                            );
                          },
                        ),
                      ],
                    ),
                    AppSpacing.gapXL,
                    _SettingsCard(
                      children: [
                        _TelegramSettingsTile(
                          icon: Icons.logout_rounded,
                          iconBackground: AppColors.error,
                          title: AppText.settingsTitleLogOut,
                          subtitle: AppText.settingsSubtitleLogOut,
                          titleColor: AppColors.error,
                          onTap: () => _showLogoutDialog(context, ref),
                        ),
                      ],
                    ),
                    AppSpacing.gapMD,
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
                  padding: AppSpacing.padXXL,
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
        title: const Text(AppText.logOutDialogTitle),
        content: const Text(
          AppText.logOutDialogContent,
        ),
        actionsAlignment: MainAxisAlignment.end,
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: isDark ? Colors.white : Colors.black,
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text(AppText.cancel),
          ),
          AppSpacing.hGapXS,
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              minimumSize: const Size(90, AppDimensions.buttonHeightSM),
            ),
            onPressed: () async {
              Navigator.pop(context);

              await ref.read(authProvider.notifier).logout();

              if (context.mounted) {
                context.go(AppRoutes.welcome);
              }
            },
            child: const Text(AppText.logOutConfirm),
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
        title: const Text(AppText.clearSessionDialogTitle),
        content: const Text(
          AppText.clearSessionDialogContent,
        ),
        actionsAlignment: MainAxisAlignment.end,
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: isDark ? Colors.white : Colors.black,
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text(AppText.cancel),
          ),
          AppSpacing.hGapXS,
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(90, AppDimensions.buttonHeightSM),
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              context.go(AppRoutes.welcome);
            },
            child: const Text(AppText.clearSessionConfirm),
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
        const SizedBox(height: AppSpacing.lg),
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
        const SizedBox(height: AppSpacing.xxs),
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
    return AppCard(
      color: isDark ? AppColors.cardDark : Colors.white,
      borderRadius: AppRadius.xxl,
      hasBorder: false,
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
      leading: IconBadge(
        icon: icon,
        color: Colors.white,
        backgroundColor: iconBackground,
        size: AppDimensions.settingsIconSize,
        iconSize: AppDimensions.settingsIconGlyph,
        borderRadius: AppRadius.sm,
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
