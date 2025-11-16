import 'package:flutter/material.dart';

/// Application color palette with glassmorphism aesthetic
class AppColors {
  AppColors._();

  // Primary Colors - Purple Gradient
  static const Color primaryPurple = Color(0xFF667EEA);
  static const Color primaryPurpleDark = Color(0xFF764BA2);
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryPurple, primaryPurpleDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Accent Colors
  static const Color accentGreen = Color(0xFF00C9A7); // Success, growth, trees
  static const Color accentOrange = Color(0xFFFF6B6B); // Urgency, alerts, errors
  static const Color accentBlue = Color(0xFF4D96FF); // Information, links
  static const Color accentYellow = Color(0xFFFFC93C); // Warnings, highlights
  static const Color accentPink = Color(0xFFFF6BCB); // Creative, fun
  static const Color accentTeal = Color(0xFF00D9FF); // Cool, calm

  // Background Gradients
  static const LinearGradient backgroundGradientLight = LinearGradient(
    colors: [Color(0xFFF093FB), Color(0xFFF5576C)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient backgroundGradientDark = LinearGradient(
    colors: [Color(0xFF2C3E50), Color(0xFF1A1A2E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient backgroundGradientBlue = LinearGradient(
    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradientGreen = LinearGradient(
    colors: [Color(0xFF00C9A7), Color(0xFF00D9B5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradientSunset = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFFFE66D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradientOcean = LinearGradient(
    colors: [Color(0xFF4D96FF), Color(0xFF6BCCFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Glass Panel Colors
  static const Color glassPanelLight = Color(0xB3FFFFFF); // 70% white
  static const Color glassPanelDark = Color(0xB31A1A2E); // 70% dark blue
  static const Color glassPanelTransparent = Color(0x66FFFFFF); // 40% white

  // Text Colors
  static const Color textPrimary = Color(0xFF2D3748);
  static const Color textSecondary = Color(0xFF718096);
  static const Color textTertiary = Color(0xFFA0AEC0);
  static const Color textDark = Color(0xFFE2E8F0);
  static const Color textDarkSecondary = Color(0xFFCBD5E0);

  // Background Colors
  static const Color backgroundLight = Color(0xFFF7FAFC);
  static const Color backgroundDark = Color(0xFF1A202C);

  // Border Colors
  static const Color borderLight = Color(0x33FFFFFF); // 20% white
  static const Color borderDark = Color(0x1AFFFFFF); // 10% white

  // Shadow Colors
  static const Color shadowLight = Color(0x1A000000); // 10% black
  static const Color shadowDark = Color(0x33000000); // 20% black

  // Status Colors
  static const Color success = Color(0xFF00C9A7);
  static const Color warning = Color(0xFFFFC93C);
  static const Color error = Color(0xFFFF6B6B);
  static const Color info = Color(0xFF4D96FF);

  // Tree Colors (for different tree species)
  static const Color treeOak = Color(0xFF8B4513);
  static const Color treePine = Color(0xFF228B22);
  static const Color treeMaple = Color(0xFFFF6347);
  static const Color treeCherry = Color(0xFFFFB7C5);
  static const Color treeBirch = Color(0xFFF5F5DC);
  static const Color treeWillow = Color(0xFF9ACD32);
  static const Color treeCedar = Color(0xFFCD853F);
  static const Color treeRedwood = Color(0xFFA0522D);
  static const Color treeBamboo = Color(0xFF7CFC00);
  static const Color treePalm = Color(0xFF32CD32);

  // Badge Colors by Rarity
  static const Color badgeCommon = Color(0xFF9CA3AF);
  static const Color badgeUncommon = Color(0xFF22C55E);
  static const Color badgeRare = Color(0xFF3B82F6);
  static const Color badgeEpic = Color(0xFF9333EA);
  static const Color badgeLegendary = Color(0xFFFBBF24);

  // Chart Colors
  static const List<Color> chartColors = [
    accentBlue,
    accentGreen,
    accentOrange,
    accentPink,
    accentYellow,
    accentTeal,
    primaryPurple,
    primaryPurpleDark,
  ];

  // Priority Colors
  static const Color priorityLow = Color(0xFF10B981);
  static const Color priorityMedium = Color(0xFFF59E0B);
  static const Color priorityHigh = Color(0xFFEF4444);
  static const Color priorityUrgent = Color(0xFFDC2626);

  // Accessibility - High Contrast Mode
  static const Color highContrastBackground = Color(0xFF000000);
  static const Color highContrastForeground = Color(0xFFFFFFFF);
  static const Color highContrastAccent = Color(0xFFFFFF00);

  // Accessibility - Color Blind Palettes

  // Protanopia (Red-blind)
  static const List<Color> protanopiaColors = [
    Color(0xFF0173B2), // Blue
    Color(0xFFDE8F05), // Orange
    Color(0xFF029E73), // Teal
    Color(0xFFCC78BC), // Pink
  ];

  // Deuteranopia (Green-blind)
  static const List<Color> deuteranopiaColors = [
    Color(0xFF0173B2), // Blue
    Color(0xFFDE8F05), // Orange
    Color(0xFF029E73), // Teal
    Color(0xFFCC78BC), // Pink
  ];

  // Tritanopia (Blue-blind)
  static const List<Color> tritanopiaColors = [
    Color(0xFFD55E00), // Vermillion
    Color(0xFF0072B2), // Blue
    Color(0xFF009E73), // Bluish green
    Color(0xFFCC79A7), // Reddish purple
  ];

  /// Get color by priority level
  static Color getColorByPriority(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return priorityUrgent;
      case 'high':
        return priorityHigh;
      case 'medium':
        return priorityMedium;
      case 'low':
      default:
        return priorityLow;
    }
  }

  /// Get color by badge rarity
  static Color getColorByRarity(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'legendary':
        return badgeLegendary;
      case 'epic':
        return badgeEpic;
      case 'rare':
        return badgeRare;
      case 'uncommon':
        return badgeUncommon;
      case 'common':
      default:
        return badgeCommon;
    }
  }

  /// Get color by tree species
  static Color getColorByTreeSpecies(String species) {
    switch (species.toLowerCase()) {
      case 'oak':
        return treeOak;
      case 'pine':
        return treePine;
      case 'maple':
        return treeMaple;
      case 'cherry':
        return treeCherry;
      case 'birch':
        return treeBirch;
      case 'willow':
        return treeWillow;
      case 'cedar':
        return treeCedar;
      case 'redwood':
        return treeRedwood;
      case 'bamboo':
        return treeBamboo;
      case 'palm':
        return treePalm;
      default:
        return treeOak;
    }
  }

  /// Get chart color by index (cycles through colors)
  static Color getChartColor(int index) {
    return chartColors[index % chartColors.length];
  }
}
