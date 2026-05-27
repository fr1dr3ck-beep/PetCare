import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobileBody;
  final Widget desktopBody;

  const ResponsiveLayout({
    super.key,
    required this.mobileBody,
    required this.desktopBody,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // If the screen is smaller than 900px, display the mobile body configuration
        if (constraints.maxWidth < 900) {
          return mobileBody;
        } else {
          return desktopBody;
        }
      },
    );
  }
}