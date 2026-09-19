import 'package:flutter/material.dart';
import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/melai_app_bar.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../data/dummy_data/dummy_deliveries.dart';
import '../../../data/models/delivery.dart';

/// Report a delay for a stop — pick a reason, see the simulated impact on
/// later ETAs, then continue the route.
class DelayedDeliveryScreen extends StatefulWidget {
  final Delivery delivery;
  final DeliveryStop stop;

  DelayedDeliveryScreen({super.key, Delivery? delivery, DeliveryStop? stop})
      : delivery = delivery ?? kDeliveries.first,
        stop = stop ?? (delivery ?? kDeliveries.first).stops.first;

  @override
  State<DelayedDeliveryScreen> createState() => _DelayedDeliveryScreenState();
}

class _DelayedDeliveryScreenState extends State<DelayedDeliveryScreen> {
  String _reason = 'Traffic congestion';
  final _noteController = TextEditingController();
  bool _submitting = false;

  static const _reasons = [
    'Traffic congestion',
    'Customer unavailable',
    'Incorrect address',
    'Vehicle issue',
    'Weather conditions',
  ];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _submitting = false);

    widget.stop.status = StopStatus.delayed;
    widget.stop.issueReason = _noteController.text.trim().isEmpty ? _reason : '$_reason — ${_noteController.text.trim()}';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Simulated: delay logged for ${widget.stop.customerName}. Later ETAs adjusted.')),
    );
    Navigator.of(context).pushReplacementNamed(AppRoutes.deliveryNextStop, arguments: widget.delivery);
  }

  @override
  Widget build(BuildContext context) {
    final laterStops = widget.delivery.stops.where((s) => s.sequenceIndex > widget.stop.sequenceIndex).toList();

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: const MelaiAppBar(title: 'Report Delay', showBack: true),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.warningBg, borderRadius: BorderRadius.circular(AppSpacing.radiusMd), border: Border.all(color: AppColors.warning.withValues(alpha: 0.4))),
              child: Row(
                children: [
                  const Icon(Icons.schedule_rounded, color: AppColors.warning),
                  const SizedBox(width: 10),
                  Expanded(child: Text('Reporting a delay for ${widget.stop.customerName}.', style: AppTextStyles.bodyMd)),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Reason for Delay', style: AppTextStyles.headlineSm),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final r in _reasons)
                  ChoiceChip(
                    label: Text(r),
                    selected: _reason == r,
                    onSelected: (_) => setState(() => _reason = r),
                    selectedColor: AppColors.warning.withValues(alpha: 0.2),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Additional Notes (optional)', style: AppTextStyles.labelLg),
            const SizedBox(height: 6),
            TextField(controller: _noteController, maxLines: 2, decoration: const InputDecoration(hintText: 'Add more detail...')),
            if (laterStops.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              Text('Impact on Remaining Stops', style: AppTextStyles.headlineSm),
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppSpacing.radiusMd), border: Border.all(color: AppColors.border)),
                child: Column(
                  children: [
                    for (final s in laterStops)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.arrow_upward_rounded, size: 14, color: AppColors.warning),
                            const SizedBox(width: 6),
                            Expanded(child: Text(s.customerName, style: AppTextStyles.bodyMd, maxLines: 1, overflow: TextOverflow.ellipsis)),
                            Text('ETA shifts later', style: AppTextStyles.bodySm.copyWith(color: AppColors.warning)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: 'Log Delay & Continue',
              icon: Icons.check_rounded,
              loading: _submitting,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
