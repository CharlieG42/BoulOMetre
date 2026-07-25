import 'package:flutter/material.dart';
import 'package:boul_o_metre/utils/constants.dart';

class ActionButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isLoading;

  const ActionButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
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
            : Icon(icon ?? Icons.check, color: textColor ?? Colors.white),
        label: isLoading
            ? const Text('Chargement...')
            : Text(
                text,
                style: TextStyle(
                  color: textColor ?? Colors.white,
                  fontSize: 16,
                ),
              ),
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
          disabledBackgroundColor: AppConstants.primaryColor.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
