import 'package:flutter/material.dart';

class ResourceGrid extends StatelessWidget {
  final int crossAxisCount;
  final double aspectRatio;
  final double iconSize;

  const ResourceGrid({
    super.key,
    required this.crossAxisCount,
    required this.aspectRatio,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    // Mapping your filenames to friendly display labels
    final List<Map<String, String>> gridData = [
      {"image": "assets/images/petslider/squareone.jpg", "label": "Friends"},
      {"image": "assets/images/petslider/square2.jpg", "label": "Cuddle"},
      {"image": "assets/images/petslider/square3.jpg", "label": "Care"},
      {"image": "assets/images/petslider/square4.jpg", "label": "Newborn"},
      {"image": "assets/images/petslider/square5.jpg", "label": "Sunset"},
      {"image": "assets/images/petslider/square6.jpg", "label": "Nature"},
      {"image": "assets/images/petslider/square7.jpg", "label": "Pairs"},
      {"image": "assets/images/petslider/square8.jpg", "label": "Mini"},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: aspectRatio,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: gridData.length,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 3)),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  gridData[index]["image"]!,
                  fit: BoxFit.cover,
                ),
                // Optional: Semi-transparent overlay to make text readable
                Container(
                  color: Colors.black.withOpacity(0.2),
                  alignment: Alignment.bottomCenter,
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    gridData[index]["label"]!,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}