import 'package:flutter/material.dart';

class MyNavPanel extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const MyNavPanel({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 16),
      child: Column(
        children: [
          // THE MENU BOX
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.deepPurple[400],
              borderRadius: BorderRadius.circular(25),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                const Text(
                  "MENU",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const Divider(color: Colors.white24, indent: 20, endIndent: 20),

                // Navigation Tiles with Active Indicators and Hover
                _NavTile(
                  icon: Icons.home,
                  label: "Home",
                  isActive: currentIndex == 0,
                  onTap: () => onTap(0),
                ),
                _NavTile(
                  icon: Icons.store,
                  label: "Market",
                  isActive: currentIndex == 1,
                  onTap: () => onTap(1),
                ),
                _NavTile(
                  icon: Icons.shopping_cart,
                  label: "Cart",
                  isActive: currentIndex == 2,
                  onTap: () => onTap(2),
                ),
                _NavTile(
                  icon: Icons.person,
                  label: "Me",
                  isActive: currentIndex == 3,
                  onTap: () => onTap(3),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // THE NOTIFICATIONS BOX
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    "NOTIFICATIONS",
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w500
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavTile({
    super.key,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_NavTile> createState() => _NavTileState();
}

class _NavTileState extends State<_NavTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    // Colors based on your mobile body screenshot (Teal indicator)
    final Color activeColor = const Color(0xFF4DB6AC);
    final Color contentColor = widget.isActive ? activeColor : Colors.white;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            // The "Encased" background effect
            color: _isHovered || widget.isActive
                ? Colors.white.withOpacity(0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                  widget.icon,
                  color: contentColor,
                  size: 22
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  widget.label,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    color: contentColor,
                    fontSize: 14,
                    fontWeight: widget.isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}