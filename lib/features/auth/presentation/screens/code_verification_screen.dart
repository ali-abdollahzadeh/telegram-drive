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

class CodeVerificationScreen extends ConsumerStatefulWidget {
  final String phoneNumber;
  const CodeVerificationScreen({super.key, required this.phoneNumber});

  @override
  ConsumerState<CodeVerificationScreen> createState() => _CodeVerificationScreenState();
}

class _CodeVerificationScreenState extends ConsumerState<CodeVerificationScreen> {
  final _codeCtrl = TextEditingController();
  int _countdown = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() {
        _countdown--;
        if (_countdown <= 0) {
          _canResend = true;
          _countdown = 0;
        }
      });
      return _countdown > 0;
    });
  }

  Future<void> _verify() async {
    if (_codeCtrl.text.trim().length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppText.pleaseEnterFullCode)),
      );
      return;
    }

    final success = await ref.read(authProvider.notifier).verifyCode(_codeCtrl.text.trim());
    if (!mounted) return;

    if (success) {
      context.go(AppRoutes.drive);
    } else {
      final state = ref.read(authProvider);
      if (state.step == AuthStep.needs2FA) {
        context.push(AppRoutes.verifyPassword);
      }
    }
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
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
        title: const Text(AppText.verifyCode),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: Padding(
        padding: AppSpacing.screen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSpacing.gapXS,
            Text(
              AppText.enterVerificationCode,
              style: AppTextStyles.headlineSmall(context),
            ),
            AppSpacing.gapXS,
            Text(
              '${AppText.codeSentTo}${widget.phoneNumber}',
              style: AppTextStyles.bodyMedium(context),
            ),
            AppSpacing.gapXXXL,

            AuthTextField(
              controller: _codeCtrl,
              label: AppText.verificationCode,
              hint: AppText.verificationCodeHint,
              icon: Icons.verified_rounded,
              keyboardType: TextInputType.number,
              autofocus: true,
              maxLength: 6,
            ),
            AppSpacing.gapMD,

            // Resend row
            Row(
              children: [
                Text(
                  _canResend ? AppText.didntReceiveCode : '${AppText.resendIn}${_countdown}s',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (_canResend) ...[
                  AppSpacing.hGapXXS,
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _countdown = 60;
                        _canResend = false;
                      });
                      _startCountdown();
                    },
                    style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                    child: const Text(AppText.resend),
                  ),
                ],
              ],
            ),
            AppSpacing.gapXXL,
            PrimaryButton(
              label: AppText.verify,
              isLoading: isLoading,
              onPressed: _verify,
            ),
          ],
        ),
      ),
    );
  }
}
