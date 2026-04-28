import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/routing/app_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final viewMode = ref.watch(defaultViewModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // Account Section
          _SectionHeader('Account'),
          _SettingsTile(
            icon: Icons.phone_rounded,
            title: 'Phone Number',
            subtitle: '+1 234 567 8900',
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Connected',
                style: TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          _SettingsTile(
            icon: Icons.logout_rounded,
            title: 'Log Out',
            iconColor: AppColors.error,
            onTap: () => _showLogoutDialog(context, ref),
          ),
          const Divider(height: 32),

          // Storage Section
          _SectionHeader('Storage'),
          _SettingsTile(
            icon: Icons.storage_rounded,
            title: 'Cache Size',
            subtitle: '128 MB used',
          ),
          _SettingsTile(
            icon: Icons.delete_sweep_rounded,
            title: 'Clear Cache',
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cache cleared')),
            ),
          ),
          _SettingsTile(
            icon: Icons.folder_open_rounded,
            title: 'Download Location',
            subtitle: '/storage/emulated/0/Download',
          ),
          const Divider(height: 32),

          // Appearance Section
          _SectionHeader('Appearance'),
          _SettingsTile(
            icon: Icons.palette_rounded,
            title: 'Theme',
            trailing: DropdownButton<ThemeMode>(
              value: themeMode,
              underline: const SizedBox(),
              onChanged: (v) => ref.read(themeModeProvider.notifier).state = v!,
              items: const [
                DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
                DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
                DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
              ],
            ),
          ),
          _SettingsTile(
            icon: Icons.grid_view_rounded,
            title: 'Default View',
            trailing: DropdownButton<String>(
              value: viewMode,
              underline: const SizedBox(),
              onChanged: (v) => ref.read(defaultViewModeProvider.notifier).state = v!,
              items: const [
                DropdownMenuItem(value: 'grid', child: Text('Grid')),
                DropdownMenuItem(value: 'list', child: Text('List')),
              ],
            ),
          ),
          const Divider(height: 32),

          // Security Section
          _SectionHeader('Security'),
          _SettingsTile(
            icon: Icons.fingerprint_rounded,
            title: 'Biometric Unlock',
            trailing: Switch(
              value: false,
              onChanged: (_) {},
              activeThumbColor: AppColors.primary,
            ),
          ),
          _SettingsTile(
            icon: Icons.app_blocking_rounded,
            title: 'App Lock',
            trailing: Switch(
              value: false,
              onChanged: (_) {},
              activeThumbColor: AppColors.primary,
            ),
          ),
          _SettingsTile(
            icon: Icons.no_encryption_rounded,
            title: 'Clear Local Session',
            iconColor: AppColors.error,
            onTap: () => _showClearSessionDialog(context, ref),
          ),
          const Divider(height: 32),

          // About Section
          _SectionHeader('About'),
          _SettingsTile(
            icon: Icons.info_outline_rounded,
            title: 'App Version',
            subtitle: '${AppConstants.appVersion} (Phase 1 Mock)',
          ),
          _SettingsTile(
            icon: Icons.privacy_tip_rounded,
            title: 'Privacy Policy',
            subtitle: 'All data stays on your device',
          ),
          _SettingsTile(
            icon: Icons.code_rounded,
            title: 'Open Source Licenses',
            onTap: () => showLicensePage(context: context, applicationName: AppConstants.appName),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out? Your session will be removed from this device.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go(AppRoutes.welcome);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  void _showClearSessionDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear Local Session'),
        content: const Text('This will remove your local session data. You will need to log in again.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go(AppRoutes.welcome);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.primary,
              letterSpacing: 1.2,
            ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: (iconColor ?? AppColors.primary).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor ?? AppColors.primary, size: 20),
      ),
      title: Text(title, style: Theme.of(context).textTheme.titleSmall),
      subtitle: subtitle != null
          ? Text(subtitle!, style: Theme.of(context).textTheme.bodySmall)
          : null,
      trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right_rounded, size: 20) : null),
      onTap: onTap,
    );
  }
}
