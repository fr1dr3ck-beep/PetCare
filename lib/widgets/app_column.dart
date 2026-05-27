import 'package:flutter/material.dart';
import 'big_text.dart';
import 'package:provider/provider.dart';
import 'package:trial_project/pet/pet_store_controller.dart';

class AppColumn extends StatelessWidget {
  final String text;
  final String subCategory;

  const AppColumn({
    super.key, required this.text, required this.subCategory,
  });

  @override
  Widget build(BuildContext context) {
    const Color tealIndicator = Color(0xFF4DB6AC);
    final controller = Provider.of<PetStoreController>(context);

    final matchingPet = controller.pets.firstWhere(
          (p) => p.name == text, orElse: () => controller.pets.first,
    );
    int currentStock = controller.getStockLevel(matchingPet.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center,
      children: [
        BigText(text: text, size: 14),
        const SizedBox(height: 2),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.inventory_2_rounded, color: tealIndicator, size: 11),
            const SizedBox(width: 4),

            // 🚀 FLEXIBLE WRAPPER: Fixes horizontal layout overflow errors dynamically
            Flexible(
              child: Text(
                currentStock > 0 ? "$currentStock available" : "Sold Out",
                maxLines: 1, overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: currentStock > 0 ? Colors.black45 : Colors.red[400]),
              ),
            ),

            if (controller.isAdmin) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => controller.adjustStockLevel(matchingPet.id, false),
                child: const Icon(Icons.remove_circle_outline_rounded, size: 13, color: Colors.redAccent),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () => controller.adjustStockLevel(matchingPet.id, true),
                child: const Icon(Icons.add_circle_outline_rounded, size: 13, color: Colors.green),
              ),
            ]
          ],
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            const Icon(Icons.circle, color: Color(0xFFffd28d), size: 9),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                subCategory,
                maxLines: 1, overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[600], fontSize: 10, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ],
    );
  }
}