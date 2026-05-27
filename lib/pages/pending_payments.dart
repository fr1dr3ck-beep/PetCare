import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trial_project/pet/pet_store_controller.dart';
import 'package:trial_project/widgets/big_text.dart';

class PendingPaymentsPage extends StatelessWidget {
  const PendingPaymentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final storeState = Provider.of<PetStoreController>(context);
    final transactions = storeState.pendingTransactions;

    // Separate datasets
    final storeTransactions = transactions.where((txn) => txn.type == "Store").toList();
    final serviceTransactions = transactions.where((txn) => txn.type == "Services").toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF3EEFA), // Creamy soft lavender canvas
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: const BackButton(color: Color(0xFF4A148C)),
          title: const Text(
            "Clearance & Ledger Hub",
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 20,
              color: Color(0xFF1A0533),
              letterSpacing: -0.5,
            ),
          ),
          centerTitle: false,
          // FLOATING DOCK SEGMENTED PICKER: Custom modern capsule tab layout
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(64),
            child: Container(
              height: 48,
              margin: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFF1A0533).withOpacity(0.04),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TabBar(
                unselectedLabelColor: const Color(0xFF6A5380),
                labelColor: Colors.white,
                indicatorSize: TabBarIndicatorSize.tab,
                // Premium nested capsule animation look
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF673AB7), Color(0xFF4A148C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF673AB7).withOpacity(0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.2),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                tabs: [
                  Tab(text: "Market Orders (${storeTransactions.length})"),
                  Tab(text: "Care Bookings (${serviceTransactions.length})"),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          physics: const BouncingScrollPhysics(),
          children: [
            _buildTransactionView(storeTransactions, storeState, "No market logs queued.", Icons.shopping_bag_outlined),
            _buildTransactionView(serviceTransactions, storeState, "No medical/spa files logged.", Icons.room_service_outlined),
          ],
        ),
      ),
    );
  }

  // 🚀 NEW: DIALOG PANEL PROMPTING ADMIN FOR DECLINE REASONS WITH PRESET BUTTONS
  void _showDeclineReasonDialog(BuildContext context, PetStoreController storeState, String transactionId) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Row(
            children: [
              Icon(Icons.gpp_bad_rounded, color: Colors.redAccent, size: 24),
              SizedBox(width: 10),
              Text("Decline Order Request", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: reasonController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: "Type custom explanation alert text here...",
                  hintStyle: TextStyle(fontSize: 13),
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                ),
              ),
              const SizedBox(height: 14),
              const Text("QUICK PRESETS:", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 6),

              // Preset Button Options
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ActionChip(
                    label: const Text("Invalid Reference ID", style: TextStyle(fontSize: 11)),
                    onPressed: () => reasonController.text = "Invalid Reference ID", // 🌟 FIXED: Changed from onTap
                  ),
                  ActionChip(
                    label: const Text("Payment has been declined", style: TextStyle(fontSize: 11)),
                    onPressed: () => reasonController.text = "Payment has been declined", // 🌟 FIXED: Changed from onTap
                  ),
                ],
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: () {
                String closingReason = reasonController.text.trim();
                if (closingReason.isEmpty) closingReason = "Payment verification criteria unmet.";

                // Triggers the state mutation method
                storeState.adminDeclineTransaction(transactionId, closingReason);
                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Transaction declined. Notification alert dispatched."), backgroundColor: Colors.redAccent),
                );
              },
              child: const Text("Confirm Decline", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTransactionView(
      List<PendingTransaction> txns,
      PetStoreController storeState,
      String blankText,
      IconData emptyIcon,
      ) {
    if (txns.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20)
                ],
              ),
              child: Icon(emptyIcon, size: 40, color: const Color(0xFFB09FFF)),
            ),
            const SizedBox(height: 16),
            Text(
              blankText,
              style: const TextStyle(color: Color(0xFF7D6B91), fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.2),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: txns.length,
      itemBuilder: (context, index) {
        final txn = txns[index];
        bool isConfirmed = txn.status == "Confirmed";

        final Color accentThemeColor = txn.type == "Store" ? const Color(0xFF2196F3) : const Color(0xFF9C27B0);

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1A0533).withOpacity(0.03),
                blurRadius: 16,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Container(
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: accentThemeColor, width: 6)),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "STATEMENT REFERENCE",
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF1A0533).withOpacity(0.4), letterSpacing: 1.2),
                      ),
                      Text(
                        txn.id,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: accentThemeColor, fontFamily: 'monospace', letterSpacing: 0.5),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Text(
                    txn.description,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1A0533), height: 1.3, letterSpacing: -0.2),
                  ),

                  // ADMIN VIEW PROTECTED BLOCK LAYER
                  if (storeState.isAdmin) ...[
                    const SizedBox(height: 18),

                    // CUSTOMER DETAILS SECTION BLOCK CARD
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFECEFF1), width: 1),
                      ),
                      child: Column(
                        // 🚀 FIXED: Invalid text string layout artifact removed from here
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.badge_outlined, size: 16, color: accentThemeColor),
                              const SizedBox(width: 8),
                              const Text("ACCOUNT HOLDER COORDINATES", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFF546E7A), letterSpacing: 1.0)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildProfileMetaRow("Full Name", txn.userName),
                          _buildProfileMetaRow("Mobile Link", txn.userPhone),
                          _buildProfileMetaRow("Registered Loc", txn.userAddress),
                          const Divider(height: 20),
                          _buildProfileMetaRow(
                            "Payment Method",
                            txn.proofOfPayment.startsWith("assets/") ? "Online Gateway" : txn.proofOfPayment,
                          ),

                          // LIVE RECEIPT PREVIEW ATTACHMENT CARD FOR ADMIN SIGN-OFF
                          if (txn.proofOfPayment.startsWith("assets/")) ...[
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Icon(Icons.image_search_rounded, size: 14, color: Colors.grey[600]),
                                const SizedBox(width: 6),
                                const Text(
                                  "VISUAL RECEIPT VERIFICATION",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Color(0xFF546E7A), letterSpacing: 0.5),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: double.infinity,
                                height: 180,
                                color: Colors.grey[100],
                                child: Image.asset(
                                  txn.proofOfPayment,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, _, __) => const Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.broken_image_outlined, color: Colors.black26, size: 32),
                                        SizedBox(height: 4),
                                        Text("Failed to render attachment", style: TextStyle(fontSize: 11, color: Colors.black38)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // BOOKED PET DETAILS DETAILS SECTION CARD BLOCK
                    if (txn.type == "Services" && txn.serviceItemsSnapshot.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      ...txn.serviceItemsSnapshot.map((service) => Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDF7FF),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFF3E5F5), width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.pets_rounded, size: 14, color: Color(0xFFAB47BC)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    service.serviceTitle.toUpperCase(),
                                    maxLines: 1, overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFF7B1FA2), letterSpacing: 0.8),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildProfileMetaRow("Pet Taxonomy", service.petType),
                            _buildProfileMetaRow("Pet Alias", service.petName),
                            _buildProfileMetaRow("Coat Pattern", service.petColor),
                            _buildProfileMetaRow("Dispatch Dest", service.ownerAddress),
                          ],
                        ),
                      )).toList(),
                    ],
                  ],

                  const SizedBox(height: 16),
                  Container(height: 1, color: const Color(0xFFECEFF1)),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "TOTAL AMOUNT",
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: const Color(0xFF1A0533).withOpacity(0.4), letterSpacing: 1.0),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "₱${txn.totalPrice.toStringAsFixed(2)}",
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF1A0533), letterSpacing: -0.5),
                          ),
                        ],
                      ),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (!storeState.isAdmin && txn.proofOfPayment != "N/A" && txn.proofOfPayment != "Counter COD")
                            const Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(
                                "Proof Attachment Attached ✓",
                                style: TextStyle(fontSize: 10, color: Color(0xFF00796B), fontWeight: FontWeight.bold),
                              ),
                            ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isConfirmed ? const Color(0xFFE8F5E9) : const Color(0xFFFFF8E1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6, height: 6,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isConfirmed ? const Color(0xFF2E7D32) : const Color(0xFFEF6C00),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  txn.status.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    color: isConfirmed ? const Color(0xFF2E7D32) : const Color(0xFFEF6C00),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // GRADIENT ADMIN APPROVAL INTERACTION ACTION BUTTON
                  // GRADIENT ADMIN APPROVAL INTERACTION ACTION BUTTON
                  if (storeState.isAdmin && !isConfirmed) ...[
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        storeState.adminConfirmTransaction(txn.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                                const SizedBox(width: 10),
                                Text("Transaction ${txn.id} Authorized Successfully."),
                              ],
                            ),
                            backgroundColor: const Color(0xFF2E7D32),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2E7D32).withOpacity(0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            )
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.verified_user_rounded, color: Colors.white, size: 16),
                            SizedBox(width: 8),
                            Text(
                              "AUTHORIZE & SETTLE PAYMENT",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 0.8),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 🚀 PASTE THE NEW BUTTON PANEL HERE:
                    // 🚀 NEW: DECLINE ACTION INTERACTION BUTTON PANEL
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () => _showDeclineReasonDialog(context, storeState, txn.id),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.block_flipped, color: Colors.redAccent, size: 16),
                            SizedBox(width: 8),
                            Text("DECLINE REQUEST & SEND ALERT", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 0.8)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileMetaRow(String fieldLabel, String fieldValue) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              "$fieldLabel:",
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF90A4AE)),
            ),
          ),
          Expanded(
            child: Text(
              fieldValue,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF263238), height: 1.2),
            ),
          ),
        ],
      ),
    );
  }
}