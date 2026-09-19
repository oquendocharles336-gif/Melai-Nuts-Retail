import 'package:flutter/material.dart';
import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/melai_app_bar.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../data/dummy_data/dummy_deliveries.dart';
import '../../../data/models/delivery.dart';

/// Proof-of-delivery confirmation — a simulated signature/photo capture
/// placeholder plus an optional note, then marks the stop as delivered.
class DeliveryConfirmationScreen extends StatefulWidget {
  final Delivery delivery;
  final DeliveryStop stop;

  DeliveryConfirmationScreen({super.key, Delivery? delivery, DeliveryStop? stop})
      : delivery = delivery ?? kDeliveries.first,
        stop = stop ?? (delivery ?? kDeliveries.first).stops.first;

  @override
  State<DeliveryConfirmationScreen> createState() => _DeliveryConfirmationScreenState();
}

class _DeliveryConfirmationScreenState extends State<DeliveryConfirmationScreen> {
  final _noteController = TextEditingController();
  bool _signatureCaptured = false;
  bool _photoCaptured = false;
  bool _submitting = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    setState(() => _submitting = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _submitting = false);

    widget.stop.status = StopStatus.delivered;
    widget.stop.proofNote = _noteController.text.trim().isEmpty ? null : _noteController.text.trim();

    final nextStop = widget.delivery.stops.any((s) => s.status == StopStatus.pending || s.status == StopStatus.enRoute);
    if (!nextStop) {
      widget.delivery.status = DeliveryStatus.completed;
    }

    if (!mounted) return;
    if (nextStop) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.deliveryNextStop, arguments: widget.delivery);
    } else {
      Navigator.of(context).pushReplacementNamed(AppRoutes.deliveryCompleted, arguments: widget.delivery);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: const MelaiAppBar(title: 'Confirm Delivery', showBack: true),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppSpacing.radiusMd), border: Border.all(color: AppColors.border), boxShadow: AppShadows.sm),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: AppColors.primaryContainer, shape: BoxShape.circle),
                    child: const Icon(Icons.person, color: AppColors.primary),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.stop.customerName, style: AppTextStyles.labelLg),
                        Text(widget.stop.orderId, style: AppTextStyles.bodySm),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Proof of Delivery', style: AppTextStyles.headlineSm),
            const SizedBox(height: AppSpacing.sm),
            _ProofTile(
              icon: Icons.draw_outlined,
              title: 'Customer Signature',
              captured: _signatureCaptured,
              onTap: () => setState(() => _signatureCaptured = true),
            ),
            const SizedBox(height: 10),
            _ProofTile(
              icon: Icons.camera_alt_outlined,
              title: 'Photo of Delivered Package',
              captured: _photoCaptured,
              onTap: () => setState(() => _photoCaptured = true),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Delivery Note (optional)', style: AppTextStyles.labelLg),
            const SizedBox(height: 6),
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: const InputDecoration(hintText: 'e.g. Left with guard, gate code confirmed...'),
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Simulated proof capture — no camera or signature pad is actually used.', style: AppTextStyles.bodySm)),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: 'Confirm Delivery',
              icon: Icons.check_circle_outline_rounded,
              loading: _submitting,
              onPressed: _confirm,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProofTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool captured;
  final VoidCallback onTap;

  const _ProofTile({required this.icon, required this.title, required this.captured, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: captured ? AppColors.successBg : Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: captured ? AppColors.success.withValues(alpha: 0.4) : AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: captured ? AppColors.success : AppColors.textSecondary),
            const SizedBox(width: 10),
            Expanded(child: Text(title, style: AppTextStyles.labelLg)),
            Icon(
              captured ? Icons.check_circle : Icons.add_circle_outline_rounded,
              color: captured ? AppColors.success : AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
