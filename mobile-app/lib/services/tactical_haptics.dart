import 'package:flutter/services.dart';

class TacticalHaptics {
  /// Trigger light impact on scan button taps or action triggers
  static Future<void> triggerScan() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (_) {}
  }

  /// Trigger heavy impact on malicious detection, medium on suspicious, light on safe
  static Future<void> triggerVerdict(String? verdict) async {
    try {
      final normalized = verdict?.toUpperCase() ?? '';
      if (normalized == 'MALICIOUS') {
        await HapticFeedback.heavyImpact();
        await Future.delayed(const Duration(milliseconds: 140));
        await HapticFeedback.heavyImpact();
      } else if (normalized == 'SUSPICIOUS') {
        await HapticFeedback.mediumImpact();
      } else {
        await HapticFeedback.lightImpact();
      }
    } catch (_) {}
  }
}
