import 'package:flutter/material.dart';
import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/info_banner.dart';
import '../../../core/widgets/melai_app_bar.dart';
import '../../../core/widgets/primary_button.dart';

/// "Account Security Recovery" — request a password reset code/link.
///
/// This simulates the reset process only: no email is actually sent, and
/// after a brief delay the person is taken straight to the Reset Password
/// screen (frontend-only, no backend).
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController(
    text: 'staff.santacruz@melainuts.ph',
  );
  bool _sending = false;

  Future<void> _sendResetCode() async {
    setState(() => _sending = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _sending = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Simulated reset code sent — check your email.'),
      ),
    );
    Navigator.of(context).pushNamed(AppRoutes.resetPassword);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: const MelaiAppBar(title: 'Melai Nuts Retailing', showBack: true),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
                boxShadow: AppShadows.md,
              ),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.vpn_key_rounded,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text('ACCOUNT SECURITY RECOVERY', style: AppTextStyles.labelSm),
                  const SizedBox(height: 6),
                  Text(
                    'Reset Your Password',
                    style: AppTextStyles.headlineLg.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter your registered employee or customer email to receive a secure recovery code.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMd,
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Email Address', style: AppTextStyles.labelLg),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                      suffixIcon: Icon(
                        Icons.verified_rounded,
                        color: AppColors.success,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Associated with Santa Cruz Main Retail and POS register roles.',
                      style: AppTextStyles.bodySm,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const InfoBanner(
                    text:
                        'A 6-digit verification code will be dispatched to your email for Laguna branch personnel verification.',
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    label: 'Send Reset Code / Link',
                    icon: Icons.send_rounded,
                    loading: _sending,
                    onPressed: _sendResetCode,
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Back to Login'),
                  ),
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    'Having trouble? Contact Melai Nuts HQ Admin at support@melainuts.ph.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySm,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
