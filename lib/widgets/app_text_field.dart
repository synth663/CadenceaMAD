import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_decorations.dart';
import '../theme/app_text_styles.dart';

/// Styled text input field with icon, focus ring, and error state.
/// Matches the input fields in SignUp.tsx and Login.tsx.
class AppTextField extends StatefulWidget {
  final String hintText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final bool obscureText;
  final TextEditingController? controller;
  final String? errorText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  const AppTextField({
    super.key,
    required this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.obscureText = false,
    this.controller,
    this.errorText,
    this.keyboardType,
    this.onChanged,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: AppDecorations.inputHeight,
          decoration: hasError
              ? AppDecorations.inputError
              : _isFocused
                  ? AppDecorations.inputFocused
                  : AppDecorations.inputDefault,
          child: Row(
            children: [
              if (widget.prefixIcon != null) ...[
                const SizedBox(width: 16.0),
                Icon(
                  widget.prefixIcon,
                  size: AppDecorations.iconSM,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 12.0),
              ] else
                const SizedBox(width: 16.0),
              Expanded(
                child: Focus(
                  onFocusChange: (focused) {
                    setState(() => _isFocused = focused);
                  },
                  child: TextField(
                    controller: widget.controller,
                    obscureText: widget.obscureText,
                    keyboardType: widget.keyboardType,
                    onChanged: widget.onChanged,
                    style: AppTextStyles.input,
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      hintStyle: AppTextStyles.inputPlaceholder,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                  ),
                ),
              ),
              if (widget.suffixIcon != null) ...[
                GestureDetector(
                  onTap: widget.onSuffixTap,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Icon(
                      widget.suffixIcon,
                      size: AppDecorations.iconSM,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ] else
                const SizedBox(width: 16.0),
            ],
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6.0),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text(
              widget.errorText!,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.destructive,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
