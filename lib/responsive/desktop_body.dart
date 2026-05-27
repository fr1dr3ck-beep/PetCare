import 'package:flutter/material.dart';
import 'package:trial_project/widgets/header.dart';
import 'package:trial_project/widgets/drawer.dart';
import "package:trial_project/widgets/search_widget.dart";
import "package:trial_project/widgets/pet_slider.dart";
import "package:trial_project/widgets/resource_grid.dart";
import "package:trial_project/widgets/transaction_calendar.dart";
import "package:trial_project/widgets/info_list_item.dart";
import "package:trial_project/pages/profile_page.dart";
import "package:trial_project/pages/cart/cart_page.dart";
import "package:trial_project/pages/market/market_page.dart";
import 'package:provider/provider.dart';
import 'package:trial_project/pet/pet_store_controller.dart';
import 'package:trial_project/pages/pet_detail_page.dart';

class MyDesktopBody extends StatefulWidget {
  const MyDesktopBody({super.key});

  @override
  State<MyDesktopBody> createState() => _MyDesktopBodyState();
}

class _MyDesktopBodyState extends State<MyDesktopBody> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;
  bool _isOnboardingPromptActive = false;

  @override
  void initState() {
    super.initState();
    final storeState = Provider.of<PetStoreController>(context, listen: false);
    storeState.addListener(_verifyUserOnboardingStatus);
    WidgetsBinding.instance.addPostFrameCallback((_) => _verifyUserOnboardingStatus());
  }

  @override
  void dispose() {
    Provider.of<PetStoreController>(context, listen: false).removeListener(_verifyUserOnboardingStatus);
    super.dispose();
  }

  void _verifyUserOnboardingStatus() {
    if (!mounted) return;
    final state = Provider.of<PetStoreController>(context, listen: false);
    if (!state.isAdmin && !state.isProfileLoading && !state.hasCompletedOnboarding) {
      _showRequiredOnboardingForm(context, state);
    }
  }

  void _showRequiredOnboardingForm(BuildContext context, PetStoreController storeState) {
    if (_isOnboardingPromptActive) return;
    _isOnboardingPromptActive = true;

    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            title: const Row(
              children: [
                Icon(Icons.assignment_ind_rounded, color: Colors.deepPurple, size: 26),
                SizedBox(width: 10),
                Text("Account Setup Profile", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            content: SizedBox(
              width: 380,
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Welcome to PetCare! Please complete your profile records context coordinates to initialize dashboard coordinates seamlessly.",
                        style: TextStyle(fontSize: 12, color: Colors.black38, height: 1.3),
                      ),
                      const SizedBox(height: 20),
                      const Text("Full Name", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black54)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: nameController,
                        validator: (v) => (v == null || v.trim().isEmpty) ? "Full name entry cannot be empty" : null,
                        decoration: _buildFormInputStyleBox("Enter your name", Icons.person_outline_rounded),
                      ),
                      const SizedBox(height: 16),
                      const Text("Contact Number", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black54)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        validator: (v) => (v == null || v.trim().isEmpty) ? "Contact coordinates required" : null,
                        decoration: _buildFormInputStyleBox("+63 917 123 4567", Icons.phone_android_outlined),
                      ),
                      const SizedBox(height: 16),
                      const Text("Delivery & Care Address", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black54)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: addressController,
                        maxLines: 2,
                        validator: (v) => (v == null || v.trim().isEmpty) ? "Address coordination parameter required" : null,
                        decoration: _buildFormInputStyleBox("Street, City, Zip Code", Icons.location_on_outlined),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: GestureDetector(
                  onTap: () {
                    if (formKey.currentState!.validate()) {
                      storeState.updateUserProfile(
                        name: nameController.text.trim(),
                        phone: phoneController.text.trim(),
                        address: addressController.text.trim(),
                      );
                      _isOnboardingPromptActive = false;
                      Navigator.pop(dialogContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Onboarding metadata established! Welcome aboard."), backgroundColor: Color(0xFF4DB6AC)),
                      );
                    }
                  },
                  child: Container(
                    width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(color: Colors.deepPurple, borderRadius: BorderRadius.circular(14)),
                    child: const Center(
                      child: Text("INITIALIZE PLATFORM", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.5)),
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  InputDecoration _buildFormInputStyleBox(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint, hintStyle: const TextStyle(fontSize: 12, color: Colors.black26),
      prefixIcon: Icon(icon, size: 18, color: Colors.grey[400]),
      filled: true, fillColor: const Color(0xFFF8F9FB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      errorStyle: const TextStyle(fontSize: 11, height: 0.8),
    );
  }

  void _showExpandedCalendarDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.calendar_month_rounded, color: Colors.deepPurple, size: 26),
            SizedBox(width: 10),
            Text("Transaction History", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.deepPurple[50], borderRadius: BorderRadius.circular(20)),
                child: const Column(
                  children: [
                    Text("May 2026", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Text("Su"), Text("Mo"), Text("Tu"), Text("We"), Text("Th"), Text("Fr"), Text("Sa")],
                    ),
                    Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("17"), Text("18"), Text("19"), Text("20"), Text("21"),
                        Text("22", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
                        Text("23")
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Recent Verified Statements:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black54)),
              ),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(backgroundColor: Color(0xFFE0F2F1), child: Icon(Icons.check_circle, color: Color(0xFF00796B))),
                title: const Text("Premium Services Checkout", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                subtitle: const Text("Verified Successfully • +5 Treats Pts loaded", style: TextStyle(fontSize: 11)),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close", style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold))),
        ],
      ),
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
                  physics: const BouncingScrollPhysics(), itemCount: storeState.notifications.length,
                  itemBuilder: (context, idx) {
                    final notif = storeState.notifications[idx];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
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

  Widget _buildSidebarItem(IconData icon, String label, bool isActive, VoidCallback onTap) {
    return InkWell(
      onTap: onTap, borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(color: isActive ? Colors.white.withOpacity(0.15) : Colors.transparent, borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            Icon(icon, color: isActive ? const Color(0xFF4DB6AC) : Colors.white, size: 22),
            const SizedBox(width: 16),
            Text(label, style: TextStyle(color: isActive ? const Color(0xFF4DB6AC) : Colors.white, fontSize: 15)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final storeState = Provider.of<PetStoreController>(context);

    return Scaffold(
      key: _scaffoldKey, backgroundColor: const Color(0xFFE5D1FA),
      body: Row(
        children: [
          const SizedBox(width: 240, child: MyDrawer()),
          Expanded(
            flex: 3,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                toolbarHeight: 70, backgroundColor: Colors.deepPurple[400], elevation: 0, automaticallyImplyLeading: false,
                flexibleSpace: CustomHeader(scaffoldKey: _scaffoldKey, title: 'Petcare Dashboard', showMenu: false),
              ),
              body: _buildMainContent(),
            ),
          ),
          Container(
            width: 280, padding: const EdgeInsets.all(16), color: const Color(0xFFE5D1FA),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  decoration: BoxDecoration(color: Colors.deepPurple[400], borderRadius: BorderRadius.circular(32)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Center(child: Text("MENU", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.5))),
                      const SizedBox(height: 10),
                      const Divider(color: Colors.white54, thickness: 1, indent: 10, endIndent: 10),
                      const SizedBox(height: 10),
                      _buildSidebarItem(Icons.home_rounded, "Home", _currentIndex == 0, () => setState(() => _currentIndex = 0)),
                      const SizedBox(height: 5),
                      _buildSidebarItem(Icons.store_rounded, "Market", _currentIndex == 1, () => setState(() => _currentIndex = 1)),
                      const SizedBox(height: 5),
                      _buildSidebarItem(Icons.shopping_cart_rounded, "Cart", _currentIndex == 2, () => setState(() => _currentIndex = 2)),
                      const SizedBox(height: 5),
                      _buildSidebarItem(Icons.person_rounded, "Me", _currentIndex == 3, () => setState(() => _currentIndex = 3)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showNotificationsWindowSheet(context, storeState),
                    child: Container(
                      width: double.infinity, padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4))]),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("NOTIFICATIONS", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
                              if (storeState.hasUnreadNotifications) Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle)),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Expanded(
                            child: storeState.notifications.isEmpty
                                ? const Center(child: Text("No notifications yet", style: TextStyle(color: Colors.black38, fontSize: 12)))
                                : ListView.builder(
                              physics: const BouncingScrollPhysics(), itemCount: storeState.notifications.length,
                              itemBuilder: (context, idx) {
                                final notif = storeState.notifications[idx];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(color: notif["isRead"] ? Colors.grey[50] : const Color(0xFFF3E5F5), borderRadius: BorderRadius.circular(12)),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(notif["title"], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87)),
                                      const SizedBox(height: 2),
                                      Text(notif["message"], maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: Colors.black54)),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    switch (_currentIndex) {
      case 1: return const MarketPage();
      case 2: return const CartPage();
      case 3: return const ProfilePage();
      default:
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const MySearchBar(),
              const PetSlider(),
              GestureDetector(
                onTap: () => _showExpandedCalendarDialog(context),
                child: const TransactionCalendar(),
              ),
              const _Title(text: "Hot", color: Color(0xFFFF5252)),
              const DynamicRotatingHotList(),
              const _Title(text: "Promos", color: Color(0xFFFFA726)),
              const DynamicRotatingPromosList(),
              const SizedBox(height: 40),
              LayoutBuilder(
                builder: (context, constraints) {
                  double paddingFactor = constraints.maxWidth > 800 ? 0.25 : 0.1;
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: constraints.maxWidth * paddingFactor),
                    child: const ResourceGrid(crossAxisCount: 4, aspectRatio: 1.0, iconSize: 24),
                  );
                },
              ),
              const _Title(text: "Visit"),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: 4,
                  itemBuilder: (context, index) => InfoListItem(index: index),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        );
    }
  }
}

class DynamicRotatingHotList extends StatefulWidget {
  const DynamicRotatingHotList({super.key});
  @override
  State<DynamicRotatingHotList> createState() => _DynamicRotatingHotListState();
}

class _DynamicRotatingHotListState extends State<DynamicRotatingHotList> {
  late ScrollController _scrollController;
  int? _hoveredIndex;
  final int _uniqueItemCount = 7;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startScrolling());
  }

  void _startScrolling() {
    if (!_scrollController.hasClients) return;
    double maxScroll = _scrollController.position.maxScrollExtent;
    double currentScroll = _scrollController.offset;
    double duration = (maxScroll - currentScroll) / 35;
    if (duration <= 0) return;
    _scrollController.animateTo(maxScroll, duration: Duration(seconds: duration.toInt()), curve: Curves.linear).then((_) {
      if (_scrollController.hasClients) { _scrollController.jumpTo(0); _startScrolling(); }
    });
  }

  @override
  void dispose() { _scrollController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final storeState = Provider.of<PetStoreController>(context);
    final trendingPets = storeState.pets.take(_uniqueItemCount).toList();

    String getPetImage(String petName) {
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
      if (name.contains("budgerigar")) return "assets/images/birds/budgerigar.jpg";
      if (name.contains("cockatiel")) return "assets/images/birds/cockatiel.jpg";
      if (name.contains("african grey")) return "assets/images/birds/african_grey.jpg";
      if (name.contains("conure")) return "assets/images/birds/green_cheeked_conure.jpg";
      if (name.contains("zebra finch")) return "assets/images/birds/zebra_finch.jpg";
      return "assets/images/petslider/placeholder.jpg";
    }

    if (trendingPets.isEmpty) return const SizedBox(height: 160);

    return SizedBox(
      height: 190,
      child: ListView.builder(
        controller: _scrollController, scrollDirection: Axis.horizontal, itemCount: 1000, physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final petIndex = index % trendingPets.length;
          final pet = trendingPets[petIndex];
          bool isHovered = _hoveredIndex == index;

          return MouseRegion(
            onEnter: (_) => setState(() => _hoveredIndex = index),
            onExit: (_) => setState(() => _hoveredIndex = null),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200), curve: Curves.easeOut, margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10), width: isHovered ? 180 : 130,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: isHovered ? 12 : 6, offset: const Offset(0, 4))]),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PetDetailPage(pet: pet))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: Image.asset(getPetImage(pet.name), width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.deepPurple[50], child: const Icon(Icons.pets, color: Colors.deepPurple, size: 28)))),
                      Padding(padding: const EdgeInsets.all(8.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(pet.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)), const SizedBox(height: 2), Text("₱${pet.price}", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.deepPurple))])),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class DynamicRotatingPromosList extends StatefulWidget {
  const DynamicRotatingPromosList({super.key});
  @override
  State<DynamicRotatingPromosList> createState() => _DynamicRotatingPromosListState();
}

class _DynamicRotatingPromosListState extends State<DynamicRotatingPromosList> {
  late ScrollController _scrollController;
  int? _hoveredIndex;

  final List<Map<String, dynamic>> promoItems = [
    {"title": "20% OFF", "subtitle": "All Bird Supplies", "icon": Icons.flutter_dash_rounded, "gradient": [const Color(0xFFFF9100), const Color(0xFFFF3D00)]},
    {"title": "₱50 OFF", "subtitle": "Grooming Packages", "icon": Icons.content_cut_rounded, "gradient": [Color(0xFFB388FF), Color(0xFF6200EA)]},
    {"title": "FREE TOY", "subtitle": "Spend 100 Treats Pts", "icon": Icons.card_giftcard_rounded, "gradient": [const Color(0xFF26A69A), const Color(0xFF00695C)]},
    {"title": "BOGO DEAL", "subtitle": "Premium Cat Treats", "icon": Icons.pets_rounded, "gradient": [const Color(0xFFEC407A), const Color(0xFFB71C1C)]},
    {"title": "15% SAVINGS", "subtitle": "First Veterinary Check", "icon": Icons.medical_services_rounded, "gradient": [const Color(0xFF42A5F5), const Color(0xFF0D47A1)]},
    {"title": "₱10 GIFT", "subtitle": "Shampoo Products", "icon": Icons.bubble_chart_rounded, "gradient": [const Color(0xFF66BB6A), const Color(0xFF1B5E20)]},
    {"title": "3x REWARDS", "subtitle": "Spa Day Sessions", "icon": Icons.star_rounded, "gradient": [const Color(0xFFAB47BC), const Color(0xFF4A148C)]},
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startScrolling());
  }

  void _startScrolling() {
    if (!_scrollController.hasClients) return;
    double maxScroll = _scrollController.position.maxScrollExtent;
    double currentScroll = _scrollController.offset;
    double duration = (maxScroll - currentScroll) / 35;
    if (duration <= 0) return;
    _scrollController.animateTo(maxScroll, duration: Duration(seconds: duration.toInt()), curve: Curves.linear).then((_) {
      if (_scrollController.hasClients) { _scrollController.jumpTo(0); _startScrolling(); }
    });
  }

  @override
  void dispose() { _scrollController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: ListView.builder(
        controller: _scrollController, scrollDirection: Axis.horizontal, itemCount: 1000, physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final promoIndex = index % promoItems.length;
          final promo = promoItems[promoIndex];
          bool isHovered = _hoveredIndex == index;

          return MouseRegion(
            onEnter: (_) => setState(() => _hoveredIndex = index),
            onExit: (_) => setState(() => _hoveredIndex = null),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200), curve: Curves.easeOut, width: isHovered ? 230 : 190, margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10), padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: promo["gradient"]), boxShadow: [BoxShadow(color: (promo["gradient"][1] as Color).withOpacity(0.25), blurRadius: isHovered ? 12 : 6, offset: const Offset(0, 4))]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(promo["title"], style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)), Icon(promo["icon"] as IconData, color: Colors.white70, size: 20)]),
                  Text(promo["subtitle"], maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Title extends StatelessWidget {
  final String text; final Color? color;
  const _Title({required this.text, this.color});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(left: 20, top: 35, bottom: 10), child: Text(text, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: color)));
}
