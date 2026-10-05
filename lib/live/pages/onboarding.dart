import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:realstore/live/liveControllers/startup_controller.dart';

// class Onboarding extends StatefulWidget {
//   const Onboarding({super.key});

//   @override
//   State<Onboarding> createState() => _OnboardingState();
// }

// class _OnboardingState extends State<Onboarding>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _fadeAnimation;
//   final ChatListController controller = Get.put(ChatListController());
//   final ThemeController themeCtrl = Get.put(ThemeController());
//   final AccountController accountController = Get.put(AccountController());
//   final IconNavigationHandler navigationHandler = IconNavigationHandler();
//   final CurrencyController currencyController = Get.put(CurrencyController());
//   final AddMoneyController addMoneyController = Get.find<AddMoneyController>();
//   final PbcMarketController pbcMarketController =
//       Get.put(PbcMarketController());
//   final AvailableBalanceController balanceCtrl =
//       Get.put(AvailableBalanceController());

//   @override
//   void initState() {
//     super.initState();

//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1200),
//     );

//     _fadeAnimation = CurvedAnimation(
//       parent: _controller,
//       curve: Curves.easeInOut,
//     );

//     _controller.forward();

//     Future.delayed(const Duration(seconds: 10), () {
//       Get.offNamed('/login');
//     });
//   }

//   // @override
//   // void initState() {
//   //   super.initState();

//   //   _controller = AnimationController(
//   //     vsync: this,
//   //     duration: const Duration(milliseconds: 1200),
//   //   );

//   //   _fadeAnimation = CurvedAnimation(
//   //     parent: _controller,
//   //     curve: Curves.easeInOut,
//   //   );

//   //   _controller.forward();

//   //   Future.delayed(const Duration(seconds: 6), () async {
//   //     final authController = Get.find<AuthController>();
//   //     final themeController = Get.find<ThemeController>();
//   //     final user = authController.currentUser;

//   //     if (user != null) {
//   //       /// Load saved theme first
//   //       await themeController.loadTheme();

//   //       Get.offAllNamed('/home');
//   //     } else {
//   //       Get.offAllNamed('/login');
//   //     }
//   //   });
//   // }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: FadeTransition(
//         opacity: _fadeAnimation,
//         child: Center(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               /// 🔹 Rounded Textido Logo
//               Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(24),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.08),
//                       blurRadius: 18,
//                       offset: const Offset(0, 8),
//                     ),
//                   ],
//                 ),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(24),
//                   child: Image.asset(
//                     'assets/images/Textido Logo.jpeg',
//                     width: 120,
//                     height: 120,
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 20),

//               /// 🔹 Subtle tagline
//               Text(
//                 'A text-first social platform',
//                 style: TextStyle(
//                   fontSize: 12.5,
//                   fontStyle: FontStyle.italic,
//                   color: Colors.black.withOpacity(0.55),
//                   letterSpacing: 0.3,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class Onboarding extends StatefulWidget {
//   const Onboarding({super.key});

//   @override
//   State<Onboarding> createState() => _OnboardingState();
// }

// class _OnboardingState extends State<Onboarding>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _fadeAnimation;

//   @override
//   void initState() {
//     super.initState();

//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1200),
//     );

//     _fadeAnimation = CurvedAnimation(
//       parent: _controller,
//       curve: Curves.easeInOut,
//     );

//     _controller.forward();

//     /// ✅ Start app initialization silently
//     startupCtrl.initializeApp();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: FadeTransition(
//         opacity: _fadeAnimation,
//         child: Center(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               /// 🔹 Rounded Textido Logo
//               Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(24),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.08),
//                       blurRadius: 18,
//                       offset: const Offset(0, 8),
//                     ),
//                   ],
//                 ),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(24),
//                   child: Image.asset(
//                     'assets/images/Textido Logo.jpeg',
//                     width: 120,
//                     height: 120,
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 20),

//               /// 🔹 Subtle tagline
//               Text(
//                 'A text-first social platform',
//                 style: TextStyle(
//                   fontSize: 12.5,
//                   fontStyle: FontStyle.italic,
//                   color: Colors.black.withOpacity(0.55),
//                   letterSpacing: 0.3,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  final StartupController startupCtrl = Get.put(StartupController());

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.forward();

    /// ✅ Start app initialization silently
    startupCtrl.initializeApp();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// 🔹 Rounded Textido Logo
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset(
                    'assets/images/RealStore Logo.png',
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// 🔹 Subtle tagline
              Text(
                // 'Connect, Chat, Earn, Buy & Sell',
                'Shop Real. Shop Direct.',
                style: TextStyle(
                  fontSize: 12.5,
                  fontStyle: FontStyle.italic,
                  color: Colors.black.withOpacity(0.55),
                  letterSpacing: 0.3,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
