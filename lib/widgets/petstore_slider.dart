import 'package:flutter/material.dart';
import "package:trial_project/pet/pet_store_controller.dart";
import 'package:provider/provider.dart';
import '../pet/pet_product_model.dart';
import "package:trial_project/widgets/small_text.dart";
import "package:trial_project/widgets/big_text.dart";
import 'dart:async';

class PetStoreSlider extends StatefulWidget {
  const PetStoreSlider({super.key});

  @override
  State<PetStoreSlider> createState() => _PetStoreSliderState();
}

class _PetStoreSliderState extends State<PetStoreSlider> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  var _currPageValue = 0.0;
  final double _scaleFactor = 0.8;
  final double _height = 220;
  Timer? _timer;

  // 🛠️ ASSET MAPPER: Pairs inventory database names with clean asset folder paths
  String _getPetImage(String petName) {
    final name = petName.toLowerCase();

    // Dogs
    if (name.contains("golden retriever")) return "assets/images/dogs/golden_retriever.jpg";
    if (name.contains("french bulldog")) return "assets/images/dogs/french_bulldog.jpg";
    if (name.contains("german shepherd")) return "assets/images/dogs/german_shepherd.jpg";
    if (name.contains("pomeranian husky") || name.contains("pomsky")) return "assets/images/dogs/pomeranian_husky.jpg";
    if (name.contains("labrador")) return "assets/images/dogs/labrador.jpg";

    // Cats
    if (name.contains("maine coon")) return "assets/images/cats/maine_coon.jpg";
    if (name.contains("persian")) return "assets/images/cats/persian.jpg";
    if (name.contains("siamese")) return "assets/images/cats/siamese.jpg";
    if (name.contains("british shorthair")) return "assets/images/cats/british_shorthair.jpg";
    if (name.contains("ragdoll")) return "assets/images/cats/ragdoll.jpg";

    // Birds
    if (name.contains("cockatiel")) return "assets/images/birds/cockatiel.jpg";
    if (name.contains("conure")) return "assets/images/birds/green_cheeked_conure.jpg";
    if (name.contains("zebra finch")) return "assets/images/birds/zebra_finch.jpg";
    if (name.contains("african grey")) return "assets/images/birds/african_grey.jpg";
    if (name.contains("budgerigar")) return "assets/images/birds/budgerigar.jpg";

    return "";
  }

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() { _currPageValue = _pageController.page!; });
    });

    _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (_pageController.hasClients) {
        final storeState = Provider.of<PetStoreController>(context, listen: false);
        if (storeState.pets.isNotEmpty) {
          int nextPage = _pageController.page!.toInt() + 1;
          if (nextPage >= storeState.pets.length) nextPage = 0;
          _pageController.animateToPage(nextPage, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
        }
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color headerPurple = Colors.deepPurple[400]!;
    final Color tealIndicator = const Color(0xFF4DB6AC);

    return Consumer<PetStoreController>(
      builder: (context, storeState, child) {
        if (storeState.pets.isEmpty) {
          return const SizedBox(height: 280, child: Center(child: Text("No items available")));
        }

        return SizedBox(
          height: 280,
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: storeState.pets.length,
                itemBuilder: (context, position) {
                  final pet = storeState.pets[position];
                  return _buildPageItem(pet, position, headerPurple, tealIndicator, storeState);
                },
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () { if (_pageController.hasClients) _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn); },
                  child: Container(width: 50, color: Colors.transparent),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () { if (_pageController.hasClients) _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn); },
                  child: Container(width: 50, color: Colors.transparent),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPageItem(PetModel pet, int index, Color headerPurple, Color tealIndicator, PetStoreController storeState) {
    Matrix4 matrix = Matrix4.identity();
    if (index == _currPageValue.floor()) {
      var currScale = 1 - (_currPageValue - index) * (1 - _scaleFactor);
      var currTrans = _height * (1 - currScale) / 2;
      matrix = Matrix4.diagonal3Values(1, currScale, 1)..setTranslationRaw(0, currTrans, 0);
    } else if (index == _currPageValue.floor() + 1) {
      var currScale = _scaleFactor + (_currPageValue - index + 1) * (1 - _scaleFactor);
      var currTrans = _height * (1 - currScale) / 2;
      matrix = Matrix4.diagonal3Values(1, currScale, 1)..setTranslationRaw(0, currTrans, 0);
    } else if (index == _currPageValue.floor() - 1) {
      var currScale = 1 - (_currPageValue - index) * (1 - _scaleFactor);
      var currTrans = _height * (1 - currScale) / 2;
      matrix = Matrix4.diagonal3Values(1, currScale, 1)..setTranslationRaw(0, currTrans, 0);
    } else {
      var currScale = 0.8;
      matrix = Matrix4.diagonal3Values(1, currScale, 1)..setTranslationRaw(0, _height * (1 - _scaleFactor) / 2, 0);
    }

    int currentInventory = storeState.getStockLevel(pet.id);
    String imageAssetPath = _getPetImage(pet.name);

    return Transform(
      transform: matrix,
      child: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Viewing profile for ${pet.name}!"), backgroundColor: headerPurple, duration: const Duration(milliseconds: 700)));
        },
        child: Stack(
          children: [
            // 📸 RENDER DYNAMIC ASSET IMAGE INSTEAD OF FALLBACK ICON
            Container(
              height: 220, margin: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: pet.id.isEven ? const Color(0xFFE8E5FA) : const Color(0xFFFDF0ED),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image.asset(
                  imageAssetPath,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Center(
                    child: Icon(Icons.pets, size: 60, color: headerPurple.withOpacity(0.3)),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 110, margin: const EdgeInsets.only(left: 30, right: 30, bottom: 15),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.white, boxShadow: const [BoxShadow(color: Color(0xFFe8e8e8), blurRadius: 5.0, offset: Offset(0, 5))]),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      BigText(text: pet.name, size: 18),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.inventory_2_rounded, color: tealIndicator, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            currentInventory > 0 ? "In Stock: $currentInventory units" : "OUT OF STOCK",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: currentInventory > 0 ? Colors.black54 : Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildBadgeInfo(Icons.circle, pet.category, const Color(0xFFffd28d)),

                          // ⚙️ CHANGES HERE: Swapped Location to Heart, and Clock to Checkmark
                          _buildBadgeInfo(Icons.favorite_rounded, "Cute", const Color(0xFFFF5252)), // ❤️ Heart Icon
                          _buildBadgeInfo(Icons.check_circle_rounded, "Verified", tealIndicator),       //  Checkmark Icon
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgeInfo(IconData icon, String text, Color iconColor) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 12),
        const SizedBox(width: 4),
        SmallText(text: text, color: Colors.grey[600]!, size: 11),
      ],
    );
  }
}