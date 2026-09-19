import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/melai_app_bar.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../data/models/order.dart';
import '../../../data/models/refund.dart';
import 'refund_success_screen.dart';
import 'refund_failed_screen.dart';

const List<String> _kStageLabels = ['Request Submitted', 'Under Review', 'Approved', 'Processing', 'Refunded'];

class RefundProcessingScreen extends StatefulWidget {
  final RefundRequest request;

  const RefundProcessingScreen({super.key, required this.request});

  @override
  State<RefundProcessingScreen> createState() => _RefundProcessingScreenState();
}

class _RefundProcessingScreenState extends State<RefundProcessingScreen> {
  late int _stage;
  bool _advancing = false;

  @override
  void initState() {
    super.initState();
    _stage = widget.request.timeline.lastIndexWhere((s) => s.done || s.current);
    if (_stage < 0) _stage = 0;
  }

  List<OrderTimelineStep> get _timeline => [
    for (int i = 0; i < _kStageLabels.length; i++)
      OrderTimelineStep(
        label: _kStageLabels[i],
        description: i < _stage ? 'Completed' : (i == _stage ? 'In progress' : 'Pending'),
        time: i < _stage ? 'Updated' : (i == _stage ? 'Now' : '—'),
        done: i < _stage,
        current: i == _stage,
      ),
  ];

  Future<void> _advance() async {
    setState(() => _advancing = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() {
      _advancing = false;
      if (_stage < _kStageLabels.length - 1) _stage++;
    });
    if (_stage == _kStageLabels.length - 1) {
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => RefundSuccessScreen(request: widget.request)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRejected = widget.request.status == RefundStatus.rejected;
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: MelaiAppBar(title: 'Refund ${widget.request.id}', showBack: true),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Order ${widget.request.orderId}', style: AppTextStyles.titleMd, overflow: TextOverflow.ellipsis),
                        Text(
                          '₱${widget.request.amount.toStringAsFixed(0)} • ${widget.request.reason}',
                          style: AppTextStyles.bodySm,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: widget.request.status.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(widget.request.status.label, style: AppTextStyles.labelMd.copyWith(color: widget.request.status.color)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Refund Timeline', style: AppTextStyles.titleMd),
            const SizedBox(height: AppSpacing.sm),
            if (isRejected)
              for (final step in widget.request.timeline) _TimelineRow(step: step, isLast: step == widget.request.timeline.last)
            else
              for (int i = 0; i < _timeline.length; i++)
                _TimelineRow(step: _timeline[i], isLast: i == _timeline.length - 1),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: isRejected
              ? PrimaryButton(
            label: 'View Rejection Details',
            icon: Icons.info_outline_rounded,
            onPressed: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => RefundFailedScreen(request: widget.request)),
            ),
          )
              : PrimaryButton(
            label: _stage == _kStageLabels.length - 1 ? 'View Refund Receipt' : 'Simulate: Move to Next Stage',
            icon: Icons.refresh_rounded,
            loading: _advancing,
            onPressed: _advance,
          ),
        ),
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final OrderTimelineStep step;
  final bool isLast;

  const _TimelineRow({required this.step, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final color = step.done ? AppColors.success : (step.current ? AppColors.primary : AppColors.border);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Icon(
                  step.done ? Icons.check : (step.current ? Icons.hourglass_top_rounded : Icons.circle),
                  size: 13,
                  color: Colors.white,
                ),
              ),
              if (!isLast) Expanded(child: Container(width: 2, color: AppColors.border)),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(step.label, style: AppTextStyles.labelLg.copyWith(color: step.current ? AppColors.primary : AppColors.textPrimary)),
                  Text(step.description, style: AppTextStyles.bodySm),
                  Text(step.time, style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}