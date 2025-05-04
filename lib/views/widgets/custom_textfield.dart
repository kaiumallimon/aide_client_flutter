import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomTextfield extends StatelessWidget {
  const CustomTextfield({
    super.key,
    required this.controller,
    required this.hintText,
    this.height = 50,
    this.width = 300,
    this.expandable = false,
    this.maxLine = 1,
    this.prefixIcon,
    this.readOnly = false,
    this.isPassword = false,
  });

  final TextEditingController controller;
  final String hintText;
  final double width;
  final double height;
  final bool expandable;
  final int maxLine;
  final IconData? prefixIcon;
  final bool readOnly;
  final bool isPassword;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: TextFormField(
        controller: controller,
        expands: expandable,
        obscureText: isPassword,
        textAlignVertical: TextAlignVertical.top,
        readOnly: readOnly,
        maxLines: expandable ? null : maxLine,
        minLines: expandable ? null : 1,
        style: const TextStyle(fontSize: 16, color: Colors.white),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
          filled: true,
          fillColor: Colors.grey.shade900,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(0),
            borderSide: BorderSide.none,
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(0),

            borderSide: BorderSide(color: Colors.deepOrange, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          prefixIcon:
              prefixIcon != null ? Icon(prefixIcon, color: Colors.grey) : null,
        ),
      ),
    );
  }
}
