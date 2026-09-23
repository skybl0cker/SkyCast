import 'package:flutter/services.dart';

Future<void> hapticsForCode(int code) async {
  if (code >= 95) {
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 180));
    await HapticFeedback.heavyImpact();
  } else if ((code >= 51 && code <= 67) || (code >= 80 && code <= 82)) {
    await HapticFeedback.lightImpact();
  }
}
