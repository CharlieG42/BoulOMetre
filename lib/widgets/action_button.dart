import 'package:flutter/material.dart';
import 'package:boul_o_metre/utils/constants.dart';

class ActionButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isLoading;

  const ActionButton({
    super.key,
    required this.text,
    this.icon,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : (icon != null ? Icon(icon) : const SizedBox(width: 24)),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppConstants.primaryColor,
          foregroundColor: textColor ?? Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
            vertical: AppConstants.defaultPadding,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          disabledBackgroundColor: AppConstants.primaryColor.withOpacity(0.5),
        ),
      ),
    );
  }
}