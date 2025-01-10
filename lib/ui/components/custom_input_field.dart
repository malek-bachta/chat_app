import 'package:flutter/material.dart';

class CustomInputField extends StatelessWidget {
  final TextEditingController controller;
  final String? label;
  final Icon? icon;
  final String? errorText;
  final bool obscureText;
  final Function? toggleVisibility;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? contentPadding;
  final Widget? suffixIcon; // Updated to accept any Widget
  final bool isParagraph;
  final bool isEmail;
  final String? prefixIcon;
  final ValueChanged<String>? onChanged;
  final double? fontSize;
  final FontWeight? fontWeight;
  final double? labelFontSize;
  final FontWeight? labelFontWeight;
  final Color? prefixIconColor;
  final Color? focusedBorderColor;
  final TextAlign? textAlign;
  final Color? backgroundColor;
  final bool? enableBorder;
  final FloatingLabelBehavior? floatingLabelBehavior;
  final FocusNode? focusNode;

  const CustomInputField({
    super.key,
    required this.controller,
    this.label,
    this.icon,
    this.errorText,
    this.obscureText = false,
    this.toggleVisibility,
    this.onTap,
    this.contentPadding,
    this.suffixIcon,
    this.isParagraph = false,
    this.isEmail = false,
    this.prefixIcon,
    this.onChanged,
    this.fontSize,
    this.fontWeight,
    this.labelFontSize,
    this.labelFontWeight,
    this.prefixIconColor,
    this.focusedBorderColor,
    this.textAlign,
    this.backgroundColor,
    this.enableBorder = true,
    this.floatingLabelBehavior,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: TextField(
        textAlign: textAlign ?? TextAlign.start,
        onChanged: onChanged,
        controller: controller,
        focusNode: focusNode,
        obscureText: obscureText,
        decoration: InputDecoration(
          contentPadding: contentPadding ??
              const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          focusedBorder: enableBorder == true
              ? OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(32)),
                  borderSide: BorderSide(
                    color: focusedBorderColor ?? Colors.grey,
                    width: 2.0,
                  ),
                )
              : const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(32)),
                  borderSide: BorderSide.none,
                ),
          enabledBorder: enableBorder == true
              ? const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(32)),
                  borderSide: BorderSide(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                )
              : const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(32)),
                  borderSide: BorderSide.none),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(32)),
          ),
          filled: true,
          fillColor: backgroundColor ?? Colors.transparent,
          labelText: label ?? '',
          labelStyle: const TextStyle(
            color: Colors.black26,
          ),
          floatingLabelBehavior:
              floatingLabelBehavior ?? FloatingLabelBehavior.auto,
          suffixIcon: suffixIcon, // Ensures the suffix icon is displayed
          errorText: errorText,
          errorStyle: TextStyle(
            color: Theme.of(context).colorScheme.error,
          ),
          prefixIcon: prefixIcon != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 12.0, left: 24.0),
                  child: Image.asset(
                    prefixIcon!,
                    height: 14,
                    width: 16,
                    color: prefixIconColor ?? Colors.black26,
                  ),
                )
              : null,
        ),
        keyboardType: isParagraph
            ? TextInputType.multiline
            : isEmail == true
                ? TextInputType.emailAddress
                : TextInputType.text,
        minLines: 1,
        maxLines: isParagraph ? 10 : 1,
        style: TextStyle(
          fontSize: fontSize ?? 16,
          fontWeight: fontWeight ?? FontWeight.normal,
        ),
        scrollPadding: const EdgeInsets.only(bottom: 100),
      ),
    );
  }
}
