import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trial_project/pet/pet_store_controller.dart';
import 'package:trial_project/pages/pet_detail_page.dart';

class MySearchBar extends StatefulWidget {
  const MySearchBar({super.key});

  @override
  State<MySearchBar> createState() => _MySearchBarState();
}

class _MySearchBarState extends State<MySearchBar> {
  final SearchController _searchController = SearchController();

  @override
  Widget build(BuildContext context) {
    final store = Provider.of<PetStoreController>(context); // Links into current controller context state

    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 12),
      child: SearchAnchor(
        searchController: _searchController,
        // Customizes the background canvas treatment of the full-screen modal view
        viewBackgroundColor: const Color(0xFFF8F6FC),
        viewElevation: 0,
        builder: (BuildContext context, SearchController controller) {
          return SearchBar(
            controller: controller,
            padding: const WidgetStatePropertyAll<EdgeInsets>(
              EdgeInsets.symmetric(horizontal: 18.0, vertical: 2.0),
            ),
            onTap: () => controller.openView(), // Instantly pops open suggestion drawer
            onChanged: (value) {
              store.updateSearchQuery(value); // Relays keyword inputs down to provider array sets
              controller.openView();
            },
            leading: const Icon(Icons.search_rounded, color: Color(0xFF673AB7), size: 22),
            hintText: "Search treats, breeds, or pets...",
            hintStyle: WidgetStateProperty.all(
              TextStyle(color: Colors.deepPurple[200], fontSize: 14, fontWeight: FontWeight.w500),
            ),
            textStyle: WidgetStateProperty.all(
              const TextStyle(color: Color(0xFF1A0533), fontSize: 14, fontWeight: FontWeight.w600),
            ),
            elevation: WidgetStateProperty.all(0),
            backgroundColor: WidgetStateProperty.all(Colors.white),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
            side: WidgetStateProperty.all(
              BorderSide(color: const Color(0xFF673AB7).withOpacity(0.08), width: 1.5),
            ),
            // Floating layered high-fidelity depth shadows
            shadowColor: WidgetStateProperty.all(const Color(0xFF1A0533).withOpacity(0.04)),
            trailing: [
              if (controller.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear_rounded, color: Colors.black38, size: 18),
                  onPressed: () {
                    controller.clear();
                    store.updateSearchQuery("");
                  },
                ),
            ],
          );
        },
        suggestionsBuilder: (BuildContext context, SearchController controller) {
          store.updateSearchQuery(controller.text); // Updates query filter targets live
          final results = store.filteredPets; // Grabs the reactive filtered data model collection

          // 🌟 PRESET MASTER VISUAL: Gorgeous custom empty status panel illustration
          if (results.isEmpty) {
            return [
              Padding(
                padding: const EdgeInsets.only(top: 80),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple[50],
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.find_in_page_outlined, size: 44, color: Color(0xFF673AB7)),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "No Furry Friends Found",
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF1A0533)),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Try looking up another species or keyword target parameter.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.deepPurple[300], fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              )
            ];
          }

          // 🐾 DYNAMIC CARDS: Modern product rows containing status pills and premium border curves
          return results.map((pet) {
            final String imagePath = store.getPetImage(pet); // Resolves relative disk asset references safely

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF1A0533).withOpacity(0.03), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1A0533).withOpacity(0.015),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  // 1. Left Graphic Section: Crisp clipped rounding borders
                  leading: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset(
                        imagePath, // Pulls the target model representation path
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.pets_rounded, size: 24, color: Colors.grey), // Safety fallback
                      ),
                    ),
                  ),
                  // 2. Middle Content Section: Informative data layout
                  title: Text(
                    pet.name, // Renders categorical name string
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF1A0533)),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      children: [
                        // Category Label Chip
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF673AB7).withOpacity(0.06),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            pet.category.toUpperCase(),
                            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF673AB7), letterSpacing: 0.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 3. Right Status Section: Cost metric markers
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2F1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "\$${pet.price}",
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF00796B)),
                    ),
                  ),
                  onTap: () {
                    _searchController.closeView(pet.name); // Dismisses suggestions engine view scope safely
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PetDetailPage(pet: pet), // Forwards control to product breakdown profile
                      ),
                    );
                  },
                ),
              ),
            );
          }).toList();
        },
      ),
    );
  }
}