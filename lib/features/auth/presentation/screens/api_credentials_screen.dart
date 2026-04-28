import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/routing/app_router.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';

class ApiCredentialsScreen extends ConsumerStatefulWidget {
  const ApiCredentialsScreen({super.key});

  @override
  ConsumerState<ApiCredentialsScreen> createState() => _ApiCredentialsScreenState();
}

class _ApiCredentialsScreenState extends ConsumerState<ApiCredentialsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiIdCtrl = TextEditingController();
  final _apiHashCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  @override
  void dispose() {
    _apiIdCtrl.dispose();
    _apiHashCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(authProvider.notifier).sendCode(
          apiId: _apiIdCtrl.text.trim(),
          apiHash: _apiHashCtrl.text.trim(),
          phone: _phoneCtrl.text.trim(),
        );

    if (!mounted) return;

    final state = ref.read(authProvider);
    if (state.step == AuthStep.codeSent) {
      context.push(
        '${AppRoutes.verifyCode}?phone=${Uri.encodeComponent(_phoneCtrl.text.trim())}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;

    ref.listen(authProvider, (_, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!), backgroundColor: AppColors.error),
        );
        ref.read(authProvider.notifier).clearError();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect Account'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                'Enter your Telegram API credentials',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodyMedium,
                  children: [
                    const TextSpan(text: 'Get your API ID and Hash from '),
                    TextSpan(
                      text: 'my.telegram.org',
                      style: const TextStyle(color: AppColors.primary, decoration: TextDecoration.underline),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => launchUrl(Uri.parse(AppConstants.telegramHelpUrl)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              AuthTextField(
                controller: _apiIdCtrl,
                label: 'API ID',
                hint: 'e.g. 12345678',
                icon: Icons.vpn_key_rounded,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'API ID is required';
                  if (int.tryParse(v.trim()) == null) return 'API ID must be a number';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              AuthTextField(
                controller: _apiHashCtrl,
                label: 'API Hash',
                hint: 'e.g. a1b2c3d4e5f6...',
                icon: Icons.tag_rounded,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'API Hash is required';
                  if (v.trim().length < 16) return 'API Hash seems too short';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              AuthTextField(
                controller: _phoneCtrl,
                label: 'Phone Number',
                hint: '+1 234 567 8900',
                icon: Icons.phone_rounded,
                keyboardType: TextInputType.phone,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Phone number is required';
                  if (v.trim().length < 8) return 'Enter a valid phone number with country code';
                  return null;
                },
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: isLoading ? null : _submit,
                child: isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                      )
                    : const Text('Continue'),
              ),

              const SizedBox(height: 24),
              _InfoCard(),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Your credentials are stored only on your device. They never leave your phone.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
