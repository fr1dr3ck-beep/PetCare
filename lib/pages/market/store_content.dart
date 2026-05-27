import 'package:flutter/material.dart';
import "package:trial_project/pet/pet_product_model.dart";
import "package:trial_project/pet/pet_store_controller.dart";
import 'package:provider/provider.dart';
import "package:trial_project/widgets/small_text.dart";
import "package:trial_project/widgets/big_text.dart";
import "package:trial_project/widgets/petstore_slider.dart";
import "package:trial_project/widgets/app_column.dart";
import 'package:trial_project/pages/pet_detail_page.dart';

class StoreContent extends StatelessWidget {
  const StoreContent({super.key});

  String _getPetImage(String petName) {
    final name = petName.toLowerCase();
    if (name.contains("golden retriever")) return "assets/images/dogs/golden_retriever.jpg";
    if (name.contains("french bulldog")) return "assets/images/dogs/french_bulldog.jpg";
    if (name.contains("german shepherd")) return "assets/images/dogs/german_shepherd.jpg";
    if (name.contains("pomeranian husky") || name.contains("pomsky")) return "assets/images/dogs/pomeranian_husky.jpg";
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

  void _openPriceChangeDialog(BuildContext context, PetStoreController state, dynamic pet) {
    final ctrl = TextEditingController(text: pet.price);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Modify Price for ${pet.name}"),
        content: TextField(controller: ctrl, keyboardType: TextInputType.number, decoration: const InputDecoration(prefixText: "₱")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(onPressed: () { state.adminModifyProductPrice(pet.id, ctrl.text); Navigator.pop(context); }, child: const Text("Save")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color headerPurple = Colors.deepPurple[400]!;
    final tealIndicator = const Color(0xFF4DB6AC);

    return Consumer<PetStoreController>(
      builder: (context, storeState, child) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PetStoreSlider(),
              _buildCategoryHeader("Dogs"),
              _buildPetCategorizedList(storeState, "Dogs", headerPurple, tealIndicator),
              _buildCategoryHeader("Cats"),
              _buildPetCategorizedList(storeState, "Cats", headerPurple, tealIndicator),
              _buildCategoryHeader("Birds"),
              _buildPetCategorizedList(storeState, "Birds", headerPurple, tealIndicator),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryHeader(String title) {
    return Padding(padding: const EdgeInsets.only(left: 20, top: 16, bottom: 8), child: BigText(text: title, size: 22));
  }

  Widget _buildPetCategorizedList(PetStoreController storeState, String categoryFilter, Color headerPurple, Color tealIndicator) {
    final sectionPets = storeState.pets.where((pet) => pet.category == categoryFilter).toList();

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(), shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: sectionPets.length,
      itemBuilder: (context, index) {
        final pet = sectionPets[index];
        int currentSelection = storeState.getSelectionQty(pet.id);
        String imageAssetPath = _getPetImage(pet.name);

        return GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PetDetailPage(pet: pet))),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12), color: Colors.transparent,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 115, height: 115, decoration: BoxDecoration(color: Colors.deepPurple[50], borderRadius: BorderRadius.circular(20)),
                  child: ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.asset(imageAssetPath, fit: BoxFit.cover, errorBuilder: (context, _, __) => Center(child: Icon(categoryFilter == "Birds" ? Icons.flutter_dash : Icons.pets, size: 45, color: headerPurple)))),
                ),
                Expanded(
                  child: Container(
                    height: 100, decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20))),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          AppColumn(text: pet.name, subCategory: pet.category),

                          // 🚀 ROW BOX CONSTRAINTS: Keeps components tightly packaged together without separate lines
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Text("₱${pet.price}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: headerPurple)),

                                  if (storeState.isAdmin) ...[
                                    const SizedBox(width: 4),
                                    GestureDetector(
                                      onTap: () => _openPriceChangeDialog(context, storeState, pet),
                                      child: Container(
                                        constraints: const BoxConstraints(maxWidth: 50), // 🚀 ELLIPSIS BOUNDARY
                                        child: const Text(
                                          "Change",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(color: Colors.deepPurple, fontSize: 11, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),

                              // 🚀 SINGLE UNIFIED ROW GROUP: Locks step items right next to add trigger button
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(20)),
                                    child: Row(
                                      children: [
                                        GestureDetector(onTap: () => storeState.updateCartQty(pet.id, false), child: const Padding(padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4), child: Icon(Icons.remove, size: 12, color: Colors.black54))),
                                        Text("$currentSelection", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                        GestureDetector(onTap: () => storeState.updateCartQty(pet.id, true), child: const Padding(padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4), child: Icon(Icons.add, size: 12, color: Colors.black54))),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  GestureDetector(
                                    onTap: () {
                                      if (currentSelection > 0) {
                                        storeState.confirmToCart(pet.id);
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Added ${pet.name} to Cart!"), backgroundColor: tealIndicator, duration: const Duration(seconds: 1)));
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(color: currentSelection > 0 ? tealIndicator : Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                                      child: const Text("Add", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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
