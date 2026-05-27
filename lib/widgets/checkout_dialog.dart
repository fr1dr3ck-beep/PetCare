import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trial_project/pet/pet_store_controller.dart';

// 🚀 REFACTORED: INPUT FORM DIALOG TO COLLECT ACCOUNT DETAILS AS PROOF
void showUploadProofDialog(BuildContext parentContext, {required bool isStore, List<int>? selectedIds}) {
  final storeState = Provider.of<PetStoreController>(parentContext, listen: false);

  final formKey = GlobalKey<FormState>();
  final accountNameController = TextEditingController();
  final accountNumberController = TextEditingController();
  final referenceIdController = TextEditingController();

  showDialog(
    context: parentContext,
    barrierDismissible: false,
    builder: (dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        title: const Center(
          child: Text(
            "Payment Verification",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
          ),
        ),
        content: SizedBox(
          width: 340,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Please input your payment transfer account details below to verify your transaction parameters securely.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.black45, height: 1.4),
                  ),
                  const SizedBox(height: 20),

                  // 1. Account Name Input Field
                  _buildDialogField("Account Name", "e.g., John Doe", accountNameController, Icons.person_outline_rounded),
                  const SizedBox(height: 14),

                  // 2. Account Number Input Field
                  _buildDialogField("Account Number", "e.g., 09123456789", accountNumberController, Icons.phone_android_outlined, keyboardType: TextInputType.number),
                  const SizedBox(height: 14),

                  // 3. Reference ID / Payment ID Input Field
                  _buildDialogField("Reference ID / Payment ID", "e.g., REF123456789", referenceIdController, Icons.receipt_long_rounded),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext), // Safely closes the dialog view scope cleanly
            child: const Text("Cancel", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.pop(dialogContext); // Closes dialog view scope cleanly

                // Structures the distinct input text elements into a beautifully aligned single text string block
                String structuredProofText =
                    "Name: ${accountNameController.text.trim()} | "
                    "No: ${accountNumberController.text.trim()} | "
                    "Ref ID: ${referenceIdController.text.trim()}";

                // Commits the structured block directly into your Supabase transactions ledger
                if (selectedIds != null && selectedIds.isNotEmpty) {
                  if (isStore) {
                    await storeState.checkoutStoreCartSuccess(selectedIds, proofOfPayment: structuredProofText);
                  } else {
                    await storeState.checkoutServicesSuccess(selectedIds, proofOfPayment: structuredProofText);
                  }
                }

                if (parentContext.mounted) {
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    const SnackBar(
                      content: Text("Payment transaction information submitted successfully!"),
                      backgroundColor: Color(0xFF4DB6AC),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              elevation: 0,
            ),
            child: const Text("Confirm Submission", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      );
    },
  );
}

// 🚀 REUSABLE STYLED TEXTFIELD CONTAINER BUILDER FOR DIALOG FORM FORMS
Widget _buildDialogField(String label, String hint, TextEditingController controller, IconData icon, {TextInputType keyboardType = TextInputType.text}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black54)),
      const SizedBox(height: 6),
      TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: (v) => (v == null || v.trim().isEmpty) ? "$label is required" : null,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black26, fontSize: 13),
          prefixIcon: Icon(icon, size: 18, color: Colors.grey[400]),
          filled: true,
          fillColor: const Color(0xFFF5F5F7),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          errorStyle: const TextStyle(fontSize: 10, height: 0.8),
        ),
      ),
    ],
  );
}

// 🏪 CHANNELS PICKER ACTION OVERLAY POPUP
void showCheckoutMethodDialog(BuildContext parentContext, {required bool isStore, List<int>? selectedIds}) {
  final storeState = Provider.of<PetStoreController>(parentContext, listen: false);

  showDialog(
    context: parentContext,
    builder: (dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        title: const Center(
          child: Text(
            "Select Payment Method",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "How would you like to settle your checkout balance parameters safely?",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.black45, height: 1.4),
            ),
            const SizedBox(height: 24),

            // CHOICE A: Physical Counter Payment Flow
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.amber[50], shape: BoxShape.circle),
                child: const Icon(Icons.storefront_rounded, color: Colors.amber),
              ),
              title: const Text("Physical Payment", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: const Text("Pay at the store counter or upon delivery", style: TextStyle(fontSize: 11)),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
              onTap: () async {
                Navigator.pop(dialogContext); // Dismiss selection dialogue using explicit scope handle
                if (selectedIds != null && selectedIds.isNotEmpty) {
                  if (isStore) {
                    await storeState.checkoutStoreCartSuccess(selectedIds, proofOfPayment: "Counter COD");
                  } else {
                    await storeState.checkoutServicesSuccess(selectedIds, proofOfPayment: "Counter COD");
                  }
                }
                if (parentContext.mounted) {
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    const SnackBar(content: Text("Order processed successfully via Physical Payment!"), backgroundColor: Color(0xFF4DB6AC)),
                  );
                }
              },
            ),
            const Divider(height: 16, color: Color(0xFFEEEEEE)),

            // CHOICE B: Online PayMongo Checkout Gateway Session
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.deepPurple[50], shape: BoxShape.circle),
                child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.deepPurple),
              ),
              title: const Text("Online Payment", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: const Text("Pay securely via GCash, Maya, Cards, or QRPh", style: TextStyle(fontSize: 11)),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
              onTap: () async {
                Navigator.pop(dialogContext); // Safely close payment picker window

                // 1. Opens external web link portal layer using stable parent context
                await storeState.initiatePayMongoCheckout(parentContext, isStore: isStore, selectedIds: selectedIds);

                // 2. Instantly opens the verification input form sheet instead of the old file upload view
                if (parentContext.mounted) {
                  showUploadProofDialog(parentContext, isStore: isStore, selectedIds: selectedIds);
                }
              },
            ),
          ],
        ),
      );
    },
  );
}
