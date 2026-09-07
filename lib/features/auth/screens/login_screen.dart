import 'package:flutter/material.dart';
import '../../../app/routes.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/info_banner.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../data/dummy_data/dummy_accounts.dart';
import '../../../data/models/user_role.dart';
import '../widgets/role_badge_card.dart';

/// Staff/Owner/Delivery sign-in screen with a "Quick Demo Role Switcher"
/// (dummy-data only) plus a link out to Customer account access.
///
/// This is a FRONTEND-ONLY simulated login: there is no backend. Signing in
/// with one of the documented dummy emails (see [kDemoAccounts]) routes to
/// that role's portal; any other input falls back to whichever role badge
/// is currently selected.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(text: 'staff@melainuts.com');
  final _passwordController = TextEditingController(text: kDemoPassword);
  UserRole _selectedRole = UserRole.staff;
  bool _submitting = false;

  void _applyDemoAccount(DemoAccount account) {
    setState(() {
      _selectedRole = account.role;
      _emailController.text = account.email;
      _passwordController.text = account.password;
    });
  }

  Future<void> _signIn() async {
    final matched = findDemoAccountByEmail(_emailController.text);
    final role = matched?.role ?? _selectedRole;

    setState(() => _submitting = true);
    // Simulate a brief network round-trip so the loading state is visible.
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _submitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Simulated sign-in as ${role.label}')),
    );
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.homeFor(role), (r) => false);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.xs,
            AppSpacing.md,
            AppSpacing.lg,
          ),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    AppConstants.hubLabel,
                    style: AppTextStyles.bodySm,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.successBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '● System Online',
                    style: AppTextStyles.labelMd.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(color: AppColors.border),
                boxShadow: AppShadows.md,
              ),
              child: Column(
                children: [
                  const AppLogo(size: 76),
                  const SizedBox(height: 14),
                  Text(
                    'Welcome Back',
                    style: AppTextStyles.headlineLg.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Enter authorized credentials to access branch\ninventory, register, and logistics.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMd,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const InfoBanner(
                    icon: Icons.shield_outlined,
                    title: 'Security Policy',
                    text:
                        'Staff access requires authenticated email & password. RFID hardware is restricted to shopper loyalty.',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    label: 'Email or Username',
                    controller: _emailController,
                    prefixIcon: Icons.person_outline_rounded,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Password', style: AppTextStyles.labelLg),
                      TextButton(
                        onPressed: () => Navigator.of(
                          context,
                        ).pushNamed(AppRoutes.forgotPassword),
                        child: const Text('Forgot Password?'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: AppTextStyles.bodyLg,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(
                        Icons.lock_outline_rounded,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Demo password for every account: $kDemoPassword',
                      style: AppTextStyles.bodySm,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  PrimaryButton(
                    label: 'Sign In to Portal',
                    icon: Icons.login_rounded,
                    loading: _submitting,
                    onPressed: _signIn,
                  ),
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: () =>
                        Navigator.of(context).pushNamed(AppRoutes.security),
                    icon: const Icon(Icons.shield_outlined, size: 16),
                    label: const Text('Login & Security Settings'),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'CUSTOMER ACCESS',
                          style: AppTextStyles.labelSm,
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 14),
                  InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => Navigator.of(
                      context,
                    ).pushNamed(AppRoutes.customerAccess),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.warningBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.outlineVariant),
                        boxShadow: AppShadows.sm,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.contactless_rounded,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'CUSTOMER ACCOUNT ACCESS',
                                  style: AppTextStyles.labelSm,
                                ),
                                Text(
                                  'Ordering & RFID Loyalty Account →',
                                  style: AppTextStyles.titleMd.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.border),
                boxShadow: AppShadows.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.badge_outlined,
                        size: 18,
                        color: AppColors.darkBrown,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Quick Demo Role Switcher',
                          style: AppTextStyles.titleMd,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Frontend Demo',
                          style: AppTextStyles.labelSm,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap any role badge to auto-populate demo credentials.',
                    style: AppTextStyles.bodySm,
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 2.6,
                    children: kDemoAccounts.map((acc) {
                      return RoleBadgeCard(
                        role: acc.role,
                        name: acc.name,
                        subtitle: acc.subtitle,
                        selected: _selectedRole == acc.role,
                        onTap: () => _applyDemoAccount(acc),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Active Selection:', style: AppTextStyles.bodySm),
                      Text(
                        '${_selectedRole.shortLabel}: ${AppConstants.branches.first}',
                        style: AppTextStyles.labelLg.copyWith(
                          color: _selectedRole.color,
                        ),
                      ),
                    ],
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
