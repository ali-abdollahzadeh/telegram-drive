import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common_widgets.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : const Color(0xFFF2F2F7),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/settings');
            }
          },
        ),
        title: Text(
          AppText.privacyPolicyTitle,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xl,
          ),
          child: AppCard(
            padding: AppSpacing.padXXL,
            color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: AppRadius.xl,
            hasBorder: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.shield_rounded,
                  size: 48,
                  color: isDark ? Colors.white : Colors.black,
                ),
                AppSpacing.gapXL,
                Text(
                  AppText.privacyCommitmentHeading,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                AppSpacing.gapMD,
                Text(
                  AppText.privacyCommitmentBody,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black87,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                AppSpacing.gapXL,
                _PolicySection(
                  title: AppText.privacySection1Title,
                  description: AppText.privacySection1Body,
                  icon: Icons.no_accounts_rounded,
                  isDark: isDark,
                ),
                AppSpacing.gapLG,
                _PolicySection(
                  title: AppText.privacySection2Title,
                  description: AppText.privacySection2Body,
                  icon: Icons.smartphone_rounded,
                  isDark: isDark,
                ),
                AppSpacing.gapLG,
                _PolicySection(
                  title: AppText.privacySection3Title,
                  description: AppText.privacySection3Body,
                  icon: Icons.money_off_rounded,
                  isDark: isDark,
                ),
                AppSpacing.gapLG,
                _PolicySection(
                  title: AppText.privacySection4Title,
                  description: AppText.privacySection4Body,
                  icon: Icons.money_off_rounded,
                  isDark: isDark,
                ),
                AppSpacing.gapLG,
                _PolicySection(
                  title: AppText.privacySection5Title,
                  description: AppText.privacySection5Body,
                  icon: Icons.money_off_rounded,
                  isDark: isDark,
                ),
                AppSpacing.gapLG,
                _PolicySection(
                  title: AppText.privacySection6Title,
                  description: AppText.privacySection6Body,
                  icon: Icons.money_off_rounded,
                  isDark: isDark,
                ),
                AppSpacing.gapXXL,
                Center(
                  child: Text(
                    AppText.privacyLastUpdated,
                    style: TextStyle(
                      color: isDark ? Colors.white38 : Colors.black45,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isDark;

  const _PolicySection({
    required this.title,
    required this.description,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconBadge(
          icon: icon,
          color: isDark ? AppColors.textSecondaryDark : Colors.black87,
          backgroundColor: isDark ? AppColors.cardDarkAlt : Colors.black12,
          size: AppSpacing.huge,
          iconSize: AppSpacing.lg,
          borderRadius: AppRadius.md,
        ),
        AppSpacing.hGapMD,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              AppSpacing.gapXXS,
              Text(
                description,
                style: TextStyle(
                  color: isDark ? Colors.white54 : Colors.black54,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
