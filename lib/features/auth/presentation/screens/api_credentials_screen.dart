import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
  final _phoneCtrl = TextEditingController();

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final phone = _phoneCtrl.text.trim();

    await ref.read(authProvider.notifier).sendCode(
          phone: phone,
        );

    if (!mounted) return;

    final state = ref.read(authProvider);

    if (state.step == AuthStep.codeSent) {
      context.push(
        '${AppRoutes.verifyCode}?phone=${Uri.encodeComponent(phone)}',
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
            content: Text(next.error!),
            backgroundColor: AppColors.error,
          ),
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
              AppSpacing.gapXS,
              Text(
                AppText.enterPhoneNumber,
                style: AppTextStyles.headlineSmall(context),
              ),
              AppSpacing.gapXS,
              Text(
                AppText.phoneLoginDescription,
                style: AppTextStyles.bodyMedium(context),
              ),
              const SizedBox(height: 32),
              AuthTextField(
                controller: _phoneCtrl,
                label: AppText.phoneNumber,
                hint: AppText.phoneNumberHint,
                icon: Icons.phone_rounded,
                keyboardType: TextInputType.phone,
                autofocus: true,
                validator: (v) {
                  final value = v?.trim() ?? '';

                  if (value.isEmpty) {
                    return AppText.phoneNumberRequired;
                  }

                  if (value.length < 8) {
                    return AppText.phoneNumberInvalid;
                  }

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
              const _InfoCard(),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: AppSpacing.allMD,
      borderColor: AppColors.primary.withValues(alpha: 0.2),
      color: AppColors.primary.withValues(alpha: 0.08),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              AppText.telegramSessionStoredOnDevice,
              style: AppTextStyles.bodySmall(context)?.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
