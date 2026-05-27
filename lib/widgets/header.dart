import 'package:flutter/material.dart';

class CustomHeader extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final String title;
  final bool showMenu; // Parameter to control visibility

  const CustomHeader({
    super.key,
    required this.scaffoldKey,
    this.title = 'Petcare',
    this.showMenu = true, // Defaults to true so mobile works automatically
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.deepPurple[400],
      height: 70,
      child: SafeArea(
        child: Stack(
          children: [
            // 1. Centered Logo and Text
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 🌟 FIXED: Replaced the old static paw icon with your new mastermind logo asset
                  Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: Padding(
                        padding: const EdgeInsets.all(3.0), // Elegant inner padding so the logo content matches layout boundaries beautifully
                        child: Image.asset(
                          'assets/images/petslider/logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // 2. Menu Button pinned to the right
            // Only renders if showMenu is true
            if (showMenu)
              Positioned(
                right: 8,
                top: 0,
                bottom: 0,
                child: IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white, size: 30),
                  onPressed: () => scaffoldKey.currentState?.openDrawer(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}