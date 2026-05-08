import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';

class ApiCredentialsScreen extends ConsumerStatefulWidget {
  const ApiCredentialsScreen({super.key});

  @override
  ConsumerState<ApiCredentialsScreen> createState() =>
      _ApiCredentialsScreenState();
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
          SnackBar(
              content: Text(next.error!), backgroundColor: AppColors.error),
        );
        ref.read(authProvider.notifier).clearError();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppText.connectAccount),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screen,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                AppText.enterApiCredentials,
                style: AppTextStyles.headlineSmall(context),
              ),
              AppSpacing.gapXS,
              RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodyMedium,
                  children: [
                    const TextSpan(text: AppText.getApiIdFrom),
                    TextSpan(
                      text: AppText.myTelegramOrg,
                      style: const TextStyle(
                          color: AppColors.primary,
                          decoration: TextDecoration.underline),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () =>
                            launchUrl(Uri.parse(AppConstants.telegramHelpUrl)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              AuthTextField(
                controller: _apiIdCtrl,
                label: AppText.apiId,
                hint: AppText.apiIdHint,
                icon: Icons.vpn_key_rounded,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty)
                    return AppText.apiIdRequired;
                  if (int.tryParse(v.trim()) == null)
                    return AppText.apiIdMustBeNumber;
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AuthTextField(
                controller: _apiHashCtrl,
                label: AppText.apiHash,
                hint: AppText.apiHashHint,
                icon: Icons.tag_rounded,
                validator: (v) {
                  if (v == null || v.trim().isEmpty)
                    return AppText.apiHashRequired;
                  if (v.trim().length < 16) return AppText.apiHashTooShort;
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AuthTextField(
                controller: _phoneCtrl,
                label: AppText.phoneNumber,
                hint: AppText.phoneNumberHint,
                icon: Icons.phone_rounded,
                keyboardType: TextInputType.phone,
                validator: (v) {
                  if (v == null || v.trim().isEmpty)
                    return AppText.phoneNumberRequired;
                  if (v.trim().length < 8) return AppText.phoneNumberInvalid;
                  return null;
                },
              ),
              AppSpacing.gapXXL,
              PrimaryButton(
                label: AppText.continueButton,
                isLoading: isLoading,
                onPressed: _submit,
              ),
              AppSpacing.gapXL,
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
    return AppCard(
      padding: AppSpacing.allMD,
      borderColor: AppColors.primary.withValues(alpha: 0.2),
      color: AppColors.primary.withValues(alpha: 0.08),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded,
              color: AppColors.primary, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              AppText.credentialsStoredOnDevice,
              style: AppTextStyles.bodySmall(context)
                  ?.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
