import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_text.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/settings/presentation/providers/settings_provider.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _introController;
  late final AnimationController _contentController;
  late final AnimationController _floatingController;

  late final Animation<Offset> _contentSlide;
  late final Animation<double> _contentOpacity;

  @override
  void initState() {
    super.initState();

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );

    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.22),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: Curves.easeOutCubic,
      ),
    );

    _contentOpacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: Curves.easeOut,
      ),
    );

    _introController.forward().then((_) {
      _floatingController.repeat(reverse: true);
      _contentController.forward();
    });
  }

  @override
  void dispose() {
    _introController.dispose();
    _contentController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  void _toggleTheme() {
    final current = ref.read(themeModeProvider);
    ThemeMode next;
    if (current == ThemeMode.dark) {
      next = ThemeMode.light;
    } else if (current == ThemeMode.light) {
      next = ThemeMode.system;
    } else {
      next = ThemeMode.dark;
    }
    ref.read(themeModeProvider.notifier).state = next;
  }

  IconData _themeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return Icons.dark_mode_rounded;
      case ThemeMode.light:
        return Icons.light_mode_rounded;
      case ThemeMode.system:
        return Icons.brightness_auto_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  _buildAnimatedIntro(isDark),
                  const SizedBox(height: 26),
                  FadeTransition(
                    opacity: _contentOpacity,
                    child: SlideTransition(
                      position: _contentSlide,
                      child: _buildContent(context, isDark),
                    ),
                  ),
                  const Spacer(flex: 3),
                  FadeTransition(
                    opacity: _contentOpacity,
                    child: SlideTransition(
                      position: _contentSlide,
                      child: _buildCTA(context, isDark),
                    ),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),

            // Theme toggle icon — top right
            Positioned(
              top: 8,
              right: 12,
              child: FadeTransition(
                opacity: _contentOpacity,
                child: Tooltip(
                  message: themeMode == ThemeMode.dark
                      ? AppText.tooltipDarkMode
                      : themeMode == ThemeMode.light
                          ? AppText.tooltipLightMode
                          : AppText.tooltipSystemTheme,
                  child: IconButton(
                    onPressed: _toggleTheme,
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, anim) => RotationTransition(
                        turns: anim,
                        child: FadeTransition(opacity: anim, child: child),
                      ),
                      child: Icon(
                        _themeIcon(themeMode),
                        key: ValueKey(themeMode),
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.lightTextSecondary,
                        size: 22,
                      ),
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor:
                          isDark ? AppColors.cardDark : AppColors.lightSurface,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedIntro(bool isDark) {
    return Column(
      children: [
        SizedBox(
          width: 260,
          height: 220,
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _introController,
              _floatingController,
            ]),
            builder: (context, child) {
              final introProgress = _easeOut(_introController.value);
              final floatingValue = sin(_floatingController.value * pi);
              final bgColor = Theme.of(context).colorScheme.surface;

              return Transform.translate(
                offset: Offset(0, -3 * floatingValue),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(260, 220),
                      painter: _TelegramCloudPainter(
                        progress: introProgress,
                        floatingValue: floatingValue,
                        coverColor: bgColor,
                      ),
                    ),
                    _buildCloudIcon(
                      icon: Icons.location_pin,
                      x: -72,
                      y: -28,
                      delay: 0.20,
                      size: 25,
                      rotation: -0.18,
                      isDark: isDark,
                    ),
                    _buildCloudIcon(
                      icon: Icons.videocam_rounded,
                      x: -36,
                      y: -52,
                      delay: 0.34,
                      size: 27,
                      rotation: -0.40,
                      isDark: isDark,
                    ),
                    _buildCloudIcon(
                      icon: Icons.camera_alt_rounded,
                      x: -8,
                      y: 4,
                      delay: 0.14,
                      size: 28,
                      rotation: 0.18,
                      isDark: isDark,
                    ),
                    _buildCloudIcon(
                      icon: Icons.emoji_emotions_rounded,
                      x: 42,
                      y: -24,
                      delay: 0.26,
                      size: 29,
                      rotation: -0.16,
                      isDark: isDark,
                    ),
                    _buildCloudIcon(
                      icon: Icons.chat_bubble_rounded,
                      x: 48,
                      y: 44,
                      delay: 0.06,
                      size: 27,
                      rotation: -0.12,
                      isDark: isDark,
                    ),
                    _buildCloudIcon(
                      icon: Icons.edit_rounded,
                      x: 84,
                      y: -42,
                      delay: 0.38,
                      size: 26,
                      rotation: 0.30,
                      isDark: isDark,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 2),
        Text(
          AppConstants.appName,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.lightTextPrimary,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCloudIcon({
    required IconData icon,
    required double x,
    required double y,
    required double delay,
    required double size,
    required double rotation,
    required bool isDark,
  }) {
    final iconColor = isDark ? Colors.white : AppColors.dividerDark;

    double localProgress =
        ((_introController.value - delay) / (1 - delay)).clamp(0.0, 1.0);

    localProgress = _easeOutBack(localProgress);

    final floatingValue = sin(_floatingController.value * pi);
    final bounce = sin(localProgress.clamp(0.0, 1.0) * pi) * 11;

    return Transform.translate(
      offset: Offset(
        x,
        y + (1 - localProgress) * 145 - bounce + floatingValue * 2,
      ),
      child: Transform.rotate(
        angle: rotation * localProgress,
        child: Opacity(
          opacity: localProgress.clamp(0.0, 1.0),
          child: Icon(
            icon,
            color: iconColor,
            size: size,
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool isDark) {
    return Column(
      children: [
        Text(
          AppConstants.appTagline,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.lightTextSecondary,
                fontWeight: FontWeight.w400,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: [
            _FeaturePill(
                icon: Icons.lock_rounded, label: AppText.pillPrivate, isDark: isDark),
            _FeaturePill(
                icon: Icons.cloud_upload_rounded,
                label: AppText.pillUpload,
                isDark: isDark),
            _FeaturePill(
                icon: Icons.folder_rounded, label: AppText.pillOrganize, isDark: isDark),
            _FeaturePill(
                icon: Icons.preview_rounded, label: AppText.pillPreview, isDark: isDark),
          ],
        ),
      ],
    );
  }

  Widget _buildCTA(BuildContext context, bool isDark) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () => context.push(AppRoutes.login),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppText.getStarted,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, size: 20),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          AppText.dataStaysOnDevice,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color:
                    isDark ? AppColors.textHintDark : AppColors.lightTextHint,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  double _easeOut(double x) {
    return 1 - pow(1 - x, 3).toDouble();
  }

  double _easeOutBack(double x) {
    const c1 = 1.70158;
    const c3 = c1 + 1;
    return 1 + c3 * pow(x - 1, 3).toDouble() + c1 * pow(x - 1, 2).toDouble();
  }
}

// ---------------------------------------------------------------------------
// Cloud painter — cover color now comes from the theme background
// ---------------------------------------------------------------------------

class _TelegramCloudPainter extends CustomPainter {
  final double progress;
  final double floatingValue;
  final Color coverColor;

  const _TelegramCloudPainter({
    required this.progress,
    required this.floatingValue,
    required this.coverColor,
  });

  double _easeOut(double x) {
    return 1 - pow(1 - x, 3).toDouble();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final p = _easeOut(progress.clamp(0.0, 1.0));

    final center = Offset(
      size.width / 2,
      size.height / 2 - 18,
    );

    final floatOffset = Offset(0, -floatingValue * 2.5);
    final actualCenter = center + floatOffset;

    final path = _telegramPage6Mask(actualCenter, p);

    // Shadow
    final shadowPaint = Paint()
      ..color = AppColors.teledriveBlue.withValues(alpha: 0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);

    canvas.save();
    canvas.translate(0, 8);
    canvas.drawPath(path, shadowPaint);
    canvas.restore();

    // Fill cloud with app primary blue
    canvas.save();
    canvas.clipPath(path);

    final bluePaint = Paint()..color = AppColors.teledriveBlue;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      bluePaint,
    );

    canvas.restore();

    // Cover bottom portion with screen background color (dark-mode aware)
    final coverPaint = Paint()..color = coverColor;
    final coverY = _lerp(109, 109, p);
    final coverRect = Rect.fromCenter(
      center: Offset(actualCenter.dx, actualCenter.dy + coverY),
      width: 240,
      height: 100,
    );
    canvas.drawRect(coverRect, coverPaint);
  }

  Path _telegramPage6Mask(Offset center, double p) {
    final Path result = Path()..fillType = PathFillType.nonZero;

    // Main rotated rounded square (mask1)
    final mainSize = _lerp(140, 100, p);
    final mainRadius = _lerp(40, 50, p);

    final mainCenter = center +
        Offset(
          _lerp(0, 29 / 2, p),
          _lerp(0, -19 / 2, p),
        );

    final mainRect = Rect.fromCenter(
      center: mainCenter,
      width: mainSize,
      height: mainSize,
    );

    final mainRRect = RRect.fromRectAndRadius(
      mainRect,
      Radius.circular(mainRadius),
    );

    final mainPath = Path()..addRRect(mainRRect);

    final matrix = Matrix4.identity()
      ..translateByDouble(mainCenter.dx, mainCenter.dy, 0, 1)
      ..rotateZ(_degreesToRadians(_lerp(360, 450, p)))
      ..translateByDouble(-mainCenter.dx, -mainCenter.dy, 0, 1);

    result.addPath(mainPath.transform(matrix.storage), Offset.zero);

    // cloud_extra_mask1
    result.addOval(
      Rect.fromCircle(
        center: center +
            Offset(
              _lerp(0, -122 / 2, p),
              _lerp(0, 54 / 2 - 1, p),
            ),
        radius: _lerp(0, 33, p),
      ),
    );

    // cloud_extra_mask2
    result.addOval(
      Rect.fromCircle(
        center: center +
            Offset(
              _lerp(0, -84 / 2, p),
              _lerp(0, -29 / 2, p),
            ),
        radius: _lerp(0, 94 / 4, p),
      ),
    );

    // cloud_extra_mask3
    result.addOval(
      Rect.fromCircle(
        center: center +
            Offset(
              _lerp(0, 128 / 2, p),
              _lerp(0, 56 / 2, p),
            ),
        radius: _lerp(0, 124 / 4, p),
      ),
    );

    // cloud_extra_mask4
    result.addOval(
      Rect.fromCircle(
        center: center +
            Offset(
              0,
              _lerp(0, 50, p),
            ),
        radius: _lerp(0, 64, p),
      ),
    );

    return result;
  }

  double _lerp(double start, double end, double t) {
    return start + (end - start) * t;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  @override
  bool shouldRepaint(covariant _TelegramCloudPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.floatingValue != floatingValue ||
        oldDelegate.coverColor != coverColor;
  }
}

// ---------------------------------------------------------------------------
// Feature pill — dark-mode aware
// ---------------------------------------------------------------------------

class _FeaturePill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;

  const _FeaturePill({
    required this.icon,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.lightDivider,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.lightTextSecondary,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}
