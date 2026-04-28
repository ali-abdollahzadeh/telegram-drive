import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/routing/app_router.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _contentController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<Offset> _contentSlide;
  late Animation<double> _contentOpacity;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _contentController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));

    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _logoController, curve: const Interval(0, 0.5)),
    );
    _contentSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOut),
    );
    _contentOpacity = Tween<double>(begin: 0, end: 1).animate(_contentController);

    _logoController.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 200), () => _contentController.forward());
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const Spacer(flex: 2),
                // Logo
                AnimatedBuilder(
                  animation: _logoController,
                  builder: (_, __) => Opacity(
                    opacity: _logoOpacity.value,
                    child: Transform.scale(
                      scale: _logoScale.value,
                      child: _buildLogo(),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Content
                FadeTransition(
                  opacity: _contentOpacity,
                  child: SlideTransition(
                    position: _contentSlide,
                    child: _buildContent(context),
                  ),
                ),
                const Spacer(flex: 3),
                // CTA
                FadeTransition(
                  opacity: _contentOpacity,
                  child: SlideTransition(
                    position: _contentSlide,
                    child: _buildCTA(context),
                  ),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 32,
                spreadRadius: 0,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: const Icon(Icons.cloud_rounded, color: Colors.white, size: 50),
        ),
        const SizedBox(height: 20),
        Text(
          AppConstants.appName,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.textPrimaryDark,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      children: [
        Text(
          AppConstants.appTagline,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textSecondaryDark,
                fontWeight: FontWeight.w400,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        // Feature pills
        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: const [
            _FeaturePill(icon: Icons.lock_rounded, label: 'Private'),
            _FeaturePill(icon: Icons.cloud_upload_rounded, label: 'Upload'),
            _FeaturePill(icon: Icons.folder_rounded, label: 'Organize'),
            _FeaturePill(icon: Icons.preview_rounded, label: 'Preview'),
          ],
        ),
      ],
    );
  }

  Widget _buildCTA(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () => context.push(AppRoutes.login),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Get Started'),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward_rounded, size: 20),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Your data never leaves your Telegram account.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textHintDark,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _FeaturePill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FeaturePill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.dividerDark),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primary, size: 16),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.textSecondaryDark)),
        ],
      ),
    );
  }
}
