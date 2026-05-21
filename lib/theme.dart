import 'package:flutter/material.dart';
import 'models/task.dart';

class AppTheme {
  static const baseText = Color(0xFF1C1917);
  static const secondaryText = Color(0xFF78716C);
  static const divider = Color(0xFFE7E5E4);

  static const effortLight = Color(0xFF3B82F6);
  static const effortMedium = Color(0xFFEAB308);
  static const effortHeavy = Color(0xFFEF4444);
  static const success = Color(0xFF22C55E);
  static const danger = Color(0xFFEF4444);

  static const confettiColors = [
    Color(0xFFFBBF24),
    Color(0xFFF472B6),
    Color(0xFF34D399),
    Color(0xFF60A5FA),
    Color(0xFFA78BFA),
    Color(0xFFFB923C),
    Color(0xFFFACC15),
    Color(0xFF4ADE80),
  ];

  static Color effortColor(EffortLevel level) {
    switch (level) {
      case EffortLevel.light: return effortLight;
      case EffortLevel.medium: return effortMedium;
      case EffortLevel.heavy: return effortHeavy;
    }
  }

  static Color backgroundForMode(AppMode mode) {
    switch (mode) {
      case AppMode.rescue: return const Color(0xFFFEF7F2);
      case AppMode.daily: return const Color(0xFFF5FBFA);
      case AppMode.energy: return const Color(0xFFFEF5F5);
    }
  }

  static Color surfaceForMode(AppMode mode) {
    switch (mode) {
      case AppMode.rescue: return const Color(0xFFFDF0E5);
      case AppMode.daily: return const Color(0xFFE8F5F2);
      case AppMode.energy: return const Color(0xFFFDE8E8);
    }
  }

  static Color surfaceElevatedForMode(AppMode mode) {
    switch (mode) {
      case AppMode.rescue: return const Color(0xFFFCE4D0);
      case AppMode.daily: return const Color(0xFFD4EDE8);
      case AppMode.energy: return const Color(0xFFFBC8C8);
    }
  }

  static Color accentForMode(AppMode mode) {
    switch (mode) {
      case AppMode.rescue: return const Color(0xFFD97706);
      case AppMode.daily: return const Color(0xFF0D9488);
      case AppMode.energy: return const Color(0xFFF97316);
    }
  }

  static Color accentHoverForMode(AppMode mode) {
    switch (mode) {
      case AppMode.rescue: return const Color(0xFFB45309);
      case AppMode.daily: return const Color(0xFF0F766E);
      case AppMode.energy: return const Color(0xFFEA580C);
    }
  }

  static Color accentSurfaceForMode(AppMode mode) {
    switch (mode) {
      case AppMode.rescue: return const Color(0x1FD97706);
      case AppMode.daily: return const Color(0x1F0D9488);
      case AppMode.energy: return const Color(0x1FF97316);
    }
  }

  static String modeEmoji(AppMode mode) {
    switch (mode) {
      case AppMode.rescue: return '🆘';
      case AppMode.daily: return '🌤️';
      case AppMode.energy: return '⚡';
    }
  }

  static String modeLabel(AppMode mode) {
    switch (mode) {
      case AppMode.rescue: return '救援';
      case AppMode.daily: return '日常';
      case AppMode.energy: return '高能';
    }
  }

  static String effortEmoji(EffortLevel level) {
    switch (level) {
      case EffortLevel.light: return '🔵';
      case EffortLevel.medium: return '🟡';
      case EffortLevel.heavy: return '🔴';
    }
  }
}
