import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Logo extends StatelessWidget {
  const Logo({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Text.rich(
        TextSpan(
          text: 'UIU',
          style: GoogleFonts.montserrat(
            fontSize: 25,
            color: Colors.deepOrange,
            fontWeight: FontWeight.w500,
          ),
          children: [
            TextSpan(
              text: '-',
              style: GoogleFonts.montserrat(
                fontSize: 25,
                color: Colors.white,
              ),
            ),
            TextSpan(
              text: 'AIDE',
              style: GoogleFonts.montserrat(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.activeBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

