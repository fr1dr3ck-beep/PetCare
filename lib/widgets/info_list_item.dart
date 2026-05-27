import 'package:flutter/material.dart';

class InfoListItem extends StatelessWidget {
  final int index;
  const InfoListItem({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 75,
      width: 280, // Set a fixed width for the singular row look
      margin: const EdgeInsets.only(right: 15), // Gap between items
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: ListTile(
          leading: Icon(Icons.location_on, color: Colors.deepPurple[400]),
          title: Text(
            "Location ${index + 1}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          trailing: const Icon(Icons.chevron_right, size: 18),
          onTap: () => print("Tapped Location ${index + 1}"),
        ),
      ),
    );
  }
}