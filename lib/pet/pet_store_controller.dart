import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trial_project/pet/pet_product_model.dart';
import 'package:trial_project/pages/cart/cart_model.dart';

// 🚀 NEW IMPORTS REQUIRED FOR PAYMONGO API INTERACTIONS
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class BookedService {
  final int id;
  final String serviceTitle;
  final double totalPrice;
  final String logisticsMode;
  final String petType;
  final String petName;
  final String petColor;
  final String ownerAddress;
  final String ownerId;
  String status;

  BookedService({
    required this.id,
    required this.serviceTitle,
    required this.totalPrice,
    required this.logisticsMode,
    required this.petType,
    required this.petName,
    required this.petColor,
    required this.ownerAddress,
    required this.ownerId,
    this.status = "Awaiting Action",
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'serviceTitle': serviceTitle,
    'totalPrice': totalPrice,
    'logisticsMode': logisticsMode,
    'petType': petType,
    'petName': petName,
    'petColor': petColor,
    'ownerAddress': ownerAddress,
    'ownerId': ownerId,
    'status': status,
  };

  factory BookedService.fromJson(Map<String, dynamic> json) => BookedService(
    id: json['id'],
    serviceTitle: json['serviceTitle'],
    totalPrice: (json['totalPrice'] as num).toDouble(),
    logisticsMode: json['logisticsMode'],
    petType: json['petType'],
    petName: json['petName'],
    petColor: json['petColor'],
    ownerAddress: json['ownerAddress'],
    ownerId: json['ownerId'] ?? "",
    status: json['status'] ?? "Awaiting Action",
  );
}

class ServiceDetail {
  final int id;
  final String title;
  final double price;
  final IconData icon;
  final String description;

  const ServiceDetail({
    required this.id,
    required this.title,
    required this.price,
    required this.icon,
    required this.description,
  });
}

class PendingTransaction {
  final String id;
  final String type;
  final String description;
  final double totalPrice;
  String status;
  final List<CartModel> storeItemsSnapshot;
  final List<BookedService> serviceItemsSnapshot;
  final String userName;
  final String userPhone;
  final String userAddress;
  final String txUserId;
  final String proofOfPayment;

  PendingTransaction({
    required this.id,
    required this.type,
    required this.description,
    required this.totalPrice,
    this.status = "Pending",
    required this.storeItemsSnapshot,
    required this.serviceItemsSnapshot,
    required this.userName,
    required this.userPhone,
    required this.userAddress,
    required this.txUserId,
    this.proofOfPayment = "N/A",
  });
}

class PetStoreController extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  final List<PetModel> _availablePets = [
    PetModel(id: 1, name: "Golden Retriever Puppy", price: "450.00", category: "Dogs", description: "Friendly and highly intelligent family companion."),
    PetModel(id: 2, name: "French Bulldog", price: "600.00", category: "Dogs", description: "Adaptable, quiet, and muscular compact house pet."),
    PetModel(id: 3, name: "German Shepherd", price: "500.00", category: "Dogs", description: "Confident, guardian, and highly capable working breed."),
    PetModel(id: 4, name: "Pomeranian Husky Mix", price: "550.00", category: "Dogs", description: "Energetic, fiercely loyal, and visually striking mini companion."),
    PetModel(id: 5, name: "Labrador Retriever", price: "400.00", category: "Dogs", description: "Active, outgoing, and gentle companion dog."),
    PetModel(id: 6, name: "Siamese Kitten", price: "300.00", category: "Cats", description: "Playful, vocal, and deeply devoted social house pet."),
    PetModel(id: 7, name: "Persian Cat", price: "350.00", category: "Cats", description: "Quiet, gentle, and majestic long-haired indoor feline."),
    PetModel(id: 8, name: "Maine Coon", price: "480.00", category: "Cats", description: "Massive, friendly, intelligent giant with a lush coat."),
    PetModel(id: 9, name: "Ragdoll Kitten", price: "420.00", category: "Cats", description: "Docile, affectionate, and famously relaxed lap-cat."),
    PetModel(id: 10, name: "British Shorthair", price: "380.00", category: "Cats", description: "Calm, easygoing, and recognizable chubby-cheeked feline."),
    PetModel(id: 11, name: "Budgerigar (Parakeet)", price: "45.00", category: "Birds", description: "Cheerful, compact, and easy-to-train vocal companion bird."),
    PetModel(id: 12, name: "Cockatiel Parrot", price: "120.00", category: "Birds", description: "Affectionate crest-waving whistler that loves human interaction."),
    PetModel(id: 13, name: "African Grey", price: "950.00", category: "Birds", description: "Unmatched speech mimicry intelligence and deep analytical mind."),
    PetModel(id: 14, name: "Green-Cheeked Conure", price: "250.00", category: "Birds", description: "Playful, curious, and compact trick-loving colorful parrot."),
    PetModel(id: 15, name: "Zebra Finch Trio", price: "60.00", category: "Birds", description: "Active, social, musical, and entertaining companion flock birds."),
  ];

  List<PetModel> get pets => _availablePets;

  final List<ServiceDetail> _services = [
    const ServiceDetail(id: 1, title: "Grooming and Spa", price: 45.00, icon: Icons.content_cut_rounded, description: "Includes a full premium bath, style haircut, nail trimming, and blow-dry treatment."),
    const ServiceDetail(id: 2, title: "Pet Hotel", price: 65.00, icon: Icons.bed_rounded, description: "Overnight luxury suite stay with climate control, premium meals, and live webcam access."),
    const ServiceDetail(id: 3, title: "Behavioral Training", price: 50.00, icon: Icons.school_rounded, description: "1-on-1 session covering obedience, leash socialization, and positive behavioral reinforcement."),
    const ServiceDetail(id: 4, title: "Veterinary Checkup", price: 35.00, icon: Icons.favorite_rounded, description: "Instant 30-minute high-definition video consultation with a verified, licensed veterinarian."),
  ];
  List<ServiceDetail> get services => _services;

  final Map<int, int> _selectedQuantities = {};
  final Map<int, CartModel> _globalCart = {};
  final Map<int, BookedService> _bookedServices = {};
  final Map<int, int> _petStockLevels = {};

  int _loyaltyPoints = 0;
  int get loyaltyPoints => _loyaltyPoints;

  final List<BookedService> _confirmedRegisteredPets = [];
  List<BookedService> get confirmedRegisteredPets => _confirmedRegisteredPets;

  final List<Map<String, dynamic>> _notifications = [];
  List<Map<String, dynamic>> get notifications => _notifications;
  bool get hasUnreadNotifications => _notifications.any((n) => n["isRead"] == false);

  final List<DateTime> _transactionDates = [];
  List<DateTime> get transactionDates => _transactionDates;

  bool _isAdmin = false;
  bool get isAdmin => _isAdmin;

  double _averageAppRating = 4.8;
  double get averageAppRating => _averageAppRating;
  int _ratingCount = 124;
  int get ratingCount => _ratingCount;

  Future<void> submitPlatformRating(int rating) async {
    try {
      await _supabase.from('app_ratings').insert({
        'user_id': _userId,
        'rating': rating,
      });
      await loadDataFromSupabase();
    } catch (e) {
      debugPrint("Error submitting rating: $e");
    }
  }

  Future<void> submitPetRating(int petId, int rating) async {
    try {
      await _supabase.from('pet_ratings').insert({
        'user_id': _userId,
        'pet_id': petId,
        'rating': rating,
      });
      await loadDataFromSupabase();
    } catch (e) {
      debugPrint("Error submitting pet rating: $e");
    }
  }

  int _hotLimitCount = 7;
  int get hotLimitCount => _hotLimitCount;

  final List<PendingTransaction> _pendingTransactions = [];
  List<PendingTransaction> get pendingTransactions => _pendingTransactions;

  String _userName = "";
  String _userPhone = "";
  String _userAddress = "";
  bool _hasCompletedOnboarding = false;

  bool _isProfileLoading = true;
  bool get isProfileLoading => _isProfileLoading;

  String get userName => _isAdmin ? "Administrator" : (_userName.isEmpty ? "New Member" : _userName);
  String get userPhone => _isAdmin ? "Anonymus" : (_userPhone.isEmpty ? "No Contact Configured" : _userPhone);
  String get userAddress => _isAdmin ? "Hidden Village" : (_userAddress.isEmpty ? "No Address Configured" : _userAddress);
  bool get hasCompletedOnboarding => _isAdmin ? true : _hasCompletedOnboarding;

  String get _userId => _supabase.auth.currentUser?.id ?? "test_user";

  final List<Map<String, dynamic>> _promoItems = [
    {"title": "20% OFF", "subtitle": "All Bird Supplies", "icon": Icons.flutter_dash_rounded, "gradient": [const Color(0xFFFF9100), const Color(0xFFFF3D00)]},
    {"title": "\$50 OFF", "subtitle": "Grooming Packages", "icon": Icons.content_cut_rounded, "gradient": [Color(0xFFB388FF), Color(0xFF6200EA)]},
    {"title": "FREE TOY", "subtitle": "Spend 100 Treats Pts", "icon": Icons.card_giftcard_rounded, "gradient": [const Color(0xFF26A69A), const Color(0xFF00695C)]},
    {"title": "BOGO DEAL", "subtitle": "Premium Cat Treats", "icon": Icons.pets_rounded, "gradient": [const Color(0xFFEC407A), const Color(0xFFB71C1C)]},
    {"title": "15% SAVINGS", "subtitle": "First Veterinary Check", "icon": Icons.medical_services_rounded, "gradient": [const Color(0xFF42A5F5), const Color(0xFF0D47A1)]},
    {"title": "\$10 GIFT", "subtitle": "Shampoo Products", "icon": Icons.bubble_chart_rounded, "gradient": [const Color(0xFF66BB6A), const Color(0xFF1B5E20)]},
    {"title": "3x REWARDS", "subtitle": "Spa Day Sessions", "icon": Icons.star_rounded, "gradient": [const Color(0xFFAB47BC), const Color(0xFF4A148C)]},
  ];
  List<Map<String, dynamic>> get promoItems => _promoItems;

  final List<Map<String, dynamic>> _resourceGridItems = [
    {"title": "Grooming", "icon": Icons.clean_hands},
    {"title": "Pet Hotel", "icon": Icons.hotel},
    {"title": "Training", "icon": Icons.psychology},
    {"title": "Telehealth", "icon": Icons.medical_services},
    {"title": "Diet Plan", "icon": Icons.restaurant},
    {"title": "Vaccine", "icon": Icons.vaccines},
    {"title": "Insurance", "icon": Icons.shield},
    {"title": "Adoption", "icon": Icons.volunteer_activism},
  ];
  List<Map<String, dynamic>> get resourceGridItems => _resourceGridItems;

  String _searchQuery = "";
  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<PetModel> get filteredPets {
    if (_searchQuery.isEmpty) return [];
    return _availablePets.where((pet) =>
      pet.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      pet.category.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  String getPetImage(PetModel pet) {
    String name = pet.name.toLowerCase();
    if (pet.category == "Dogs") {
      if (name.contains("golden")) return "assets/images/dogs/golden_retriever.jpg";
      if (name.contains("french")) return "assets/images/dogs/french_bulldog.jpg";
      if (name.contains("german")) return "assets/images/dogs/german_shepherd.jpg";
      if (name.contains("pomeranian")) return "assets/images/dogs/pomeranian_husky.jpg";
      if (name.contains("labrador")) return "assets/images/dogs/labrador.jpg";
    } else if (pet.category == "Cats") {
      if (name.contains("siamese")) return "assets/images/cats/siamese.jpg";
      if (name.contains("persian")) return "assets/images/cats/persian.jpg";
      if (name.contains("maine")) return "assets/images/cats/maine_coon.jpg";
      if (name.contains("ragdoll")) return "assets/images/cats/ragdoll.jpg";
      if (name.contains("british")) return "assets/images/cats/british_shorthair.jpg";
    } else if (pet.category == "Birds") {
      if (name.contains("budgerigar")) return "assets/images/birds/budgerigar.jpg";
      if (name.contains("cockatiel")) return "assets/images/birds/cockatiel.jpg";
      if (name.contains("african")) return "assets/images/birds/african_grey.jpg";
      if (name.contains("conure")) return "assets/images/birds/green_cheeked_conure.jpg";
      if (name.contains("zebra")) return "assets/images/birds/zebra_finch.jpg";
    }
    return "assets/images/petslider/placeholder.jpg"; // Fallback
  }

  PetStoreController() {
    for (var pet in _availablePets) {
      _petStockLevels[pet.id] = 25;
    }

    _supabase.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      if (event == AuthChangeEvent.signedIn || event == AuthChangeEvent.tokenRefreshed) {
        loadDataFromSupabase();
      } else if (event == AuthChangeEvent.signedOut) {
        clearUserData();
      }
    });

    loadDataFromSupabase();
  }

  void clearUserData() {
    _userName = "";
    _userPhone = "";
    _userAddress = "";
    _loyaltyPoints = 0;
    _hasCompletedOnboarding = false;
    _isProfileLoading = false;
    _globalCart.clear();
    _bookedServices.clear();
    _confirmedRegisteredPets.clear();
    _notifications.clear();
    _pendingTransactions.clear();
    _selectedQuantities.clear();
    notifyListeners();
  }

  Future<void> loadDataFromSupabase() async {
    try {
      _isProfileLoading = true;
      notifyListeners();
      final currentSessionId = _userId;

      try {
        final ratingsRes = await _supabase.from('app_ratings').select('rating');
        if (ratingsRes.isNotEmpty) {
          final ratings = ratingsRes as List;
          _ratingCount = ratings.length;
          double sum = 0;
          for (var r in ratings) {
            sum += (r['rating'] as num).toDouble();
          }
          _averageAppRating = double.parse((sum / _ratingCount).toStringAsFixed(1));
        }

        final petRatingsRes = await _supabase.from('pet_ratings').select('pet_id, rating');
        if (petRatingsRes.isNotEmpty) {
          Map<int, List<int>> ratingsMap = {};
          for (var row in petRatingsRes) {
            int pid = row['pet_id'];
            int r = row['rating'];
            ratingsMap.putIfAbsent(pid, () => []).add(r);
          }

          for (var pet in _availablePets) {
            if (ratingsMap.containsKey(pet.id)) {
              List<int> rList = ratingsMap[pet.id]!;
              pet.ratingCount = rList.length;
              double sum = rList.fold(0, (prev, element) => prev + element);
              pet.averageRating = double.parse((sum / pet.ratingCount).toStringAsFixed(1));
            } else {
              pet.averageRating = 0.0;
              pet.ratingCount = 0;
            }
          }
        }
      } catch (e) {
        debugPrint("Ratings sync failed: $e");
      }

      final profileRes = await _supabase.from('profiles').select().eq('id', currentSessionId).maybeSingle();
      if (profileRes != null) {
        _userName = profileRes['name'] ?? "";
        _userPhone = profileRes['phone'] ?? "";
        _userAddress = profileRes['address'] ?? "";
        _loyaltyPoints = profileRes['loyalty_points'] ?? 0;
        _hasCompletedOnboarding = profileRes['has_completed_onboarding'] ?? false;
      } else {
        _hasCompletedOnboarding = false;
      }

      final stockRes = await _supabase.from('pet_stocks').select();
      for (var row in stockRes) {
        _petStockLevels[row['pet_id']] = row['stock_level'];
      }

      var txnQuery = _supabase.from('pending_transactions').select();
      if (!_isAdmin) {
        txnQuery = txnQuery.eq('user_id', currentSessionId);
      }
      final txnRes = await txnQuery;
      final List<PendingTransaction> tempTxns = [];
      for (var row in txnRes) {
        final List<dynamic> storeList = row['store_items_json'] ?? [];
        final List<dynamic> serviceList = row['service_items_json'] ?? [];

        tempTxns.add(PendingTransaction(
          id: row['id'], type: row['type'], description: row['description'],
          totalPrice: (row['total_price'] as num).toDouble(), status: row['status'],
          userName: row['user_name'] ?? "", userPhone: row['user_phone'] ?? "", userAddress: row['user_address'] ?? "",
          txUserId: row['user_id'] ?? "test_user",
          proofOfPayment: row['proof_of_payment'] ?? "N/A",
          storeItemsSnapshot: storeList.map((x) => CartModel(id: x['id'], name: x['name'], price: x['price'], category: x['category'], quantity: x['quantity'])).toList(),
          serviceItemsSnapshot: serviceList.map((x) => BookedService.fromJson(x)).toList(),
        ));
      }

      var petsQuery = _supabase.from('registered_pets').select();
      if (!_isAdmin) {
        petsQuery = petsQuery.eq('user_id', currentSessionId);
      }
      final petsRes = await petsQuery;
      final List<BookedService> tempPets = [];
      for (var row in petsRes) {
        tempPets.add(BookedService(
          id: row['id'], serviceTitle: row['service_title'], totalPrice: (row['total_price'] as num).toDouble(),
          logisticsMode: row['logistics_mode'], petType: row['pet_type'], petName: row['pet_name'],
          petColor: row['pet_color'], ownerAddress: row['owner_address'], ownerId: row['user_id'] ?? "",
          status: row['status'],
        ));
      }

      final notifRes = await _supabase.from('user_notifications').select().eq('user_id', currentSessionId).order('created_at', ascending: false);
      final List<Map<String, dynamic>> tempNotifs = [];
      for (var row in notifRes) {
        tempNotifs.add({
          "id": row['id'], "title": row['title'], "message": row['message'], "isRead": row['is_read'], "time": "Past Alert"
        });
      }

      _pendingTransactions.clear();
      _pendingTransactions.addAll(tempTxns);
      _confirmedRegisteredPets.clear();
      _confirmedRegisteredPets.addAll(tempPets);
      _notifications.clear();
      _notifications.addAll(tempNotifs);

      notifyListeners();
    } catch (e) {
      debugPrint("Supabase Load Error: $e");
    } finally {
      _isProfileLoading = false;
      notifyListeners();
    }
  }

  Future<void> _createNewNotification(String title, String message, {String? targetUserId}) async {
    final uid = targetUserId ?? _userId;
    if (uid == _userId) {
      _notifications.insert(0, {"title": title, "message": message, "isRead": false, "time": "Just Now"});
      notifyListeners();
    }

    try {
      await _supabase.from('user_notifications').insert({
        'user_id': uid, 'title': title, 'message': message, 'is_read': false
      });
    } catch (e) {
      debugPrint("Notification cloud save error: $e");
    }
  }

  // =========================================================================
  // 🚀 LIVE INTEGRATION PIPELINE: PAYMONGO TEST ENVIRONMENT CONFIGURATION
  // =========================================================================
  Future<void> initiatePayMongoCheckout(BuildContext context, {required bool isStore, List<int>? selectedIds}) async {
    try {
      List<Map<String, dynamic>> lineItems = [];

      if (isStore) {
        if (selectedIds == null || selectedIds.isEmpty) return;
        for (var id in selectedIds) {
          final item = _globalCart[id];
          if (item != null) {
            double itemPrice = double.tryParse(item.price) ?? 0.0;
            int priceInCentavos = (itemPrice * 100).toInt();

            lineItems.add({
              'amount': priceInCentavos,
              'currency': 'PHP',
              'description': item.category,
              'name': item.name,
              'quantity': item.quantity,
            });
          }
        }
      } else {
        if (selectedIds == null || selectedIds.isEmpty) return;
        for (var id in selectedIds) {
          final service = _bookedServices[id];
          if (service != null) {
            int priceInCentavos = (service.totalPrice * 100).toInt();
            lineItems.add({
              'amount': priceInCentavos,
              'currency': 'PHP',
              'description': service.petType,
              'name': service.serviceTitle,
              'quantity': 1,
            });
          }
        }
      }

      if (lineItems.isEmpty) return;

      final Map<String, dynamic> checkoutPayload = {
        'data': {
          'attributes': {
            'cancel_url': 'https://petcare-gateway.vercel.app/cancel',
            'billing': {
              'address': {
                'line1': userAddress.isEmpty ? "N/A" : userAddress,
                'country': 'PH',
              },
              'name': userName.isEmpty ? "Customer" : userName,
              'phone': userPhone.isEmpty ? "09000000000" : userPhone,
            },
            'line_items': lineItems,
            'payment_method_types': ['gcash', 'paymaya', 'card', 'qrph'],
            'send_email_receipt': true,
            'show_description': true,
            'show_line_items': true,
            'success_url': 'https://petcare-gateway.vercel.app/success',
          }
        }
      };

      final response = await http.post(
        Uri.parse('https://api.paymongo.com/v1/checkout_sessions'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // 🔒 Basic Base64 token compilation utilizing your verified developers credential key
          'Authorization': 'Basic ${base64Encode(utf8.encode('sk_live_fYnu8cUKRzXrt3pDtUWtkaUe:'))}',
        },
        body: jsonEncode(checkoutPayload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        String checkoutUrl = jsonResponse['data']['attributes']['checkout_url'];

        final Uri url = Uri.parse(checkoutUrl);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
          // 🚀 REMOVED: Immediate success call removed. User must now upload proof first.
        } else {
          throw 'Could not launch payment gateway URL: $checkoutUrl';
        }
      } else {
        throw 'PayMongo Server Error: ${response.body}';
      }
    } catch (e) {
      debugPrint("PayMongo checkout process failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment Gateway Initiation Failed: $e"), backgroundColor: Colors.redAccent),
      );
    }
  }



  void setAdminMode(bool value) {
    _isAdmin = value;
    notifyListeners();
    loadDataFromSupabase();
  }

  Future<void> updateUserProfile({required String name, required String phone, required String address}) async {
    _userName = name; _userPhone = phone; _userAddress = address; _hasCompletedOnboarding = true;
    notifyListeners();

    await _supabase.from('profiles').upsert({
      'id': _userId, 'name': name, 'phone': phone, 'address': address,
      'loyalty_points': _loyaltyPoints, 'has_completed_onboarding': true
    });
  }

  Future<void> updateRegisteredPetStatus(int bookingId, String customStatus) async {
    int targetIndex = _confirmedRegisteredPets.indexWhere((pet) => pet.id == bookingId);
    if (targetIndex != -1) {
      final pet = _confirmedRegisteredPets[targetIndex];
      pet.status = customStatus;
      notifyListeners();

      await _supabase.from('registered_pets').update({'status': customStatus}).eq('id', bookingId);

      if (customStatus == "Ready for pickup") {
        await _createNewNotification(
          "Ready for Pickup! 🐾",
          "Your pet ${pet.petName} is done with the services. It is ready for pickup!",
          targetUserId: pet.ownerId,
        );
      }
    }
  }

  Future<void> adjustStockLevel(int productId, bool increase) async {
    int current = _petStockLevels[productId] ?? 25;
    if (increase) {
      _petStockLevels[productId] = current + 1;
    } else {
      if (current > 0) _petStockLevels[productId] = current - 1;
    }
    notifyListeners();

    await _supabase.from('pet_stocks').upsert({'pet_id': productId, 'stock_level': _petStockLevels[productId]});
  }

  int getStockLevel(int productId) => _petStockLevels[productId] ?? 0;
  int getSelectionQty(int productId) => _selectedQuantities[productId] ?? 0;
  List<CartModel> get cartItems => _globalCart.values.toList();
  List<BookedService> get bookedServices => _bookedServices.values.toList();

  void _logTransactionDate() {
    final now = DateTime.now();
    if (!_transactionDates.any((d) => d.year == now.year && d.month == now.month && d.day == now.day)) {
      _transactionDates.add(now);
    }
  }

  void updateCartQty(int productId, bool isIncrement) {
    modifySelection(productId, isIncrement);
  }

  void modifySelection(int productId, bool isIncrement) {
    int currentQty = getSelectionQty(productId);
    int currentStock = getStockLevel(productId);

    if (isIncrement) {
      if (currentQty >= currentStock) return;
      _selectedQuantities[productId] = currentQty + 1;
    } else {
      if (currentQty <= 0) return;
      _selectedQuantities[productId] = currentQty - 1;
    }
    notifyListeners();
  }

  void modifyActualCartQty(int productId, bool isIncrement) {
    if (!_globalCart.containsKey(productId)) return;

    final currentItem = _globalCart[productId]!;
    int currentStock = getStockLevel(productId);

    if (isIncrement) {
      if (currentItem.quantity >= currentStock) return;
      _globalCart[productId] = CartModel(
        id: currentItem.id, name: currentItem.name, price: currentItem.price,
        category: currentItem.category, quantity: currentItem.quantity + 1,
      );
    } else {
      if (currentItem.quantity <= 1) {
        _globalCart.remove(productId);
      } else {
        _globalCart[productId] = CartModel(
          id: currentItem.id, name: currentItem.name, price: currentItem.price,
          category: currentItem.category, quantity: currentItem.quantity - 1,
        );
      }
    }
    notifyListeners();
  }

  void clearProductFromCart(int productId) {
    if (_globalCart.containsKey(productId)) {
      _globalCart.remove(productId);
      notifyListeners();
    }
  }

  Future<void> checkoutStoreCartSuccess(List<int> selectedIds, {String proofOfPayment = "N/A"}) async {
    List<CartModel> itemsSnapshot = [];
    for (var id in selectedIds) {
      if (_globalCart.containsKey(id)) {
        itemsSnapshot.add(_globalCart[id]!);
        _globalCart.remove(id);
      }
    }

    if (itemsSnapshot.isEmpty) return;

    List<String> itemsBought = [];
    double calculatedTotal = 0.0;

    for (var item in itemsSnapshot) {
      double itemPrice = double.tryParse(item.price) ?? 0.0;
      calculatedTotal += (itemPrice * item.quantity);
      itemsBought.add("${item.quantity}x ${item.name}");
    }

    String generatedTxnId = "ST-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}";

    // 🚀 TRY-CATCH PROTECTION LOOP ADDED HERE
    try {
      _pendingTransactions.add(PendingTransaction(
        id: generatedTxnId, type: "Store", description: itemsBought.join(", "),
        totalPrice: calculatedTotal, storeItemsSnapshot: itemsSnapshot, serviceItemsSnapshot: [],
        userName: userName, userPhone: userPhone, userAddress: userAddress, txUserId: _userId,
        proofOfPayment: proofOfPayment,
      ));

      await _supabase.from('pending_transactions').insert({
        'id': generatedTxnId, 'type': "Store", 'description': itemsBought.join(", "),
        'total_price': calculatedTotal, 'status': "Pending", 'user_name': userName,
        'user_phone': userPhone, 'user_address': userAddress, 'user_id': _userId,
        'proof_of_payment': proofOfPayment,
        'store_items_json': itemsSnapshot.map((x) => {'id': x.id, 'name': x.name, 'price': x.price, 'category': x.category, 'quantity': x.quantity}).toList()
      });
    } catch (error) {
      debugPrint("Supabase Store ledger write exception caught: $error");
    } finally {
      // 🔒 Reaches this block to clear the UI cart even if a network drop or schema error happens
      _globalCart.clear();
      notifyListeners();
    }
  }

  Future<void> checkoutServicesSuccess(List<int> selectedIds, {String proofOfPayment = "N/A"}) async {
    List<BookedService> servicesSnapshot = [];
    List<String> serviceNames = [];
    double calculatedTotal = 0.0;

    for (var id in selectedIds) {
      if (_bookedServices.containsKey(id)) {
        final service = _bookedServices[id]!;
        servicesSnapshot.add(service);
        serviceNames.add(service.serviceTitle);
        calculatedTotal += service.totalPrice;
        _bookedServices.remove(id);
      }
    }

    if (servicesSnapshot.isEmpty) return;
    String generatedTxnId = "SR-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}";

    // 🚀 TRY-CATCH PROTECTION LOOP ADDED HERE
    try {
      _pendingTransactions.add(PendingTransaction(
        id: generatedTxnId, type: "Services", description: serviceNames.join(", "),
        totalPrice: calculatedTotal, storeItemsSnapshot: [], serviceItemsSnapshot: servicesSnapshot,
        userName: userName, userPhone: userPhone, userAddress: userAddress, txUserId: _userId,
        proofOfPayment: proofOfPayment,
      ));

      await _supabase.from('pending_transactions').insert({
        'id': generatedTxnId, 'type': "Services", 'description': serviceNames.join(", "),
        'total_price': calculatedTotal, 'status': "Pending", 'user_name': userName,
        'user_phone': userPhone, 'user_address': userAddress, 'user_id': _userId,
        'proof_of_payment': proofOfPayment,
        'service_items_json': servicesSnapshot.map((x) => x.toJson()).toList()
      });
    } catch (error) {
      debugPrint("Supabase Service ledger write exception caught: $error");
    } finally {
      notifyListeners();
    }
  }

  Future<void> adminDeclineTransaction(String transactionId, String reason) async {
    int matchingIndex = _pendingTransactions.indexWhere((txn) => txn.id == transactionId);
    if (matchingIndex == -1) return;

    final targetTxn = _pendingTransactions[matchingIndex];

    try {
      // 1. Update status flag directly in Supabase to log the reason
      await _supabase.from('pending_transactions').update({
        'status': "Declined: $reason"
      }).eq('id', transactionId);

      // 2. Dispatch a notification directly to the specific buyer's ID
      await _createNewNotification(
        "Payment Declined ❌",
        "Your order request ($transactionId) has been declined. Reason: $reason",
        targetUserId: targetTxn.txUserId,
      );

      // 3. Refresh arrays globally
      await loadDataFromSupabase();
    } catch (error) {
      debugPrint("Failed to execute admin decline sequence: $error");
    }
  }

  Future<void> adminConfirmTransaction(String transactionId) async {
    int matchingIndex = _pendingTransactions.indexWhere((txn) => txn.id == transactionId);
    if (matchingIndex == -1 || _pendingTransactions[matchingIndex].status == "Confirmed") return;

    final targetTxn = _pendingTransactions[matchingIndex];
    targetTxn.status = "Confirmed";
    _logTransactionDate();

    await _supabase.from('pending_transactions').update({'status': "Confirmed"}).eq('id', transactionId);

    if (targetTxn.type == "Store") {
      List<String> itemsBought = [];
      for (var item in targetTxn.storeItemsSnapshot) {
        int activeStock = getStockLevel(item.id);
        _petStockLevels[item.id] = activeStock - item.quantity;
        itemsBought.add("${item.quantity}x ${item.name}");

        await _supabase.from('pet_stocks').upsert({'pet_id': item.id, 'stock_level': _petStockLevels[item.id]});
      }

      await _createNewNotification("Purchase Confirmed! 🎉", "Successfully adopted: ${itemsBought.join(', ')}.");
    } else if (targetTxn.type == "Services") {
      List<String> serviceNames = [];
      for (var service in targetTxn.serviceItemsSnapshot) {
        service.status = "Active: ${service.serviceTitle}";
        serviceNames.add(service.serviceTitle);

        await _supabase.from('registered_pets').insert({
          'id': service.id, 'service_title': service.serviceTitle, 'total_price': service.totalPrice,
          'logistics_mode': service.logisticsMode, 'pet_type': service.petType, 'pet_name': service.petName,
          'pet_color': service.petColor, 'owner_address': service.ownerAddress, 'status': service.status,
          'user_id': targetTxn.txUserId
        });
      }

      await _createNewNotification(
        "Checkout Complete! 🎉",
        "Confirmed service applications for: ${serviceNames.join(', ')}.",
        targetUserId: targetTxn.txUserId,
      );
    }

    final profileData = await _supabase.from('profiles').select('loyalty_points').eq('id', targetTxn.txUserId).maybeSingle();
    int currentBuyerPoints = profileData != null ? (profileData['loyalty_points'] ?? 0) : 0;
    int updatedBuyerPoints = currentBuyerPoints + (targetTxn.type == "Store" ? 10 : 5);

    await _supabase.from('profiles').update({'loyalty_points': updatedBuyerPoints}).eq('id', targetTxn.txUserId);

    loadDataFromSupabase();
  }

  Future<void> addServiceBooking({
    required String title, required double totalCost, required String logistics,
    required String type, required String name, required String color, required String address,
  }) async {
    int bookingId = DateTime.now().millisecondsSinceEpoch;
    _bookedServices[bookingId] = BookedService(
      id: bookingId, serviceTitle: title, totalPrice: totalCost, logisticsMode: logistics,
      petType: type, petName: name, petColor: color, ownerAddress: address, ownerId: _userId,
    );

    await _createNewNotification("Service Added to Cart! 🛒", "Appointment '$title' added to cart.");
    notifyListeners();
  }

  Future<void> markAllNotificationsRead() async {
    for (var notif in _notifications) {
      notif["isRead"] = true;
    }
    notifyListeners();
    try {
      await _supabase.from('user_notifications').update({'is_read': true}).eq('user_id', _userId);
    } catch (e) {
      debugPrint("Error clearing unread badges from remote database: $e");
    }
  }

  void clearServiceBooking(int id) {
    if (_bookedServices.containsKey(id)) {
      _bookedServices.remove(id);
      notifyListeners();
    }
  }

  Future<void> confirmToCart(int productId) async {
    int chosenQty = getSelectionQty(productId);
    int currentStock = getStockLevel(productId);
    if (chosenQty <= 0 || chosenQty > currentStock) return;

    final pet = _availablePets.firstWhere((p) => p.id == productId);

    if (_globalCart.containsKey(productId)) {
      int existingQty = _globalCart[productId]!.quantity;
      if (existingQty + chosenQty > currentStock) return;

      _globalCart.update(productId, (existing) => CartModel(
        id: existing.id, name: existing.price, price: existing.price,
        category: existing.category, quantity: existing.quantity + chosenQty,
      ));
    } else {
      _globalCart[productId] = CartModel(
        id: pet.id, name: pet.name, price: pet.price, category: pet.category, quantity: chosenQty,
      );
    }

    await _createNewNotification("Item Added to Cart! 🛍️", "$chosenQty x ${pet.name} added to cart.");
    _selectedQuantities[productId] = 0;
    notifyListeners();
  }

  void updateHotPetsDisplayCount(int count) { _hotLimitCount = count; notifyListeners(); }
  void updatePromoItem(int index, String title, String subtitle) { if (index >= 0 && index < _promoItems.length) { _promoItems[index]["title"] = title; _promoItems[index]["subtitle"] = subtitle; notifyListeners(); } }
  void updateResourceGridItem(int index, String title) { if (index >= 0 && index < _resourceGridItems.length) { _resourceGridItems[index]["title"] = title; notifyListeners(); } }
  void adminModifyProductPrice(int productId, String newPrice) { int idx = _availablePets.indexWhere((p) => p.id == productId); if (idx != -1) { _availablePets[idx] = PetModel(id: _availablePets[idx].id, name: _availablePets[idx].name, price: newPrice, category: _availablePets[idx].category, description: _availablePets[idx].description); notifyListeners(); } }
  void adminModifyServicePrice(int serviceId, double newPrice) { int idx = _services.indexWhere((s) => s.id == serviceId); if (idx != -1) { _services[idx] = ServiceDetail(id: _services[idx].id, title: _services[idx].title, price: newPrice, icon: _services[idx].icon, description: _services[idx].description); notifyListeners(); } }
}
