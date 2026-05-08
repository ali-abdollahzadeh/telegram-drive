import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

class GlassBottomNavItem {
  const GlassBottomNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    this.badge,
    this.isBadgeError = false,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String? badge;
  final bool isBadgeError;
}

class GlassBottomNav extends StatelessWidget {
  const GlassBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<GlassBottomNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isDark
        ? AppColors.surfaceDark.withValues(alpha: 0.82)
        : AppColors.glassTargetMainTabs.withValues(alpha: 0.82);

    final borderColor = isDark
        ? AppColors.dividerDark.withValues(alpha: 0.45)
        : AppColors.lightDivider.withValues(alpha: 0.8);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              height: 64,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: List.generate(items.length, (index) {
                  final item = items[index];
                  final selected = index == currentIndex;

                  return Expanded(
                    child: _GlassTabItem(
                      item: item,
                      selected: selected,
                      onTap: () => onTap(index),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassTabItem extends StatelessWidget {
  const _GlassTabItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final GlassBottomNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const selectedColor = AppColors.glassTabSelected;
    const selectedTextColor = AppColors.glassTabSelectedText;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final unselectedColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.glassTabUnselected;

    final iconColor = selected ? selectedColor : unselectedColor;
    final textColor = selected ? selectedTextColor : unselectedColor;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? selectedColor.withValues(alpha: 0.09)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeOutCubic,
                  child: Icon(
                    selected ? item.selectedIcon : item.icon,
                    key: ValueKey<bool>(selected),
                    size: 24,
                    color: iconColor,
                  ),
                ),
                const SizedBox(height: 2),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
                    color: textColor,
                    height: 1,
                  ),
                  child: Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            if (item.badge != null && item.badge!.isNotEmpty)
              Positioned(
                top: 6,
                right: 18,
                child: _GlassBadge(
                  text: item.badge!,
                  isError: item.isBadgeError,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _GlassBadge extends StatelessWidget {
  const _GlassBadge({
    required this.text,
    required this.isError,
  });

  final String text;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isError
        ? AppColors.fillRedNormal
        : AppColors.teledriveBlue;

    return Container(
      constraints: const BoxConstraints(
        minWidth: 16,
        minHeight: 16,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.surfaceDark
              : AppColors.glassTargetMainTabs,
          width: 1.33,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: GoogleFonts.roboto(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.glassBadgeText,
          height: 1,
        ),
      ),
    );
  }
}