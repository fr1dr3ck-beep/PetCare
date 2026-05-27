import 'package:flutter/material.dart';
import '../responsive/desktop_body.dart';
import '../responsive/mobile_body.dart';
import '../responsive/responsive_layout.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The ResponsiveLayout decides which body to show based on screen width
      body: ResponsiveLayout(
        mobileBody: MyMobileBody(),
        desktopBody: MyDesktopBody(),
      ),
    );
  }
}