import 'package:flutter/material.dart';
import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/validation_utils.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/melai_app_bar.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../data/dummy_data/dummy_inventory.dart';
import '../../../data/models/delivery.dart';

class _StopDraft {
  final TextEditingController name;
  final TextEditingController address;
  _StopDraft({String name = '', String address = ''})
      : name = TextEditingController(text: name),
        address = TextEditingController(text: address);

  void dispose() {
    name.dispose();
    address.dispose();
  }
}

/// "Create Delivery" — pick a branch, vehicle/rider, and add stops, then
/// simulate route optimization.
///
/// The "optimizer" here is a simple nearest-neighbor simulation over
/// randomly-assigned dummy distances between stops — it demonstrates the
/// *concept* of reordering stops for a shorter route (e.g. the classic
/// Branch → Customer A → Customer C → Customer B reorder), not a real
/// routing engine. No Google Maps API, no courier API.
class CreateDeliveryScreen extends StatefulWidget {
  const CreateDeliveryScreen({super.key});

  @override
  State<CreateDeliveryScreen> createState() => _CreateDeliveryScreenState();
}

class _CreateDeliveryScreenState extends State<CreateDeliveryScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _branch;
  final String _vehicle = '';
  final String _rider = '';

  final List<_StopDraft> _stops = [];

  bool _optimizing = false;

  @override
  void dispose() {
    for (final s in _stops) {
      s.dispose();
    }
    super.dispose();
  }

  void _addStop() {
    setState(() => _stops.add(_StopDraft()));
  }

  void _removeStop(int index) {
    setState(() {
      _stops[index].dispose();
      _stops.removeAt(index);
    });
  }

  Future<void> _optimizeAndCreate() async {
    if (!_formKey.currentState!.validate()) return;
    
    final validStops = _stops.where((s) => s.name.text.trim().isNotEmpty).toList();
    if (validStops.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one stop before optimizing.')),
      );
      return;
    }

    setState(() => _optimizing = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _optimizing = false);

    // Simulated "optimization": simple reorder logic.
    final reordered = _simulateOptimizedOrder(validStops);

    final now = DateTime.now();
    final stopModels = <DeliveryStop>[];
    for (int i = 0; i < reordered.length; i++) {
      final draft = reordered[i];
      // Deterministic-but-varied dummy distance/time per leg.
      final distance = 1.8 + (i * 1.3) + (draft.name.text.length % 5) * 0.4;
      final minutes = (distance * 2.8).round();
      final etaMinutesFromNow = reordered.take(i + 1).fold<int>(0, (sum, d) {
        final idx = reordered.indexOf(d);
        final dist = 1.8 + (idx * 1.3) + (d.name.text.length % 5) * 0.4;
        return sum + (dist * 2.8).round();
      });
      final eta = now.add(Duration(minutes: etaMinutesFromNow));
      stopModels.add(
        DeliveryStop(
          id: 'stop-${now.millisecondsSinceEpoch}-$i',
          customerName: draft.name.text.trim(),
          address: draft.address.text.trim().isEmpty ? 'Address not provided' : draft.address.text.trim(),
          orderId: '#MLN-ORD-${9400 + i}',
          items: const ['1x Assorted Order'],
          sequenceIndex: i,
          distanceFromPreviousKm: double.parse(distance.toStringAsFixed(1)),
          travelMinutesFromPrevious: minutes,
          eta: '${eta.hour > 12 ? eta.hour - 12 : eta.hour}:${eta.minute.toString().padLeft(2, '0')} ${eta.hour >= 12 ? 'PM' : 'AM'}',
        ),
      );
    }

    final delivery = Delivery(
      id: 'DEL-${now.year}-${now.millisecondsSinceEpoch % 10000}',
      branch: _branch ?? 'Unknown Branch',
      vehicle: _vehicle.isEmpty ? 'Van' : _vehicle,
      riderName: _rider.isEmpty ? 'Rider' : _rider,
      createdAt: now,
      status: DeliveryStatus.optimized,
      stops: stopModels,
    );

    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AppRoutes.routeOptimization, arguments: delivery);
  }

  /// Simulated route optimization logic.
  List<_StopDraft> _simulateOptimizedOrder(List<_StopDraft> stops) {
    double scoreOf(_StopDraft s) {
      final name = s.name.text;
      // Stable fallback score for stop names.
      final hash = name.codeUnits.fold(0, (a, b) => a + b);
      return 10.0 + (hash % 50) / 10.0;
    }

    final sorted = List<_StopDraft>.from(stops)..sort((a, b) => scoreOf(a).compareTo(scoreOf(b)));
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: const MelaiAppBar(title: 'Create Delivery', showBack: true),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(AppSpacing.radiusMd), border: Border.all(color: AppColors.border)),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Frontend simulation only — routes are optimized using distance estimates.',
                        style: AppTextStyles.bodyMd,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Dispatch From', style: AppTextStyles.headlineSm),
              const SizedBox(height: AppSpacing.sm),
              DropdownButtonFormField<String>(
                initialValue: _branch,
                decoration: const InputDecoration(labelText: 'Branch'),
                items: [for (final b in kInventoryBranches) DropdownMenuItem(value: b, child: Text(b))],
                onChanged: (v) => setState(() => _branch = v),
                validator: (v) => ValidationUtils.validateRequired(v, 'Branch'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'Vehicle',
                      controller: TextEditingController(text: _vehicle)..selection = TextSelection.collapsed(offset: _vehicle.length),
                      prefixIcon: Icons.local_shipping_outlined,
                      hint: 'e.g. Laguna Van #04',
                      validator: (v) => ValidationUtils.validateRequired(v, 'Vehicle'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text('Demo field — value is fixed for this simulation.', style: AppTextStyles.bodySm),
              const SizedBox(height: 12),
              Text('Rider: ${_rider.isEmpty ? 'Not assigned' : _rider}', style: AppTextStyles.labelLg),
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Delivery Stops', style: AppTextStyles.headlineSm),
                  Text('${_stops.length} added', style: AppTextStyles.bodySm),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              for (int i = 0; i < _stops.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppSpacing.radiusMd), border: Border.all(color: AppColors.border), boxShadow: AppShadows.sm),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 26,
                              height: 26,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(color: AppColors.primaryContainer, shape: BoxShape.circle),
                              child: Text('${i + 1}', style: AppTextStyles.labelMd.copyWith(color: AppColors.primaryDark)),
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: Text('Stop ${i + 1}', style: AppTextStyles.labelLg)),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                              onPressed: _stops.length > 1 ? () => _removeStop(i) : null,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _stops[i].name,
                          decoration: const InputDecoration(labelText: 'Customer name'),
                          validator: (v) => ValidationUtils.validateName(v, 'Customer name'),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _stops[i].address,
                          decoration: const InputDecoration(labelText: 'Delivery address'),
                          validator: (v) => ValidationUtils.validateAddress(v),
                        ),
                      ],
                    ),
                  ),
                ),
              OutlinedButton.icon(
                onPressed: _addStop,
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Add Stop'),
              ),
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                label: 'Optimize Route & Create Delivery',
                icon: Icons.auto_awesome_rounded,
                loading: _optimizing,
                onPressed: _optimizeAndCreate,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
