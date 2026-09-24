import 'dart:async';
import 'package:flutter/material.dart';
import '../../../app/routes.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../data/models/user_role.dart';
import 'email_verification_screen.dart';

/// First screen shown on launch. Runs a short "connecting to branch
/// network" animation while, in parallel, checking whether someone is
/// already signed in (Firebase persists sessions across app restarts) so
/// returning users land straight back in their portal instead of Login.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _progress = 0.62;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 220), (t) {
      setState(() {
        _progress += 0.06;
        if (_progress >= 1) {
          _progress = 1;
          t.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  bool _resolving = false;

  Future<void> _proceed() async {
    if (_resolving) return;
    setState(() => _resolving = true);
    try {
      final profile = await AuthService.instance.loadCurrentProfile(
        allowVerificationResume: true,
      );
      if (!mounted) return;
      if (profile != null) {
        final destination = profile.role == UserRole.customer
            ? AppRoutes.homeFor(UserRole.customer)
            : AppRoutes.homeFor(profile.role);
        Navigator.of(context).pushReplacementNamed(destination);
        return;
      }
    } on EmailVerificationRequiredException {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const EmailVerificationScreen()),
      );
      return;
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      // Ignore — e.g. no network on first launch. Fall through to Login,
      // which will surface a clearer error on the actual sign-in attempt.
    }
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.verified_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'LAGUNA COMMERCIAL OPERATIONS',
                      style: AppTextStyles.labelMd.copyWith(
                        color: AppColors.darkBrown,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.successBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.circle,
                          size: 8,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Multi-Branch Connected',
                          style: AppTextStyles.labelMd.copyWith(
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              const AppLogo(size: 120),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  '🌿 ARTISAN ROASTED',
                  style: AppTextStyles.labelMd.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                AppConstants.appName,
                style: AppTextStyles.headlineLg.copyWith(
                  color: AppColors.primary,
                  fontSize: 30,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                AppConstants.appTagline,
                style: AppTextStyles.headlineSm.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Laguna Multi-Branch Enterprise POS & Supply System\n(Calamba • Los Baños • Santa Cruz)',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMd,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  for (final b in AppConstants.branches)
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border),
                          boxShadow: AppShadows.sm,
                        ),
                        child: Column(
                          children: [
                            Text(
                              b.split(' ').first,
                              style: AppTextStyles.labelLg,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              b == AppConstants.branches.first ? '● Main Hub' : '● Synced',
                              style: AppTextStyles.bodySm.copyWith(
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(
                    Icons.sync_rounded,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Initializing Central Catalogs...',
                      style: AppTextStyles.bodyMd,
                    ),
                  ),
                  Text(
                    '${(_progress * 100).clamp(0, 100).toInt()}%',
                    style: AppTextStyles.labelLg.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: _progress.clamp(0, 1),
                  minHeight: 6,
                  backgroundColor: AppColors.border,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _resolving ? null : _proceed,
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text('Get Started / Sign In'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _resolving ? null : _proceed,
                  icon: const Icon(Icons.qr_code_2_rounded, size: 18),
                  label: const Text('Quick Terminal Register Check'),
                ),
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 10),
              Text(
                '● Laguna Enterprise Server: Online & Synchronized',
                style: AppTextStyles.bodySm.copyWith(color: AppColors.success),
              ),
              const SizedBox(height: 4),
              Text(
                'Branch Portal v2.4 Capstone Edition',
                style: AppTextStyles.bodySm,
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
