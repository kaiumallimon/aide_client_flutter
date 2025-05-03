
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    this.width = 300,
    this.height = 50,
    required this.onPressed,
    required this.text,
    this.isLoading = false,
  });

  final double width;
  final double height;
  final VoidCallback onPressed;
  final String text;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepOrange,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
        ),
        child:
            isLoading
                ? Center(
                  child: CupertinoActivityIndicator(
                    radius: 12,
                    color: Colors.grey,
                  ),
                )
                : Text(text, style: TextStyle(fontSize: 16)),
      ),
    );
  }
}

