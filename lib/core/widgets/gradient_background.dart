import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// A gradient background widget for full-screen backgrounds
class GradientBackground extends StatelessWidget {
  final Widget child;
  final Gradient? gradient;
  final List<Color>? colors;

  const GradientBackground({
    super.key,
    required this.child,
    this.gradient,
    this.colors,
  });

  /// Background with primary gradient
  const GradientBackground.primary({
    super.key,
    required this.child,
  })  : gradient = AppColors.backgroundGradientLight,
        colors = null;

  /// Background with dark gradient
  const GradientBackground.dark({
    super.key,
    required this.child,
  })  : gradient = AppColors.backgroundGradientDark,
        colors = null;

  /// Background with blue gradient
  const GradientBackground.blue({
    super.key,
    required this.child,
  })  : gradient = AppColors.backgroundGradientBlue,
        colors = null;

  /// Background with green gradient
  const GradientBackground.green({
    super.key,
    required this.child,
  })  : gradient = AppColors.backgroundGradientGreen,
        colors = null;

  /// Background with sunset gradient
  const GradientBackground.sunset({
    super.key,
    required this.child,
  })  : gradient = AppColors.backgroundGradientSunset,
        colors = null;

  /// Background with ocean gradient
  const GradientBackground.ocean({
    super.key,
    required this.child,
  })  : gradient = AppColors.backgroundGradientOcean,
        colors = null;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient ??
            LinearGradient(
              colors: colors ?? [
                AppColors.backgroundGradientLight.colors.first,
                AppColors.backgroundGradientLight.colors.last,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
      ),
      child: child,
    );
  }
}

/// An animated gradient background that transitions between gradients
class AnimatedGradientBackground extends StatefulWidget {
  final Widget child;
  final List<Gradient> gradients;
  final Duration duration;

  const AnimatedGradientBackground({
    super.key,
    required this.child,
    required this.gradients,
    this.duration = const Duration(seconds: 10),
  });

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState
    extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _currentGradientIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _currentGradientIndex =
              (_currentGradientIndex + 1) % widget.gradients.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: widget.duration,
      decoration: BoxDecoration(
        gradient: widget.gradients[_currentGradientIndex],
      ),
      child: widget.child,
    );
  }
}
