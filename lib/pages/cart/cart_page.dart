import 'package:flutter/material.dart';
import "package:trial_project/pet/pet_product_model.dart" as placeholder; // Protected fallback context import
import "package:trial_project/pet/pet_store_controller.dart";
import 'package:provider/provider.dart';
import "package:trial_project/widgets/small_text.dart";
import "package:trial_project/widgets/petstore_slider.dart";
import "package:trial_project/widgets/big_text.dart";
import 'package:flutter_slidable/flutter_slidable.dart';
import "package:trial_project/widgets/checkout_dialog.dart";

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final Map<int, bool> _checkedStoreItems = {};
  final Map<int, bool> _checkedServiceItems = {};

  // 🚀 ASSET IMAGE MAPPER: Maps product database names to asset folder paths
  String _getPetImage(String petName) {
    final name = petName.toLowerCase();

    // Dogs Category
    if (name.contains("golden retriever")) return "assets/images/dogs/golden_retriever.jpg";
    if (name.contains("french bulldog")) return "assets/images/dogs/french_bulldog.jpg";
    if (name.contains("german shepherd")) return "assets/images/dogs/german_shepherd.jpg";
    if (name.contains("pomeranian husky") || name.contains("pomsky")) return "assets/images/dogs/pomeranian_husky.jpg";
    if (name.contains("labrador")) return "assets/images/dogs/labrador.jpg";

    // Cats Category
    if (name.contains("maine coon")) return "assets/images/cats/maine_coon.jpg";
    if (name.contains("persian")) return "assets/images/cats/persian.jpg";
    if (name.contains("siamese")) return "assets/images/cats/siamese.jpg";
    if (name.contains("british shorthair")) return "assets/images/cats/british_shorthair.jpg";
    if (name.contains("ragdoll")) return "assets/images/cats/ragdoll.jpg";

    // Birds Category
    if (name.contains("cockatiel")) return "assets/images/birds/cockatiel.jpg";
    if (name.contains("conure")) return "assets/images/birds/green_cheeked_conure.jpg";
    if (name.contains("zebra finch")) return "assets/images/birds/zebra_finch.jpg";
    if (name.contains("african grey")) return "assets/images/birds/african_grey.jpg";
    if (name.contains("budgerigar")) return "assets/images/birds/budgerigar.jpg";

    return "";
  }

  // 🚀 SERVICE ICON MAPPER: Dynamically displays corresponding feature vectors
  IconData _getServiceIcon(String title) {
    final t = title.toLowerCase();
    if (t.contains("grooming")) return Icons.content_cut_rounded;
    if (t.contains("hotel")) return Icons.bed_rounded;
    if (t.contains("training")) return Icons.school_rounded;
    if (t.contains("telehealth")) return Icons.favorite_rounded;
    return Icons.room_service_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final Color headerPurple = Colors.deepPurple[400]!;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFE5D1FA),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            color: Colors.white.withOpacity(0.4),
            child: SafeArea(
              child: TabBar(
                labelColor: Colors.deepPurple[700], unselectedLabelColor: Colors.black54,
                indicatorColor: Colors.deepPurple[400], indicatorWeight: 3,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                tabs: const [
                  Tab(text: "Store", icon: Icon(Icons.shopping_bag_outlined, size: 18)),
                  Tab(text: "Services", icon: Icon(Icons.room_service_outlined, size: 18)),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _buildStoreCartSection(headerPurple),
            _buildServicesCartSection(headerPurple),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreCartSection(Color headerPurple) {
    return Consumer<PetStoreController>(
      builder: (context, storeState, child) {
        if (storeState.cartItems.isEmpty) return _buildEmptyStateBox("Your Store cart is empty!");

        for (var item in storeState.cartItems) {
          _checkedStoreItems.putIfAbsent(item.id, () => true);
        }

        double totalCartSum = 0.0;
        int checkedCount = 0;
        for (var item in storeState.cartItems) {
          if (_checkedStoreItems[item.id] == true) {
            double price = double.tryParse(item.price) ?? 0.0;
            totalCartSum += (price * item.quantity);
            checkedCount++;
          }
        }

        bool isAllSelected = checkedCount == storeState.cartItems.length;

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.white.withOpacity(0.2),
              child: Row(
                children: [
                  _buildCustomCheckbox(
                    isChecked: isAllSelected,
                    onTap: () {
                      setState(() {
                        for (var item in storeState.cartItems) {
                          _checkedStoreItems[item.id] = !isAllSelected;
                        }
                      });
                    },
                  ),
                  const SizedBox(width: 12),
                  const SmallText(text: "Select All Items", color: Colors.black87, size: 12),
                ],
              ),
            ),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: storeState.cartItems.length,
                itemBuilder: (context, index) {
                  final cartItem = storeState.cartItems[index];
                  double itemPrice = double.tryParse(cartItem.price) ?? 0.0;
                  double totalLineCost = itemPrice * cartItem.quantity;
                  bool isChecked = _checkedStoreItems[cartItem.id] ?? true;
                  String petImagePath = _getPetImage(cartItem.name);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        _buildCustomCheckbox(
                          isChecked: isChecked,
                          onTap: () {
                            setState(() {
                              _checkedStoreItems[cartItem.id] = !isChecked;
                            });
                          },
                        ),
                        const SizedBox(width: 10),

                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Slidable(
                              key: ValueKey("store_${cartItem.id}"),
                              endActionPane: ActionPane(
                                motion: const DrawerMotion(), extentRatio: 0.25,
                                children: [
                                  SlidableAction(
                                    onPressed: (context) {
                                      storeState.clearProductFromCart(cartItem.id);
                                      _checkedStoreItems.remove(cartItem.id);
                                    },
                                    backgroundColor: const Color(0xFFE57373), foregroundColor: Colors.white,
                                    icon: Icons.delete_outline_rounded, label: 'Delete',
                                  ),
                                ],
                              ),
                              child: Container(
                                color: Colors.white, padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  children: [
                                    // 🚀 FIXED: Renders the dynamic pet thumbnail picture inside the square box
                                    Container(
                                      width: 60, height: 60,
                                      decoration: BoxDecoration(color: Colors.deepPurple[50], borderRadius: BorderRadius.circular(15)),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
                                        child: Image.asset(
                                          petImagePath,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Icon(Icons.pets, color: headerPurple, size: 24),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          BigText(text: cartItem.name, size: 15),
                                          const SizedBox(height: 2),
                                          SmallText(text: "Category: ${cartItem.category}"),
                                          const SizedBox(height: 6),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(child: Text("Total: ₱${totalLineCost.toStringAsFixed(2)}", maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: headerPurple))),
                                              Container(
                                                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(20)),
                                                child: Row(
                                                  children: [
                                                    GestureDetector(onTap: () => storeState.modifyActualCartQty(cartItem.id, false), child: const Padding(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4), child: Icon(Icons.remove, size: 12))),
                                                    Text("${cartItem.quantity}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                                    GestureDetector(onTap: () => storeState.modifyActualCartQty(cartItem.id, true), child: const Padding(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4), child: Icon(Icons.add, size: 12))),
                                                  ],
                                                ),
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Cart Summary Total:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black54)),
                        Text("₱${totalCartSum.toStringAsFixed(2)}", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: headerPurple)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () {
                        if (checkedCount == 0) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select items to check out!"), backgroundColor: Colors.orange));
                          return;
                        }

                        List<int> selectedStoreIds = [];
                        _checkedStoreItems.forEach((id, isChecked) {
                          if (isChecked) selectedStoreIds.add(id);
                        });

                        showCheckoutMethodDialog(context, isStore: true, selectedIds: selectedStoreIds);
                      },
                      child: Container(
                        width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(color: checkedCount > 0 ? const Color(0xFF7CB342) : Colors.grey[300], borderRadius: BorderRadius.circular(14)),
                        child: const Center(child: Text("COMPLETE CHECKOUT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        );
      },
    );
  }

  Widget _buildServicesCartSection(Color headerPurple) {
    return Consumer<PetStoreController>(
      builder: (context, storeState, child) {
        if (storeState.bookedServices.isEmpty) return _buildEmptyStateBox("No active Service bookings recorded!");

        for (var booking in storeState.bookedServices) {
          _checkedServiceItems.putIfAbsent(booking.id, () => true);
        }

        double totalServicesSum = 0.0;
        int checkedCount = 0;
        for (var booking in storeState.bookedServices) {
          if (_checkedServiceItems[booking.id] == true) {
            totalServicesSum += booking.totalPrice;
            checkedCount++;
          }
        }

        bool isAllSelected = checkedCount == storeState.bookedServices.length;

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.white.withOpacity(0.2),
              child: Row(
                children: [
                  _buildCustomCheckbox(
                    isChecked: isAllSelected,
                    onTap: () {
                      setState(() {
                        for (var booking in storeState.bookedServices) {
                          _checkedServiceItems[booking.id] = !isAllSelected;
                        }
                      });
                    },
                  ),
                  const SizedBox(width: 12),
                  const SmallText(text: "Select All Services", color: Colors.black87, size: 12),
                ],
              ),
            ),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: storeState.bookedServices.length,
                itemBuilder: (context, index) {
                  final booking = storeState.bookedServices[index];
                  bool isChecked = _checkedServiceItems[booking.id] ?? true;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        _buildCustomCheckbox(
                          isChecked: isChecked,
                          onTap: () {
                            setState(() {
                              _checkedServiceItems[booking.id] = !isChecked;
                            });
                          },
                        ),
                        const SizedBox(width: 10),

                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Slidable(
                              key: ValueKey("service_${booking.id}"),
                              endActionPane: ActionPane(
                                motion: const DrawerMotion(), extentRatio: 0.25,
                                children: [
                                  SlidableAction(
                                    onPressed: (context) {
                                      storeState.clearServiceBooking(booking.id);
                                      _checkedServiceItems.remove(booking.id);
                                    },
                                    backgroundColor: const Color(0xFFE57373), foregroundColor: Colors.white,
                                    icon: Icons.delete_outline_rounded, label: 'Delete',
                                  ),
                                ],
                              ),
                              child: Container(
                                color: Colors.white, padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 🚀 FIXED: Renders the dynamic icon depending on chosen care packages
                                    Container(
                                      width: 60, height: 60,
                                      decoration: BoxDecoration(color: Colors.deepPurple[50], borderRadius: BorderRadius.circular(15)),
                                      child: Icon(
                                        _getServiceIcon(booking.serviceTitle),
                                        color: headerPurple,
                                        size: 26,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(booking.serviceTitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
                                          const SizedBox(height: 2),
                                          Text("Pet: ${booking.petName} (${booking.petType}) • Mode: ${booking.logisticsMode}", maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: Colors.black45, fontWeight: FontWeight.w500)),
                                          Text("Address: ${booking.ownerAddress}", maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, color: Colors.black38)),
                                          const SizedBox(height: 6),
                                          Text("Total Cost: ₱${booking.totalPrice.toStringAsFixed(2)}", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: headerPurple)),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Service Summary Total:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black54)),
                        Text("₱${totalServicesSum.toStringAsFixed(2)}", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: headerPurple)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () {
                        if (checkedCount == 0) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select appointments to check out!"), backgroundColor: Colors.orange));
                          return;
                        }

                        List<int> toCheckout = [];
                        _checkedServiceItems.forEach((id, isChecked) {
                          if (isChecked) toCheckout.add(id);
                        });

                        showCheckoutMethodDialog(context, isStore: false, selectedIds: toCheckout);
                      },
                      child: Container(
                        width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(color: checkedCount > 0 ? const Color(0xFF7CB342) : Colors.grey[300], borderRadius: BorderRadius.circular(14)),
                        child: const Center(child: Text("COMPLETE CHECKOUT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        );
      },
    );
  }

  Widget _buildCustomCheckbox({required bool isChecked, required VoidCallback onTap}) {
    const Color tealIndicator = Color(0xFF4DB6AC);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: isChecked ? tealIndicator : Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isChecked ? tealIndicator : Colors.black38,
            width: 1.5,
          ),
        ),
        child: isChecked ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
      ),
    );
  }

  Widget _buildEmptyStateBox(String lineText) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_cart_outlined, size: 60, color: Colors.black38),
          const SizedBox(height: 12),
          BigText(text: lineText, color: Colors.black45, size: 16),
        ],
      ),
    );
  }
}