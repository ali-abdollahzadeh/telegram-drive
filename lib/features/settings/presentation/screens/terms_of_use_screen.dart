import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common_widgets.dart';

class TermsOfUseScreen extends StatelessWidget {
  const TermsOfUseScreen({super.key});

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
          AppText.termsOfUseTitle,
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
                  Icons.gavel_rounded,
                  size: 48,
                  color: isDark ? Colors.white : Colors.black,
                ),
                AppSpacing.gapXL,
                Text(
                  AppText.termsIntroHeading,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                AppSpacing.gapMD,
                Text(
                  AppText.termsIntroBody,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black87,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                AppSpacing.gapXL,
                _TermsSection(
                  title: AppText.termsSection1Title,
                  description: AppText.termsSection1Body,
                  icon: Icons.flag_outlined,
                  isDark: isDark,
                ),
                AppSpacing.gapLG,
                _TermsSection(
                  title: AppText.termsSection2Title,
                  description: AppText.termsSection2Body,
                  icon: Icons.account_circle_rounded,
                  isDark: isDark,
                ),
                AppSpacing.gapLG,
                _TermsSection(
                  title: AppText.termsSection3Title,
                  description: AppText.termsSection3Body,
                  icon: Icons.warning_amber_rounded,
                  isDark: isDark,
                ),
                AppSpacing.gapLG,
                _TermsSection(
                  title: AppText.termsSection4Title,
                  description: AppText.termsSection4Body,
                  icon: Icons.sync_problem_rounded,
                  isDark: isDark,
                ),
                AppSpacing.gapLG,
                _TermsSection(
                  title: AppText.termsSection5Title,
                  description: AppText.termsSection5Body,
                  icon: Icons.folder_rounded,
                  isDark: isDark,
                ),
                AppSpacing.gapLG,
                _TermsSection(
                  title: AppText.termsSection6Title,
                  description: AppText.termsSection6Body,
                  icon: Icons.report_problem_outlined,
                  isDark: isDark,
                ),
                AppSpacing.gapLG,
                _TermsSection(
                  title: AppText.termsSection7Title,
                  description: AppText.termsSection7Body,
                  icon: Icons.insert_drive_file_rounded,
                  isDark: isDark,
                ),
                AppSpacing.gapLG,
                _TermsSection(
                  title: AppText.termsSection8Title,
                  description: AppText.termsSection8Body,
                  icon: Icons.code_rounded,
                  isDark: isDark,
                ),
                AppSpacing.gapXXL,
                Center(
                  child: Text(
                    AppText.termsLastUpdated,
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

class _TermsSection extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isDark;

  const _TermsSection({
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
