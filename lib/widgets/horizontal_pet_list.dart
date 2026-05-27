import 'package:flutter/material.dart';

class HorizontalPetList extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final double height;

  const HorizontalPetList({
    super.key,
    required this.icon,
    required this.iconColor,
    this.height = 150,
  });

  @override
  State<HorizontalPetList> createState() => _HorizontalPetListState();
}

class _HorizontalPetListState extends State<HorizontalPetList> {
  late ScrollController _scrollController;
  final int _uniqueItemCount = 7;

  // Track which index is currently being hovered
  int? _hoveredIndex;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startScrolling());
  }

  void _startScrolling() {
    if (!_scrollController.hasClients) return;
    double maxScroll = _scrollController.position.maxScrollExtent;
    double currentScroll = _scrollController.offset;
    double pixelsPerSecond = 35;
    double duration = (maxScroll - currentScroll) / pixelsPerSecond;

    if (duration <= 0) return;

    _scrollController.animateTo(
      maxScroll,
      duration: Duration(seconds: duration.toInt()),
      curve: Curves.linear,
    ).then((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
        _startScrolling();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height + 40, // Extra height to allow room for enlargement
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: 1000,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          int displayIndex = (index % _uniqueItemCount) + 1;
          bool isHovered = _hoveredIndex == index;

          return MouseRegion(
            onEnter: (_) => setState(() => _hoveredIndex = index),
            onExit: (_) => setState(() => _hoveredIndex = null),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              // Enlarges by 0.5x (1.0 scale to 1.5 scale)
              width: isHovered ? 210 : 140,
              height: isHovered ? widget.height * 1.5 : widget.height,
              child: Material(
                color: Colors.white,
                elevation: isHovered ? 10 : 2,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    // Navigation logic: Go to a different page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailPage(index: displayIndex),
                      ),
                    );
                  },
                  splashColor: widget.iconColor.withOpacity(0.2),
                  child: Center(
                    child: Icon(
                      widget.icon,
                      color: widget.iconColor,
                      size: isHovered ? 60 : 40,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Placeholder for the "Different Page"
class DetailPage extends StatelessWidget {
  final int index;
  const DetailPage({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Location #$index Details")),
      body: Center(child: Text("Welcome to the page for Item #$index")),
    );
  }
}