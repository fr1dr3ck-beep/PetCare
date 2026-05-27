import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:trial_project/pet/pet_store_controller.dart';

class PetSlider extends StatefulWidget {
  const PetSlider({super.key});

  @override
  State<PetSlider> createState() => _PetSliderState();
}

class _PetSliderState extends State<PetSlider> {
  PageController pageController = PageController(viewportFraction: 0.85);
  var _currPageValue = 0.0;
  double _scaleFactor = 0.8;
  double _height = 220;
  Timer? _timer;

  final List<Map<String, dynamic>> _welcomeSlides = [
    {
      "title": "Welcome to PetCare!",
      "tagline": "Your premium pet community, store, and services.",
      "reviews": "Happy Family",
      "image": "assets/images/petslider/first.jpg"
    },
    {
      "title": "Adorable Companions",
      "tagline": "A pet with plentiful lovely pets.",
      "reviews": "Certified Pedigree",
      "image": "assets/images/petslider/second.jpg"
    },
    {
      "title": "Quality Service",
      "tagline": "Efficient and up to standard services.",
      "reviews": "Local Support",
      "image": "assets/images/petslider/third.jpg"
    },
    {
      "title": "Reliable and Trustworthy",
      "tagline": "Bursting with delightful energy with a sense of security.",
      "reviews": "Elite Services",
      "image": "assets/images/petslider/fourth.jpg"
    },
    {
      "title": "A lot of cuties!",
      "tagline": "Cute, cuddly, friendly lovely pets in abundance.",
      "reviews": "Active Perks",
      "image": "assets/images/petslider/fifth.jpg"
    },
  ];

  @override
  void initState() {
    super.initState();
    pageController.addListener(() {
      setState(() {
        _currPageValue = pageController.page!;
      });
    });

    _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (pageController.hasClients) {
        int nextPage = pageController.page!.toInt() + 1;
        if (nextPage >= _welcomeSlides.length) nextPage = 0;
        pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: Stack(
        children: [
          // 1. THE ACTUAL SLIDER
          PageView.builder(
            controller: pageController,
            itemCount: _welcomeSlides.length,
            itemBuilder: (context, position) {
              return _buildPageItem(position);
            },
          ),

          // 2. INVISIBLE LEFT ZONE
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () {
                if (pageController.hasClients) {
                  pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeIn,
                  );
                }
              },
              child: Container(
                width: 60,
                color: Colors.transparent,
              ),
            ),
          ),

          // 3. INVISIBLE RIGHT ZONE
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                if (pageController.hasClients) {
                  pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeIn,
                  );
                }
              },
              child: Container(
                width: 60,
                color: Colors.transparent,
              ),
            ),
          ),
        ], // End Stack children
      ), // End Stack
    ); // End SizedBox
  }

  Widget _buildPageItem(int index) {
    final slide = _welcomeSlides[index];

    // 🚀 READS DYNAMIC SYSTEM AVERAGES FROM PET STORE CONTROLLER
    final storeState = Provider.of<PetStoreController>(context);

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

    return Transform(
      transform: matrix,
      child: Stack(
        children: [
          Container(
            height: 220,
            margin: const EdgeInsets.only(left: 10, right: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: index.isEven ? const Color(0xFF69c5df) : const Color(0xFF9294cc),
              image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage(slide["image"]),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 110,
              margin: const EdgeInsets.only(left: 30, right: 30, bottom: 15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xFFe8e8e8),
                    blurRadius: 5.0,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                        slide["title"],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)
                    ),
                    const SizedBox(height: 2),
                    Text(
                        slide["tagline"],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: Colors.black38, fontWeight: FontWeight.w500)
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        // 🌟 DYNAMIC STAR LINES INTERLOCKED TO SYSTEM BALANCES
                        Wrap(
                          children: List.generate(5, (idx) {
                            return Icon(
                              idx < storeState.averageAppRating.floor() ? Icons.star_rounded : Icons.star_outline_rounded,
                              color: Colors.amber,
                              size: 14,
                            );
                          }),
                        ),
                        const SizedBox(width: 8),

                        // 🚀 DYNAMIC SCORE READ: Piles live database results directly onto the card view parameter metrics
                        Text(
                          "${storeState.averageAppRating}",
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54),
                        ),
                        const SizedBox(width: 8),

                        Flexible(
                          child: Text(
                            slide["reviews"],
                            style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}