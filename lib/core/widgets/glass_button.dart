import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// A glassmorphism-styled button with gradient background
class GlassButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Gradient? gradient;
  final Color? color;
  final Color? textColor;
  final Widget? icon;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final double? width;
  final double? height;
  final bool isLoading;
  final double blur;

  const GlassButton({
    super.key,
    required this.label,
    this.onPressed,
    this.gradient,
    this.color,
    this.textColor,
    this.icon,
    this.borderRadius = 16.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    this.width,
    this.height,
    this.isLoading = false,
    this.blur = 10.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null;

    return InkWell(
      onTap: isDisabled || isLoading ? null : onPressed,
      borderRadius: BorderRadius.circular(borderRadius),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            width: width,
            height: height,
            padding: padding,
            decoration: BoxDecoration(
              gradient: gradient ?? AppColors.primaryGradient,
              color: color,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: isDisabled
                  ? null
                  : [
                      BoxShadow(
                        color: (gradient?.colors.first ?? color ?? AppColors.primaryPurple)
                            .withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
            ),
            child: isLoading
                ? Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          textColor ?? Colors.white,
                        ),
                      ),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...[
                        icon!,
                        const SizedBox(width: 8),
                      ],
                      Text(
                        label,
                        style: TextStyle(
                          color: textColor ?? Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// An outlined glassmorphism button
class GlassOutlinedButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? borderColor;
  final Color? textColor;
  final Widget? icon;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final double? width;
  final double? height;
  final bool isLoading;

  const GlassOutlinedButton({
    super.key,
    required this.label,
    this.onPressed,
    this.borderColor,
    this.textColor,
    this.icon,
    this.borderRadius = 16.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    this.width,
    this.height,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: isDisabled || isLoading ? null : onPressed,
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        width: width,
        height: height,
        padding: padding,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: borderColor ?? AppColors.primaryPurple,
            width: 2,
          ),
        ),
        child: isLoading
            ? Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      textColor ?? AppColors.primaryPurple,
                    ),
                  ),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    icon!,
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      color: textColor ?? AppColors.primaryPurple,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// A text button with glass styling
class GlassTextButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? textColor;
  final Widget? icon;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final bool isLoading;

  const GlassTextButton({
    super.key,
    required this.label,
    this.onPressed,
    this.textColor,
    this.icon,
    this.borderRadius = 8.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null;

    return InkWell(
      onTap: isDisabled || isLoading ? null : onPressed,
      borderRadius: BorderRadius.circular(borderRadius),
      child: Padding(
        padding: padding,
        child: isLoading
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    textColor ?? AppColors.primaryPurple,
                  ),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    icon!,
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      color: textColor ?? AppColors.primaryPurple,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// A floating action button with glass styling
class GlassFloatingActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Gradient? gradient;
  final Color? backgroundColor;
  final double size;
  final double blur;

  const GlassFloatingActionButton({
    super.key,
    this.onPressed,
    required this.child,
    this.gradient,
    this.backgroundColor,
    this.size = 56.0,
    this.blur = 15.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: FloatingActionButton(
        onPressed: onPressed,
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(size / 2),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
            child: Container(
              decoration: BoxDecoration(
                gradient: gradient ?? AppColors.primaryGradient,
                color: backgroundColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (gradient?.colors.first ??
                        backgroundColor ??
                        AppColors.primaryPurple)
                        .withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Center(child: child),
            ),
          ),
        ),
      ),
    );
  }
}

/// An icon button with glass styling
class GlassIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget icon;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final double blur;
  final String? tooltip;

  const GlassIconButton({
    super.key,
    this.onPressed,
    required this.icon,
    this.backgroundColor,
    this.iconColor,
    this.size = 44.0,
    this.blur = 10.0,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBgColor = isDark
        ? AppColors.glassPanelDark
        : AppColors.glassPanelLight;

    Widget button = InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(size / 2),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: backgroundColor ?? defaultBgColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                width: 1,
              ),
            ),
            child: Center(
              child: IconTheme(
                data: IconThemeData(
                  color: iconColor ??
                      (isDark ? AppColors.textDark : AppColors.textPrimary),
                  size: size * 0.5,
                ),
                child: icon,
              ),
            ),
          ),
        ),
      ),
    );

    if (tooltip != null) {
      button = Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }
}
