import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:realstore/live/userAuth/account_controller.dart';

import 'package:realstore/live/userAuth/authController.dart';

class EarnLogin extends StatefulWidget {
  const EarnLogin({super.key});

  @override
  State<EarnLogin> createState() => _EarnLoginState();
}

class _EarnLoginState extends State<EarnLogin> {
  final AccountController accountController = Get.put(AccountController());
  //late Blockchain blockchainInstance;
  late AuthController authController;

  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();

  // 🔹 Focus nodes
  final FocusNode emailFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();

  // 🔹 Logo size
  double logoSize = 96;

  @override
  void initState() {
    super.initState();
    accountController.toggleBalanceVisibility();

    // blockchainInstance = Blockchain();
    authController = Get.put(AuthController());

    // 🔹 Listen for focus changes
    emailFocus.addListener(_handleFocusChange);
    passwordFocus.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    final hasFocus = emailFocus.hasFocus || passwordFocus.hasFocus;

    setState(() {
      logoSize = hasFocus ? 20 : 96;
    });
  }

  @override
  void dispose() {
    emailFocus.dispose();
    passwordFocus.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /// 🔹 LOGO (same UI, dynamic size)
                ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    width: logoSize,
                    height: logoSize,
                    child: Image.asset(
                      'assets/images/RealStore Logo.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// 🔹 TITLE
                const Text(
                  'Welcome back',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),

                const SizedBox(height: 6),

                Text(
                  'Sign in to continue on RealStore',
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),

                const SizedBox(height: 30),

                /// 🔹 CARD
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 30,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      /// EMAIL
                      TextField(
                        focusNode: emailFocus,
                        controller: emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.black,
                              width: 2,
                            ),
                          ),
                          prefixIcon: const Icon(Icons.email),
                          labelText: 'Email',
                          labelStyle: TextStyle(
                            color: Colors.black.withOpacity(0.65),
                          ),
                          hintText: 'Enter your email',
                        ),
                      ),

                      const SizedBox(height: 16),

                      /// PASSWORD
                      Obx(
                        () => TextField(
                          focusNode: passwordFocus,
                          controller: passwordCtrl,
                          obscureText: !authController.isPasswordVisible.value,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.black,
                                width: 2,
                              ),
                            ),
                            prefixIcon: const Icon(Icons.lock),
                            labelText: 'Password',
                            labelStyle: TextStyle(
                              color: Colors.black.withOpacity(0.65),
                            ),
                            hintText: 'Enter 6-digit password',
                            counterText: '',
                            suffixIcon: IconButton(
                              icon: Icon(
                                authController.isPasswordVisible.value
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed:
                                  authController.togglePasswordVisibility,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      /// FORGOT PASSWORD
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Get.toNamed('/forgotpassword'),
                          child: Text(
                            'Forgot password?',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black.withOpacity(0.65),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      /// LOGIN BUTTON
                      Obx(
                        () => SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: authController.isLoading.value
                                ? null
                                : () {
                                    authController.login(
                                      emailCtrl.text.trim(),
                                      passwordCtrl.text.trim(),
                                    );
                                  },
                            child: authController.isLoading.value
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : Text(
                                    'Log in',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                /// SIGN UP
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account?",
                      style: TextStyle(fontSize: 13),
                    ),
                    TextButton(
                      onPressed: () => Get.toNamed('/signup'),
                      child: Text(
                        'Sign up',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black.withOpacity(0.65),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                /// FOOTER
                Text(
                  'Shop Real. Shop Direct.',
                  style: TextStyle(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color: Colors.black45,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//------------------------------------------------------------------------------//

class EarnSignUp extends StatefulWidget {
  const EarnSignUp({super.key});

  @override
  State<EarnSignUp> createState() => _EarnSignUpState();
}

class _EarnSignUpState extends State<EarnSignUp> {
  //late Blockchain blockchainInstance;
  late AuthController authController;

  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();

  /// 🔹 Optional — a friend's 6-digit referral code.
  final TextEditingController referCodeCtrl = TextEditingController();

  // 🔹 Focus nodes
  final FocusNode nameFocus = FocusNode();
  final FocusNode emailFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  final FocusNode referCodeFocus = FocusNode();

  // 🔹 Logo size
  double logoSize = 96;

  @override
  void initState() {
    super.initState();
    //blockchainInstance = Blockchain();
    authController = Get.put(AuthController());

    // 🔹 Listen for focus changes
    nameFocus.addListener(_handleFocusChange);
    emailFocus.addListener(_handleFocusChange);
    passwordFocus.addListener(_handleFocusChange);
    referCodeFocus.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    final hasFocus =
        nameFocus.hasFocus ||
        emailFocus.hasFocus ||
        passwordFocus.hasFocus ||
        referCodeFocus.hasFocus;

    setState(() {
      logoSize = hasFocus ? 20 : 96;
    });
  }

  @override
  void dispose() {
    nameFocus.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    referCodeFocus.dispose();
    nameCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    referCodeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              children: [
                /// 🔹 LOGO (same UI, dynamic size)
                ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    width: logoSize,
                    height: logoSize,
                    child: Image.asset(
                      'assets/images/RealStore Logo.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// 🔹 TITLE
                const Text(
                  'Create account',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),

                const SizedBox(height: 6),

                Text(
                  'Join RealStore and get started',
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),

                const SizedBox(height: 30),

                /// 🔹 CARD
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 30,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      /// NAME
                      TextField(
                        focusNode: nameFocus,
                        controller: nameCtrl,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.black,
                              width: 2,
                            ),
                          ),
                          prefixIcon: const Icon(Icons.person),
                          labelText: 'Name',
                          labelStyle: TextStyle(
                            color: Colors.black.withOpacity(0.65),
                          ),
                          hintText: 'Enter your name',
                        ),
                      ),

                      const SizedBox(height: 16),

                      /// EMAIL
                      TextField(
                        focusNode: emailFocus,
                        controller: emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.black,
                              width: 2,
                            ),
                          ),
                          prefixIcon: const Icon(Icons.email),
                          labelText: 'Email',
                          labelStyle: TextStyle(
                            color: Colors.black.withOpacity(0.65),
                          ),
                          hintText: 'Enter your email',
                        ),
                      ),

                      const SizedBox(height: 16),

                      /// PASSWORD
                      Obx(
                        () => TextField(
                          focusNode: passwordFocus,
                          controller: passwordCtrl,
                          obscureText: !authController.isPasswordVisible.value,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Colors.black,
                                width: 2,
                              ),
                            ),
                            prefixIcon: const Icon(Icons.lock),
                            labelText: 'Password',
                            labelStyle: TextStyle(
                              color: Colors.black.withOpacity(0.65),
                            ),
                            hintText: 'Enter 6-digit password',
                            counterText: '',
                            suffixIcon: IconButton(
                              icon: Icon(
                                authController.isPasswordVisible.value
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed:
                                  authController.togglePasswordVisibility,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      /// REFERRAL CODE (optional)
                      TextField(
                        focusNode: referCodeFocus,
                        controller: referCodeCtrl,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.black,
                              width: 2,
                            ),
                          ),
                          prefixIcon: const Icon(Icons.card_giftcard),
                          labelText: 'Referral code (optional)',
                          labelStyle: TextStyle(
                            color: Colors.black.withOpacity(0.65),
                          ),
                          hintText: "Friend's 6-digit code",
                          counterText: '',
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// SIGN UP BUTTON
                      Obx(
                        () => SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: authController.isLoading.value
                                ? null
                                : () async {
                                    if (nameCtrl.text.isEmpty ||
                                        emailCtrl.text.isEmpty ||
                                        passwordCtrl.text.isEmpty) {
                                      Get.snackbar(
                                        'Error',
                                        'All fields are required',
                                      );
                                      return;
                                    }

                                    await authController.signup(
                                      nameCtrl.text.trim(),
                                      emailCtrl.text.trim(),
                                      passwordCtrl.text.trim(),
                                      referralCode: referCodeCtrl.text.trim(),
                                    );
                                  },
                            child: authController.isLoading.value
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    'Create account',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                /// LOGIN LINK
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account?',
                      style: TextStyle(fontSize: 13),
                    ),
                    TextButton(
                      onPressed: () => Get.toNamed('/login'),
                      child: Text(
                        'Log in',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black.withOpacity(0.65),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                /// FOOTER
                Text(
                  'Shop Real. Shop Direct.',
                  style: TextStyle(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color: Colors.black45,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
