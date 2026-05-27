import 'package:flutter/material.dart';
import "package:trial_project/pet/pet_store_controller.dart";
import 'package:provider/provider.dart';
import "package:trial_project/widgets/small_text.dart";
import "package:trial_project/widgets/big_text.dart";

class ServicesContent extends StatefulWidget {
  const ServicesContent({super.key});

  @override
  State<ServicesContent> createState() => _ServicesContentState();
}

class _ServicesContentState extends State<ServicesContent> {
  final Map<int, bool> _selectedServices = {1: false, 2: false, 3: false, 4: false};
  final Map<int, bool> _expandedInfo = {1: false, 2: false, 3: false, 4: false};
  String _selectedLogistics = "Drop-off";

  void _openServicePriceDialog(BuildContext context, PetStoreController state, ServiceDetail service) {
    final ctrl = TextEditingController(text: service.price.toStringAsFixed(2));
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Modify Price for ${service.title}"),
        content: TextField(controller: ctrl, keyboardType: TextInputType.number, decoration: const InputDecoration(prefixText: "₱")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(onPressed: () {
            double? parsedPrice = double.tryParse(ctrl.text);
            if (parsedPrice != null) {
              state.adminModifyServicePrice(service.id, parsedPrice);
            }
            Navigator.pop(context);
          }, child: const Text("Save")),
        ],
      ),
    );
  }

  void _openPetInfoFormDialog(BuildContext context, List<ServiceDetail> currentServices, double totalEstimate, Color headerPurple, Color tealIndicator) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final colorController = TextEditingController();
    final addressController = TextEditingController();
    final List<String> petTypes = ["Dog", "Cat", "Bird", "Snake"];
    String selectedPetType = "Dog";

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BigText(text: "Pet Registration", color: Colors.deepPurple[700]!, size: 20),
                  const SizedBox(height: 4),
                  const SmallText(text: "Please provide care details below:", color: Colors.black38),
                ],
              ),
              content: SizedBox(
                width: 320,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Pet Type", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black54)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedPetType,
                              isExpanded: true,
                              icon: Icon(Icons.keyboard_arrow_down_rounded, color: headerPurple),
                              items: petTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                              onChanged: (val) { if (val != null) setDialogState(() => selectedPetType = val); },
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _buildInputField("Pet Name", "e.g., Buddy", nameController, Icons.pets_rounded),
                        const SizedBox(height: 14),
                        _buildInputField("Pet Color", "e.g., Golden / White", colorController, Icons.palette_rounded),
                        const SizedBox(height: 14),
                        _buildInputField("Owner Address", "Street, City, Zip Code", addressController, Icons.home_rounded, maxLines: 2),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text("Cancel", style: TextStyle(color: Colors.black38, fontWeight: FontWeight.bold))),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      List<String> activeTitles = [];
                      for (var s in currentServices) {
                        if (_selectedServices[s.id] == true) activeTitles.add(s.title);
                      }

                      Provider.of<PetStoreController>(context, listen: false).addServiceBooking(
                        title: activeTitles.join(", "),
                        totalCost: totalEstimate,
                        logistics: _selectedLogistics,
                        type: selectedPetType,
                        name: nameController.text,
                        color: colorController.text,
                        address: addressController.text,
                      );

                      Navigator.pop(dialogContext);
                      setState(() { _selectedServices.updateAll((k, v) => false); });
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text("Care Service added to Cart under Services!"), backgroundColor: tealIndicator));
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: tealIndicator, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text("Confirm Booking", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildInputField(String label, String hint, TextEditingController controller, IconData icon, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black54)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller, maxLines: maxLines,
          validator: (v) => (v == null || v.trim().isEmpty) ? "$label is required" : null,
          decoration: InputDecoration(
            hintText: hint, hintStyle: const TextStyle(color: Colors.black26, fontSize: 13),
            prefixIcon: Icon(icon, size: 18, color: Colors.grey[400]), filled: true, fillColor: Colors.grey[100],
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            errorStyle: const TextStyle(fontSize: 10, height: 0.8),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final storeState = Provider.of<PetStoreController>(context);
    final List<ServiceDetail> currentServices = storeState.services;

    final Color headerPurple = Colors.deepPurple[400]!;
    final Color deepPurpleGlow = Colors.deepPurple[700]!;
    const Color tealIndicator = Color(0xFF4DB6AC);

    double totalEstimate = 0.0;
    for (var s in currentServices) {
      if (_selectedServices[s.id] == true) totalEstimate += s.price;
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(padding: EdgeInsets.only(left: 20, top: 16, bottom: 12), child: BigText(text: "Premium Care Services", size: 22)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(32),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    GridView.builder(
                      physics: const NeverScrollableScrollPhysics(), shrinkWrap: true,
                      itemCount: currentServices.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 2.5),
                      itemBuilder: (context, index) {
                        final s = currentServices[index];
                        bool isSelected = _selectedServices[s.id] ?? false;
                        bool isExpanded = _expandedInfo[s.id] ?? false;

                        return GestureDetector(
                          onTap: () => setState(() { _selectedServices[s.id] = !isSelected; }),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected ? deepPurpleGlow : Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: isSelected ? deepPurpleGlow : Colors.black87, width: 1.5),
                              boxShadow: isSelected ? [BoxShadow(color: deepPurpleGlow.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 2))] : [],
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              children: [
                                Icon(s.icon, size: 20, color: isSelected ? Colors.white : Colors.black87),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(s.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isSelected ? Colors.white : Colors.black87)),
                                      Text("₱${s.price.toStringAsFixed(2)}", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isSelected ? Colors.white70 : Colors.black45)),
                                    ],
                                  ),
                                ),

                                if (storeState.isAdmin) ...[
                                  GestureDetector(
                                    onTap: () => _openServicePriceDialog(context, storeState, s),
                                    child: Icon(Icons.edit_note_rounded, color: isSelected ? Colors.white : deepPurpleGlow, size: 22),
                                  ),
                                  const SizedBox(width: 4),
                                ],

                                GestureDetector(
                                  onTap: () => setState(() { _expandedInfo[s.id] = !isExpanded; }),
                                  child: Icon(isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: isSelected ? Colors.white : Colors.black54, size: 20),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    // 🚀 FIXED: Added <Widget> type parameter to .map() to resolve Object? getter error
                    ...currentServices.map<Widget>((s) {
                      if (!(_expandedInfo[s.id] ?? false)) return const SizedBox.shrink();
                      return Container(
                        margin: const EdgeInsets.only(top: 10), padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.deepPurple[50], borderRadius: BorderRadius.circular(16), border: Border.all(color: headerPurple.withOpacity(0.3))),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info_outline_rounded, color: headerPurple, size: 18),
                            const SizedBox(width: 8),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text("${s.title} (₱${s.price.toStringAsFixed(2)})", style: TextStyle(fontWeight: FontWeight.bold, color: deepPurpleGlow, fontSize: 13)),
                              const SizedBox(height: 2),
                              Text(s.description, style: const TextStyle(fontSize: 11, color: Colors.black54, height: 1.3)),
                            ])),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                    PopupMenuButton<String>(
                      onSelected: (val) => setState(() => _selectedLogistics = val),
                      itemBuilder: (context) => [const PopupMenuItem(value: "Drop-off", child: Text("Drop-off")), const PopupMenuItem(value: "Pick-up", child: Text("Pick-up"))],
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(color: const Color(0xFFF5F5F7), borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_selectedLogistics, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: headerPurple)),
                            Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: headerPurple),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Estimated Total:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black54)),
                        Text("₱${totalEstimate.toStringAsFixed(2)}", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: deepPurpleGlow)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () {
                        if (_selectedServices.values.where((v) => v == true).isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select at least one care service above!"), backgroundColor: Colors.orange));
                          return;
                        }
                        _openPetInfoFormDialog(context, currentServices, totalEstimate, headerPurple, tealIndicator);
                      },
                      child: Container(
                        width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(color: const Color(0xFF7CB342), borderRadius: BorderRadius.circular(12)),
                        child: const Center(child: Text("Book Services", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}