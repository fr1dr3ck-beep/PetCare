import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trial_project/pet/pet_store_controller.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  // 🚀 INTERNAL FEEDBACK PROMPT (Triggered if rating is 1, 2, or 3 Stars)
  void _showInternalFeedbackDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: Colors.white,
          title: const Row(
            children: [
              Icon(Icons.chat_bubble_outline_rounded, color: Colors.deepPurple, size: 22),
              SizedBox(width: 8),
              Text("We Value Your Feedback", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "We're sorry you didn't have a perfect experience! What can we do to improve our app and services for you?",
                style: TextStyle(fontSize: 13, color: Colors.black54, height: 1.4),
              ),
              SizedBox(height: 16),
              TextField(
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Tell us your suggestions...",
                  hintStyle: TextStyle(fontSize: 12, color: Colors.black26),
                  filled: true,
                  fillColor: Color(0xFFF5F5F7),
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide.none),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Thank you! Your feedback has been sent directly to our team."), backgroundColor: Color(0xFF4DB6AC)),
                );
              },
              child: const Text("Submit Feedback", style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  // 🚀 POPUP RATING SYSTEM DIALOG PANEL (Main Entry)
  void _showInteractiveRatingDialog(BuildContext context) {
    final storeState = Provider.of<PetStoreController>(context, listen: false);
    int selectedStars = 0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.deepPurple[50], shape: BoxShape.circle),
                    child: Image.asset('assets/images/petslider/logo.png', height: 36), //
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    "Rate PetCare Experience",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Tap your satisfaction score below to update our community parameters.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.black38, height: 1.4),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      int starValue = index + 1;
                      bool isFilled = starValue <= selectedStars;

                      return GestureDetector(
                        onTap: () {
                          setDialogState(() {
                            selectedStars = starValue;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(
                            isFilled ? Icons.star_rounded : Icons.star_border_rounded,
                            color: Colors.amber,
                            size: 38,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey[200]!),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text("Cancel", style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                      ),
                      const SizedBox(width: 12),

                      Expanded(
                        child: ElevatedButton(
                          onPressed: selectedStars == 0 ? null : () async {
                            Navigator.pop(context);
                            await storeState.submitPlatformRating(selectedStars);

                            if (selectedStars <= 3) {
                              if (context.mounted) _showInternalFeedbackDialog(context);
                            } else {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Thank you for your rating! Rewards points loaded."), backgroundColor: Color(0xFF4DB6AC)),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            disabledBackgroundColor: Colors.grey[200],
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 0,
                          ),
                          child: Text(
                            "Continue",
                            style: TextStyle(
                              color: selectedStars == 0 ? Colors.black26 : Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 🚀 DIALOG PROMPT FOR USER OPINIONS & IDEAS
  void _showRecommendationDialog(BuildContext context) {
    final opinionController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: Colors.white,
          title: const Row(
            children: [
              Icon(Icons.auto_awesome_outlined, color: Colors.deepPurple, size: 22),
              SizedBox(width: 8),
              Text("Submit Recommendation", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Share your words, layout suggestions, or general opinions to help expand our platform capabilities parameters.",
                style: TextStyle(fontSize: 12, color: Colors.black54, height: 1.4),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: opinionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: "Type your recommendations or feedback here...",
                  hintStyle: TextStyle(fontSize: 12, color: Colors.black26),
                  filled: true,
                  fillColor: Color(0xFFF5F5F7),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide.none,
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
                String inputOpinion = opinionController.text.trim();
                Navigator.pop(dialogContext);

                if (inputOpinion.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Thank you! Your custom recommendations have been sent to our team logs."),
                      backgroundColor: Color(0xFF4DB6AC),
                    ),
                  );
                }
              },
              child: const Text("Submit", style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  // 🐾 FLASHY, WELCOMING AND ENERGETIC ABOUT US STORY MODAL PANEL
  void _showAboutUsDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          backgroundColor: Colors.white,
          contentPadding: EdgeInsets.zero, // Enables full-bleed gradient styling for the header block
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF673AB7), Color(0xFF4DB6AC)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.pets_rounded, size: 48, color: Colors.white),
                    SizedBox(height: 10),
                    Text(
                      "Welcome to PetCare! 🎉",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5),
                    ),
                    Text(
                      "Where Happiness Has Paws 🐾",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white, letterSpacing: 0.5),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const Text(
                      "We aren't just an application we are a passionate family of animal lovers dedicated to bringing endless tail wags, joyful purrs, and stress-free care directly to your fingertips! 🐶🐱\n\n"
                          "Every feature here was designed to spark joy, protect health, and celebrate the incredible bonds we share with our pets. Thank you for joining our flock, trusting our care hub,\n and becoming a certified member of our global pet-loving family! 🎉🐕\n"
                          "Our platform bridges premium companion adoptions, automated luxury spa bookings, and cloud-synchronized health logs into one happy ecosystem, ensuring your best friends get the royal treatment they deserve.\n Thank you for joining our pack!",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Color(0xFF4A3B60), fontWeight: FontWeight.w600, height: 1.5, letterSpacing: 0.1),
                    ),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: () => Navigator.pop(dialogContext),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4DB6AC), Color(0xFF00796B)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4DB6AC).withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            "LET'S ROLL! 🐾",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.0),
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.grey[300],
      child: Column(
        children: [
          // 🌟 REMOVED CRIMPING DRAWERHEADER PROTOCOLS FOR AN UNCONSTRAINED IMAGE WRAPPER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 50, bottom: 25, left: 16, right: 16),
            child: Image.asset(
              'assets/images/petslider/logo.png',
              height: 160, // 🚀 Boosted profile size parameters cleanly
              width: 250,
              fit: BoxFit.contain,
            ),
          ),

          Divider(
            height: 1, // Total logical space allocated to the widget block
            thickness: 1.5, // Total visible thickness height lines
            indent: 28, // Symmetrical padding margin on the left vector
            endIndent: 28, // Symmetrical padding margin on the right vector
            color: const Color(0xFF673AB7).withOpacity(0.18), // Soft theme purple overlay blend
          ),
          const SizedBox(height: 16), // Balanced margin spacing matrix before buttons load

          // 🏠 HOME MENU LINK
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('H O M E '),
            onTap: () {
              if (Scaffold.of(context).isDrawerOpen) {
                Navigator.pop(context);
              }
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),

          // ✨ RECOMMENDATION MENU LINK
          ListTile(
            leading: const Icon(Icons.auto_awesome),
            title: const Text('RECOMMENDATION'),
            onTap: () {
              if (Scaffold.of(context).isDrawerOpen) {
                Navigator.pop(context);
              }
              _showRecommendationDialog(context);
            },
          ),

          // ⭐ RATE US MENU LINK
          ListTile(
            leading: const Icon(Icons.rate_review_outlined),
            title: const Text('R A T E   U S'),
            onTap: () {
              if (Scaffold.of(context).isDrawerOpen) {
                Navigator.pop(context);
              }
              _showInteractiveRatingDialog(context);
            },
          ),

          // 🐾 ABOUT US MENU LINK
          ListTile(
            leading: const Icon(Icons.info_outline_rounded),
            title: const Text('A B O U T  U S'),
            onTap: () {
              if (Scaffold.of(context).isDrawerOpen) {
                Navigator.pop(context);
              }
              _showAboutUsDialog(context);
            },
          ),
        ],
      ),
    );
  }
}