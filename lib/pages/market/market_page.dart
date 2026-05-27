import 'package:flutter/material.dart';
import 'store_content.dart';
import 'services_content.dart';

class MarketPage extends StatefulWidget {
  const MarketPage({super.key});

  @override
  State<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage> {
  int _subPageIndex = 0; // 0 for Store, 1 for Services

  @override
  Widget build(BuildContext context) {
    // Extracted the exact header purple color for consistency
    final Color headerPurple = Colors.deepPurple[400]!;
    final Color accentColor = Colors.deepPurple[200]!;

    return Column(
      children: [
        const SizedBox(height: 20),

        // Responsive full-width segmented outline container
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Caps width on desktop but adapts to full width on mobile screens
              double optimizedWidth = constraints.maxWidth > 600 ? 500 : constraints.maxWidth;

              return Center(
                child: Container(
                  width: optimizedWidth,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    // Changed border color to match the header purple
                    border: Border.all(color: headerPurple, width: 3.5),
                  ),
                  child: Row(
                    children: [
                      // First Half: Store Button
                      Expanded(
                        child: _buildOutlineButton(
                          label: "Store",
                          isActive: _subPageIndex == 0,
                          accentColor: accentColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(26),
                            bottomLeft: Radius.circular(26),
                          ),
                          onTap: () => setState(() => _subPageIndex = 0),
                        ),
                      ),

                      // Second Half: Services Button
                      Expanded(
                        child: _buildOutlineButton(
                          label: "Services",
                          isActive: _subPageIndex == 1,
                          accentColor: accentColor,
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(26),
                            bottomRight: Radius.circular(26),
                          ),
                          onTap: () => setState(() => _subPageIndex = 1),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 20),

        // Main Dynamic Page Body
        Expanded(
          child: _subPageIndex == 0
              ? const StoreContent()
              : const ServicesContent(),
        ),
      ],
    );
  }

  // Helper builder for individual zero-gap outlined choices
  Widget _buildOutlineButton({
    required String label,
    required bool isActive,
    required Color accentColor,
    required BorderRadius borderRadius,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          color: isActive ? accentColor : Colors.transparent,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey[700],
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}