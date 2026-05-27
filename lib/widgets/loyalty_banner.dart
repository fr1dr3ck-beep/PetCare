import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trial_project/pet/pet_store_controller.dart';

class LoyaltyBanner extends StatelessWidget {
  const LoyaltyBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final Color headerPurple = Colors.deepPurple[700]!;
    final Color lightPurple = Colors.deepPurple[400]!;

    // Stream points counter reactively from the state provider context
    final storeState = Provider.of<PetStoreController>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: InkWell(
        onTap: () {
          // ℹ️ Open informational notification card details window on tap
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: const Row(
                children: [
                  Icon(Icons.star_rounded, color: Colors.amber, size: 28),
                  SizedBox(width: 10),
                  Text("Loyalty Treats Rules", style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              content: const Text(
                "When you buy a pet increases your points by 2, And each service with 5, Thus with higher points the greater the customer service.",
                style: TextStyle(fontSize: 14, height: 1.5, color: Colors.black87),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Got it!", style: TextStyle(color: lightPurple, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
        },
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [headerPurple, lightPurple],
            ),
            boxShadow: [
              BoxShadow(
                color: headerPurple.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Loyalty Treats Balance",
                    style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500, letterSpacing: 0.3),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "${storeState.loyaltyPoints} Points", // Automatically displays matching numerical tracking index state
                    style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.star_rounded, color: Colors.amber, size: 26),
              ),
            ],
          ),
        ),
      ),
    );
  }
}