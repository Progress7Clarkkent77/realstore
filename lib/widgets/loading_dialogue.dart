import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:realstore/live/userAuth/account_controller.dart';

class LoadingDialog extends StatefulWidget {
  @override
  _LoadingDialogState createState() => _LoadingDialogState();
}

class _LoadingDialogState extends State<LoadingDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1), // 1-second fade animation
    )..repeat(reverse: true); // Loops animation

    _animation = Tween<double>(begin: 0.2, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Center(
        child: FadeTransition(
          opacity: _animation,
          child: Text(
            "LOADING",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
        ),
      ),
    );
  }
}

void showLoadingDialog(String message) {
  Get.dialog(
    Dialog(
      backgroundColor: Colors.transparent,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.black),
            SizedBox(height: 16),
            Obx(
              () => Text(
                loadingMessage.value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    barrierDismissible: false, // Prevent dismissing
  );
  loadingMessage.value = message;
}

void updateLoadingDialog(String newMessage) {
  loadingMessage.value = newMessage;
}

final RxString loadingMessage = "Loading...".obs;

class PaymentSuccess2 extends StatefulWidget {
  const PaymentSuccess2({super.key});

  @override
  State<PaymentSuccess2> createState() => _PaymentSuccess2State();
}

class _PaymentSuccess2State extends State<PaymentSuccess2> {
  final AccountController accountController = Get.put(AccountController());
  final List<String> images = ['assets/images/c2.jpg'];
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(seconds: 3), (timer) {
      setState(() {
        currentIndex = (currentIndex + 1) % images.length;
      });
    });
    //  accountController.fetchBalances(); // Fetch data on widget load
    accountController.fetchWalletAddress(); // Fetch wallet address on init
    accountController.toggleBalanceVisibility();

    accountController.fetchWalletDetails();
    accountController
        .fetchWalletAddress(); // Fetch wallet address on initialization
    accountController
        .fetchWalletData(); // Fetch both address & publicKey on init
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        height: double.infinity,
        width: double.infinity,
        child: Center(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  // image: DecorationImage(
                  //   image: AssetImage(images[currentIndex]),
                  //   fit: BoxFit.cover,
                  // ),
                  color: Colors.transparent,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(
                    16.0,
                  ), // Padding around the content
                  child: Align(
                    alignment: Alignment.centerLeft, // Align to the bottom left
                    child: Row(
                      children: [
                        Text(
                          "Status",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Spacer(), // Space between text and icon
                        IconButton(
                          onPressed: () {
                            Get.toNamed('/send');
                          },
                          icon: Icon(
                            Icons.arrow_back, // Use arrow icon
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 50),
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Image.asset(
                  'assets/images/success.png',
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Transaction Complete',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class PaymentFailure2 extends StatefulWidget {
  const PaymentFailure2({super.key});

  @override
  State<PaymentFailure2> createState() => _PaymentFailure2State();
}

class _PaymentFailure2State extends State<PaymentFailure2> {
  final AccountController accountController = Get.put(AccountController());
  final List<String> images = ['assets/images/c2.jpg'];
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(seconds: 3), (timer) {
      setState(() {
        currentIndex = (currentIndex + 1) % images.length;
      });
    });
    super.initState();
    //  accountController.fetchBalances(); // Fetch data on widget load
    accountController.fetchWalletAddress(); // Fetch wallet address on init
    accountController.toggleBalanceVisibility();

    accountController.fetchWalletDetails();
    accountController
        .fetchWalletAddress(); // Fetch wallet address on initialization
    accountController
        .fetchWalletData(); // Fetch both address & publicKey on init
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        height: double.infinity,
        width: double.infinity,
        child: Center(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  // image: DecorationImage(
                  //   image: AssetImage(images[currentIndex]),
                  //   fit: BoxFit.cover,
                  // ),
                  color: Colors.transparent,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(
                    16.0,
                  ), // Padding around the content
                  child: Align(
                    alignment: Alignment.centerLeft, // Align to the bottom left
                    child: Row(
                      children: [
                        Text(
                          "Status",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Spacer(), // Space between text and icon
                        IconButton(
                          onPressed: () {
                            Get.toNamed('/send');
                          },
                          icon: Icon(
                            Icons.arrow_back, // Use arrow icon
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 50),
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Image.asset(
                  'assets/images/cross-mark.png',
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Incorrect Pin or Insufficient Balance',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
