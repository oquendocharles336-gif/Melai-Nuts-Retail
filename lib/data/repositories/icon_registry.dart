import 'package:flutter/material.dart';

/// Postgres can't store an [IconData] or [Color], so the catalog/rewards
/// tables store plain strings (`icon_name`, `color_hex`) and this registry
/// turns them back into the Flutter types the existing widgets expect.
class IconRegistry {
  IconRegistry._();

  static const Map<String, IconData> _icons = {
    'nuts': Icons.eco_rounded,
    'grain': Icons.grain_rounded,
    'local_fire_department': Icons.local_fire_department_rounded,
    'card_giftcard': Icons.card_giftcard_rounded,
    'category': Icons.category_rounded,
    'local_offer': Icons.local_offer_rounded,
    'redeem': Icons.redeem_rounded,
    'local_shipping': Icons.local_shipping_rounded,
    'stars': Icons.stars_rounded,
  };

  static IconData icon(String? name, {IconData fallback = Icons.category_rounded}) {
    if (name == null) return fallback;
    return _icons[name] ?? fallback;
  }

  static Color color(String? hex, {Color fallback = const Color(0xFF8D6E63)}) {
    if (hex == null || hex.isEmpty) return fallback;
    final cleaned = hex.replaceFirst('#', '');
    final value = int.tryParse(cleaned, radix: 16);
    if (value == null) return fallback;
    return Color(cleaned.length == 6 ? (0xFF000000 | value) : value);
  }
}
