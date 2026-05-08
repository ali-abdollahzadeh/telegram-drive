import 'package:flutter/material.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Existing widgets  (enhanced to use AppSpacing / AppRadius)
// ─────────────────────────────────────────────────────────────────────────────

class LoadingView extends StatelessWidget {
  final String? message;
  const LoadingView({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 3,
            ),
          ),
          if (message != null) ...[
            AppSpacing.gapMD,
            Text(
              message!,
              style: AppTextStyles.bodyMedium(context),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorView({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.allXL,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const IconBadge(
              icon: Icons.error_outline_rounded,
              color: AppColors.error,
              size: 72,
              iconSize: 36,
            ),
            AppSpacing.gapMD,
            Text(
              AppText.somethingWentWrong,
              style: AppTextStyles.titleMedium(context),
              textAlign: TextAlign.center,
            ),
            AppSpacing.gapXS,
            Text(
              message,
              style: AppTextStyles.bodyMedium(context),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              AppSpacing.gapXL,
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text(AppText.tryAgain),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(160, 48),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.allXL,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconBadge(
              icon: icon,
              color: Theme.of(context).colorScheme.primary,
              size: 88,
              iconSize: 40,
            ),
            AppSpacing.gapXL,
            Text(
              title,
              style: AppTextStyles.titleLarge(context),
              textAlign: TextAlign.center,
            ),
            AppSpacing.gapXS,
            Text(
              subtitle,
              style: AppTextStyles.bodyMedium(context),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.xxl),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(180, 48),
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NEW: AppCard
// ─────────────────────────────────────────────────────────────────────────────

/// A standard surface card with consistent border-radius, color, and optional
/// border. Replaces ad-hoc `Container(decoration: BoxDecoration(...))` patterns.
///
/// ```dart
/// AppCard(
///   child: ListTile(title: Text('Hello')),
/// )
/// ```
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final Color? color;
  final Color? borderColor;
  final double? borderWidth;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.color,
    this.borderColor,
    this.borderWidth,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveColor =
        color ?? (isDark ? AppColors.cardDark : Colors.white);
    final effectiveBorderColor = borderColor ??
        (isDark
            ? AppColors.dividerDark.withValues(alpha: 0.45)
            : AppColors.dividerLight.withValues(alpha: 0.8));
    final radius = borderRadius ?? AppRadius.md;

    final container = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: effectiveColor,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: effectiveBorderColor,
          width: borderWidth ?? 1,
        ),
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: container,
      );
    }
    return container;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NEW: IconBadge
// ─────────────────────────────────────────────────────────────────────────────

/// A colored icon centred inside a rounded container — used in empty states,
/// error views, settings tiles, and file type indicators.
///
/// ```dart
/// IconBadge(
///   icon: Icons.folder_rounded,
///   color: AppColors.primary,
///   size: 48,
///   iconSize: 24,
/// )
/// ```
class IconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;

  /// Outer container size (width & height).
  final double size;

  /// Icon size inside the container.
  final double iconSize;

  /// Background alpha (0–1). Defaults to 0.12.
  final double backgroundAlpha;

  /// Override the background color entirely (ignores [backgroundAlpha]).
  final Color? backgroundColor;

  final double? borderRadius;

  const IconBadge({
    super.key,
    required this.icon,
    required this.color,
    this.size = 48,
    this.iconSize = 24,
    this.backgroundAlpha = 0.12,
    this.backgroundColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? color.withValues(alpha: backgroundAlpha);
    final radius = borderRadius ?? (size / 4);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Icon(icon, color: color, size: iconSize),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NEW: PrimaryButton
// ─────────────────────────────────────────────────────────────────────────────

/// Full-width primary action button with a built-in loading state.
///
/// Shows a [CircularProgressIndicator] while [isLoading] is true and
/// disables the button automatically.
///
/// ```dart
/// PrimaryButton(
///   label: AppText.continueButton,
///   isLoading: state.isLoading,
///   onPressed: _submit,
/// )
/// ```
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double? minimumWidth;
  final double minimumHeight;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.minimumWidth,
    this.minimumHeight = 50,
  });

  @override
  Widget build(BuildContext context) {
    final minWidth = minimumWidth ?? double.infinity;

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: Size(minWidth, minimumHeight),
      ),
      child: isLoading
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white,
              ),
            )
          : icon != null
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 18),
                    AppSpacing.hGapXS,
                    Text(label),
                  ],
                )
              : Text(label),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NEW: SectionHeader
// ─────────────────────────────────────────────────────────────────────────────

/// A section label row with an optional trailing widget (e.g. a button or
/// badge). Used to separate logical groups in lists and settings screens.
///
/// ```dart
/// SectionHeader(title: 'Recent Files')
/// SectionHeader(title: 'Storage', trailing: Text('2.4 GB'))
/// ```
class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  const SectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.padding = const EdgeInsets.fromLTRB(
      AppSpacing.md,
      AppSpacing.md,
      AppSpacing.md,
      AppSpacing.xs,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: Text(
              title.toUpperCase(),
              style: AppTextStyles.labelSmall(context)?.copyWith(
                letterSpacing: 0.8,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NEW: AppDivider
// ─────────────────────────────────────────────────────────────────────────────

/// A consistently styled divider that uses the theme's outline color.
///
/// Prefer this over `Divider()` to ensure consistent thickness and color.
class AppDivider extends StatelessWidget {
  final double? indent;
  final double? endIndent;
  final double thickness;

  const AppDivider({
    super.key,
    this.indent,
    this.endIndent,
    this.thickness = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: thickness,
      thickness: thickness,
      indent: indent,
      endIndent: endIndent,
      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NEW: InfoRow
// ─────────────────────────────────────────────────────────────────────────────

/// A two-column label / value row used in detail screens (e.g. file details).
///
/// ```dart
/// InfoRow(label: AppText.infoLabelSize, value: '4.2 MB')
/// ```
class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final double labelWidth;

  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.labelWidth = 110,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.vSM,
      child: Row(
        children: [
          SizedBox(
            width: labelWidth,
            child: Text(label, style: AppTextStyles.bodySmall(context)),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium(context)?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NEW: ConfirmDialog
// ─────────────────────────────────────────────────────────────────────────────

/// A reusable confirmation dialog with consistent styling.
///
/// ```dart
/// await showDialog(
///   context: context,
///   builder: (_) => ConfirmDialog(
///     title: AppText.logOutDialogTitle,
///     content: AppText.logOutDialogContent,
///     confirmLabel: AppText.logOutConfirm,
///     isDestructive: true,
///     onConfirm: () async { ... },
///   ),
/// );
/// ```
class ConfirmDialog extends StatelessWidget {
  final String title;
  final String content;
  final String confirmLabel;
  final String cancelLabel;
  final bool isDestructive;
  final VoidCallback? onConfirm;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.content,
    required this.confirmLabel,
    this.cancelLabel = AppText.cancel,
    this.isDestructive = false,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actionsAlignment: MainAxisAlignment.end,
      actionsPadding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.md,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(cancelLabel),
        ),
        AppSpacing.hGapXS,
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isDestructive ? AppColors.error : null,
            foregroundColor: isDestructive ? Colors.white : null,
            minimumSize: const Size(90, 40),
          ),
          onPressed: () {
            Navigator.pop(context);
            onConfirm?.call();
          },
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}
