import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trial_project/pet/pet_store_controller.dart';
import 'package:trial_project/pages/login_page.dart';
import 'package:trial_project/pages/pending_payments.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _handleLogoutSequence(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Colors.redAccent, size: 24),
            SizedBox(width: 10),
            Text("Sign Out", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text("Are you sure you want to log out of your PetCare account?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Logged out successfully. See you soon!"), backgroundColor: Colors.redAccent, duration: Duration(seconds: 2)),
              );
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
              );
            },
            child: const Text("Logout", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showProfileEditSheet(BuildContext context, PetStoreController storeState) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: storeState.userName);
    final phoneController = TextEditingController(text: storeState.userPhone);
    final addressController = TextEditingController(text: storeState.userAddress);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(top: 24, left: 24, right: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 45, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
                const SizedBox(height: 24),
                const Row(
                  children: [
                    Icon(Icons.edit_rounded, color: Colors.deepPurple, size: 26),
                    SizedBox(width: 10),
                    Text("Edit Profile Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                  ],
                ),
                const SizedBox(height: 20),
                const Text("Full Name", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black54)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: nameController,
                  validator: (v) => (v == null || v.trim().isEmpty) ? "Name cannot be left empty" : null,
                  decoration: _buildFormInputDecoration(Icons.person_outline_rounded),
                ),
                const SizedBox(height: 16),
                const Text("Contact Number", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black54)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  validator: (v) => (v == null || v.trim().isEmpty) ? "Phone number required" : null,
                  decoration: _buildFormInputDecoration(Icons.phone_android_outlined),
                ),
                const SizedBox(height: 16),
                const Text("Service & Delivery Address", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black54)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: addressController,
                  maxLines: 2,
                  validator: (v) => (v == null || v.trim().isEmpty) ? "Address required" : null,
                  decoration: _buildFormInputDecoration(Icons.location_on_outlined),
                ),
                const SizedBox(height: 28),
                GestureDetector(
                  onTap: () {
                    if (formKey.currentState!.validate()) {
                      storeState.updateUserProfile(
                        name: nameController.text.trim(),
                        phone: phoneController.text.trim(),
                        address: addressController.text.trim(),
                      );
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Profile changes saved successfully!"), backgroundColor: Color(0xFF4DB6AC)),
                      );
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(color: Colors.deepPurple, borderRadius: BorderRadius.circular(14)),
                    child: const Center(child: Text("SAVE CHANGES", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5))),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  InputDecoration _buildFormInputDecoration(IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, size: 18, color: Colors.grey[400]),
      filled: true,
      fillColor: const Color(0xFFF8F9FB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      errorStyle: const TextStyle(fontSize: 11, height: 0.8),
    );
  }

  void _showNotificationsWindowSheet(BuildContext context, PetStoreController storeState) {
    storeState.markAllNotificationsRead();
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFE5D1FA),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.80,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Center(child: Container(width: 45, height: 5, decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 30),
              const Text("NOTIFICATIONS", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.5)),
              const SizedBox(height: 20),
              Expanded(
                child: storeState.notifications.isEmpty
                    ? const Center(child: Text("No notifications at this time.", style: TextStyle(color: Colors.black38, fontSize: 13, fontWeight: FontWeight.w500)))
                    : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: storeState.notifications.length,
                  itemBuilder: (context, idx) {
                    final notif = storeState.notifications[idx];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const CircleAvatar(backgroundColor: Color(0xFFE5D1FA), child: Icon(Icons.notifications_active_rounded, color: Colors.deepPurple)),
                        title: Text(notif["title"], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(notif["message"], style: const TextStyle(fontSize: 12, color: Colors.black54, height: 1.3)),
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Map<String, dynamic> _determineTierSettings(int points) {
    if (points >= 200) {
      return {"text": "Ultimate Petcare Member", "bgColor": const Color(0xFFF3E5F5), "textColor": const Color(0xFF7B1FA2)};
    } else if (points >= 110) {
      return {"text": "Premium Petcare Member", "bgColor": const Color(0xFFE8EAF6), "textColor": const Color(0xFF1A237E)};
    } else if (points >= 50) {
      return {"text": "Loyal Petcare Member", "bgColor": const Color(0xFFFFF3E0), "textColor": const Color(0xFFE65100)};
    } else {
      return {"text": "Beginner Petcare Member", "bgColor": const Color(0xFFE0F2F1), "textColor": const Color(0xFF00796B)};
    }
  }

  // 🚀 NEW SYSTEM: Input form alert launcher allowing the admin to overwrite care statuses via text input fields
  void _showAdminStatusInputDialog(BuildContext context, PetStoreController storeState, BookedService petRecord) {
    final statusTextController = TextEditingController(text: petRecord.status);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(Icons.edit_note_rounded, color: Colors.deepPurple, size: 24),
            const SizedBox(width: 8),
            Text("Update Status: ${petRecord.petName}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: statusTextController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: "Input custom status message",
                hintText: "e.g., Grooming Finished / In Suite 4",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  statusTextController.text = "Ready for pickup";
                },
                icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                label: const Text("Set: Ready for pickup"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              storeState.updateRegisteredPetStatus(petRecord.id, statusTextController.text.trim());
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Pet clearance status updated successfully!"), backgroundColor: Color(0xFF4DB6AC)),
              );
            },
            child: const Text("Save", style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color deepPurpleGlow = Colors.deepPurple;
    final storeState = Provider.of<PetStoreController>(context);
    final petsList = storeState.confirmedRegisteredPets;
    final tierSettings = _determineTierSettings(storeState.loyaltyPoints);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => _showProfileEditSheet(context, storeState),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.deepPurple[300]!, width: 2)),
                      child: const Icon(Icons.person, size: 36, color: deepPurpleGlow),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(storeState.userName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: tierSettings["bgColor"], borderRadius: BorderRadius.circular(12)),
                            child: Text(tierSettings["text"], style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: tierSettings["textColor"])),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.location_on_rounded, size: 14, color: Colors.black38),
                              const SizedBox(width: 4),
                              Expanded(child: Text(storeState.userAddress, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Colors.black45))),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [Colors.deepPurple[300]!, Colors.deepPurple[600]!, const Color(0xFF311B92)],
                  stops: const [0.0, 0.5, 1.0],
                ),
                boxShadow: [BoxShadow(color: Colors.deepPurple.withOpacity(0.25), blurRadius: 12, offset: const Offset(0, 6))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Loyalty Treats Balance", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.85))),
                      const SizedBox(height: 6),
                      Text("${storeState.loyaltyPoints} Points", style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'sans-serif')),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                    child: const Icon(Icons.star_rounded, size: 24, color: Colors.amber),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text("My Registered Pets", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
            if (storeState.isAdmin)
              const Padding(
                padding: EdgeInsets.only(top: 4, bottom: 8),
                child: Text("Viewing all user records (Admin Mode)", style: TextStyle(fontSize: 10, color: Colors.deepPurple, fontWeight: FontWeight.bold)),
              ),
            const SizedBox(height: 12),

            petsList.isEmpty
                ? Container(
              width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), borderRadius: BorderRadius.circular(24)),
              child: const Center(child: Text("No registered pets found. Book a service to add one!", style: TextStyle(fontSize: 12, color: Colors.black38), textAlign: TextAlign.center)),
            )
                : SizedBox(
              height: 95,
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemCount: petsList.length,
                itemBuilder: (context, index) {
                  final petRecord = petsList[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      // 🚀 CONDITIONAL CLICK HOOK: Clicking pet item unlocks the custom update text panel exclusively for Admin sessions
                      onTap: storeState.isAdmin ? () => _showAdminStatusInputDialog(context, storeState, petRecord) : null,
                      child: Container(
                        width: 230,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2))],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(radius: 24, backgroundColor: Colors.deepPurple[50], child: const Icon(Icons.pets_rounded, color: Colors.deepPurple, size: 22)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(petRecord.petName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
                                  const SizedBox(height: 2),
                                  Text("${petRecord.petColor} ${petRecord.petType}", maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                                  const SizedBox(height: 3),

                                  // 🚀 FIXED: "Active:" text successfully modified to "Status:"
                                  Text(
                                    "Status: ${petRecord.status}",
                                    maxLines: 1, overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: petRecord.status == "Ready for pickup"
                                          ? Colors.green[700]
                                          : (storeState.isAdmin ? Colors.deepPurple[700] : Colors.deepPurple[400]),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            const Text("Account Options", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
              child: Column(
                children: [
                  _buildOptionTile(
                    icon: Icons.notifications_none_rounded,
                    iconColor: deepPurpleGlow,
                    title: "Notifications",
                    hasUnreadBadge: storeState.hasUnreadNotifications,
                    onTap: () => _showNotificationsWindowSheet(context, storeState),
                  ),
                  _buildDivider(),
                  _buildOptionTile(
                    icon: Icons.credit_card_rounded,
                    iconColor: deepPurpleGlow,
                    title: "Pending Payments",
                    hasUnreadBadge: false,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PendingPaymentsPage())),
                  ),
                  _buildDivider(),
                  _buildOptionTile(
                    icon: Icons.logout_rounded,
                    iconColor: Colors.redAccent,
                    title: "Logout",
                    hasUnreadBadge: false,
                    onTap: () => _handleLogoutSequence(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required bool hasUnreadBadge,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor, size: 22),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87)),
          if (hasUnreadBadge) ...[
            const SizedBox(width: 8),
            Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle)),
          ]
        ],
      ),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.black26),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, thickness: 0.5, indent: 56, endIndent: 20, color: Color(0xFFEEEEEE));
  }
}