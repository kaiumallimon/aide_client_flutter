import 'package:flutter/material.dart';

class TopNavigationButton extends StatelessWidget {
  const TopNavigationButton({
    super.key,
    required this.onTap,
    required this.text,
    required this.icon,
    required this.active
  });

  final VoidCallback onTap;
  final String text;
  final IconData icon;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        color: active? Colors.deepOrange:Colors.transparent,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              text,
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
