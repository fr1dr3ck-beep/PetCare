import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trial_project/pet/pet_product_model.dart';
import 'package:trial_project/pet/pet_store_controller.dart';

class PetDetailPage extends StatefulWidget {
  final dynamic pet; // Accepts the selected pet item map/model dynamically

  const PetDetailPage({super.key, required this.pet});

  @override
  State<PetDetailPage> createState() => _PetDetailPageState();
}

class _PetDetailPageState extends State<PetDetailPage> {
  bool _isDescriptionExpanded = false;

  @override
  Widget build(BuildContext context) {
    const Color deepPurpleGlow = Colors.deepPurple;
    final Color solidPurpleCard = Colors.deepPurple[400]!;
    const Color tealIndicator = Color(0xFF4DB6AC);

    // Dynamic retrieval from mapping helper we set up earlier
    String getPetImage(String petName) {
      final name = petName.toLowerCase();
      if (name.contains("golden retriever")) return "assets/images/dogs/golden_retriever.jpg";
      if (name.contains("french bulldog")) return "assets/images/dogs/french_bulldog.jpg";
      if (name.contains("german shepherd")) return "assets/images/dogs/german_shepherd.jpg";
      if (name.contains("pomeranian husky")) return "assets/images/dogs/pomeranian_husky.jpg";
      if (name.contains("labrador")) return "assets/images/dogs/labrador.jpg";
      if (name.contains("maine coon")) return "assets/images/cats/maine_coon.jpg";
      if (name.contains("persian")) return "assets/images/cats/persian.jpg";
      if (name.contains("siamese")) return "assets/images/cats/siamese.jpg";
      if (name.contains("british shorthair")) return "assets/images/cats/british_shorthair.jpg";
      if (name.contains("ragdoll")) return "assets/images/cats/ragdoll.jpg";
      if (name.contains("cockatiel")) return "assets/images/birds/cockatiel.jpg";
      if (name.contains("conure")) return "assets/images/birds/green_cheeked_conure.jpg";
      if (name.contains("zebra finch")) return "assets/images/birds/zebra_finch.jpg";
      if (name.contains("african grey")) return "assets/images/birds/african_grey.jpg";
      if (name.contains("budgerigar")) return "assets/images/birds/budgerigar.jpg";
      return "";
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<PetStoreController>(
        builder: (context, storeState, child) {
          int currentSelection = storeState.getSelectionQty(widget.pet.id);
          // 🚀 LOOKS UP THE LIVE WAREHOUSE STOCK COUNTER PARAMETER VALUE FROM THE PROVIDER
          int stockCount = storeState.getStockLevel(widget.pet.id);

          return Stack(
            children: [
              // 📸 1. BACKGROUND PRODUCT HEADER IMAGE BLOCK
              Positioned(
                left: 0, right: 0, top: 0,
                child: Container(
                  width: double.infinity,
                  height: 350, // Matches standard premium sliver banner height guidelines
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(getPetImage(widget.pet.name)),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              // 🎛️ 2. FLOATING NAVIGATION TOP BAR OVERLAY CONTROL
              Positioned(
                top: 45, left: 20, right: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.8), shape: BoxShape.circle),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.black87),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.8), shape: BoxShape.circle),
                      child: const Icon(Icons.shopping_cart_outlined, size: 18, color: Colors.black87),
                    ),
                  ],
                ),
              ),

              // 📄 3. BOTTOM OVERLAPPING WHITE CURVED SHEET CONTENT CONTAINER
              Positioned(
                left: 0, right: 0, bottom: 0, top: 320, // Negative overlap offsets header image cleanly
                child: Container(
                  padding: const EdgeInsets.only(top: 30, left: 20, right: 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title Breed Text Line
                        Text(
                          widget.pet.name,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        const SizedBox(height: 12),

                        // Ratings & Feedback Row Matrix
                        GestureDetector(
                          onTap: () => _showPetRatingDialog(context, storeState),
                          child: Row(
                            children: [
                              Wrap(
                                children: List.generate(5, (index) {
                                  return Icon(
                                    index < widget.pet.averageRating.floor() ? Icons.star_rounded : Icons.star_outline_rounded,
                                    color: Colors.amber,
                                    size: 18,
                                  );
                                }),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                widget.pet.averageRating.toString(),
                                style: const TextStyle(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 15),
                              Text(
                                "${widget.pet.ratingCount} reviews",
                                style: const TextStyle(fontSize: 13, color: Colors.black38),
                              ),
                              const SizedBox(width: 10),
                              const Icon(Icons.edit_note_rounded, size: 16, color: Colors.deepPurple),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // =========================================================================
                        // 🚀 FIXED CHARACTERISTICS MATRIX (Original Layout Structure Restored)
                        // =========================================================================
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // 🐾 1. Dynamic category string replaces static text (e.g., "Dogs")
                            _buildInfoBadge(Icons.pets_rounded, Colors.amber[300]!, widget.pet.category),

                            // 📦 2. Dynamic live warehouse database stock metrics counter (e.g., "25 available")
                            _buildInfoBadge(Icons.inventory_2_rounded, tealIndicator, "$stockCount available"),

                            //  3. Clock icon changed to check circle badge
                            _buildInfoBadge(Icons.check_circle_rounded, Colors.redAccent, "Verified Line"),
                          ],
                        ),
                        const SizedBox(height: 28),

                        // Introduction Header Text Segment Block
                        const Text(
                          "Introduce",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        const SizedBox(height: 12),

                        // Expandable Description Copy Text Container Wrap
                        Text(
                          widget.pet.description,
                          maxLines: _isDescriptionExpanded ? 100 : 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14, color: Colors.black45, height: 1.5),
                        ),

                        // Show More Dropdown Arrow Toggle Strip Link Button
                        GestureDetector(
                          onTap: () => setState(() => _isDescriptionExpanded = !_isDescriptionExpanded),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              children: [
                                Text(_isDescriptionExpanded ? "Show less" : "Show more", style: TextStyle(color: solidPurpleCard, fontWeight: FontWeight.bold)),
                                Icon(_isDescriptionExpanded ? Icons.arrow_drop_up_rounded : Icons.arrow_drop_down_rounded, color: solidPurpleCard),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 100), // Safety spacing cushion clearance layout padding block
                      ],
                    ),
                  ),
                ),
              ),

              // 🛒 4. PERSISTENT INTERACTIVE QUANTITY / ADD TO CART NAVIGATION BOTTOM BAR
              Positioned(
                left: 0, right: 0, bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Counter Container Block Element Module
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => storeState.updateCartQty(widget.pet.id, false),
                              child: const Icon(Icons.remove, size: 16, color: Colors.black54),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text("$currentSelection", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                            GestureDetector(
                              onTap: () => storeState.updateCartQty(widget.pet.id, true),
                              child: const Icon(Icons.add, size: 16, color: Colors.black54),
                            ),
                          ],
                        ),
                      ),

                      // Add to Cart action strip button control module overlay interface
                      GestureDetector(
                        onTap: () {
                          if (currentSelection > 0) {
                            storeState.confirmToCart(widget.pet.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Added ${widget.pet.name} to Cart!"), backgroundColor: tealIndicator, duration: const Duration(seconds: 1)),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          decoration: BoxDecoration(
                            color: currentSelection > 0 ? tealIndicator : Colors.grey[300],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "₱${widget.pet.price}  |  Add to Cart",
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Reusable characteristic metric pill badge view factories
  Widget _buildInfoBadge(IconData icon, Color iconColor, String text) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 14),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w600)),
      ],
    );
  }

  void _showPetRatingDialog(BuildContext context, PetStoreController storeState) {
    int selectedRating = 5;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Rate this Pet", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("How would you rate your experience or interest in this breed?", textAlign: TextAlign.center),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < selectedRating ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: Colors.amber,
                      size: 32,
                    ),
                    onPressed: () => setDialogState(() => selectedRating = index + 1),
                  );
                }),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: () {
                storeState.submitPetRating(widget.pet.id, selectedRating);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Thank you for your rating!")));
              },
              child: const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}