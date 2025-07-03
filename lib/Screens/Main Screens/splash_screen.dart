import 'package:flutter/material.dart';
import 'sign_in_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SignInPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final desiredAspectRatio = 140 / 270; // Your logo aspect ratio

    // Calculate logo dimensions (max 80% width or 50% height)
    double logoWidth = screenSize.width * 0.8;
    double logoHeight = logoWidth / desiredAspectRatio;

    if (logoHeight > screenSize.height * 0.5) {
      logoHeight = screenSize.height * 0.5;
      logoWidth = logoHeight * desiredAspectRatio;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Centered Logo (slightly higher than center)
          Align(
            alignment: const Alignment(0, -0.3), // 30% up from center
            child: SizedBox(
              width: logoWidth,
              height: logoHeight,
              child: Image.asset(
                'assets/logo.png',
                fit: BoxFit.contain,
              ),
            ),
          ),

          // Bottom-aligned text and loader
          Positioned(
            bottom: screenSize.height * 0.1, // 15% from bottom
            left: 0,
            right: 0,
            child: Column(
              children: [
                const Text(
                  'Rethink | Reduce | Recycle',
                  style: TextStyle(
                    fontSize: 24,
                    color: Color(0xFF86c13c),
                  ),
                ),
                const SizedBox(height: 20),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF86c13c)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
