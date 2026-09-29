import 'package:realstore/live/pages/ecommerce_routes.dart';
import 'package:realstore/live/userAuth/authController.dart';
import 'package:realstore/platformControllers/accountController.dart';
import 'package:realstore/platformControllers/domainController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EarnLogin1 extends StatefulWidget {
  final String organizationId;
  final String slug;
  EarnLogin1({super.key, required this.organizationId, required this.slug});

  final nav = Get.put(EcommerceLiveNavController());
  final domainCtrl = Get.find<DomainController>();

  String get orgId => domainCtrl.organizationId.value;

  @override
  State<EarnLogin1> createState() => _EarnLogin1State();
}

class _EarnLogin1State extends State<EarnLogin1> {
  final AccountController accountController = Get.put(
    AccountController(),
    permanent: true,
  ); //Get.put(AccountController());
  // late Blockchain blockchainInstance;
  late AuthController1 authController;

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
    authController = Get.put(AuthController1());

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
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: Colors.black,
          ),
          onPressed: () {
            Get.back();
          },
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            const Text(
              'Login',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.black,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
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
                    color: Colors.white,
                    child: Obx(() {
                      final domainCtrl = Get.find<DomainController>();
                      if (domainCtrl.organizationLogo.value.isNotEmpty) {
                        return Image.network(
                          domainCtrl.organizationLogo.value,
                          fit: BoxFit.cover,
                        );
                      }

                      return const Center(
                        child: Icon(Icons.store, size: 32, color: Colors.black),
                      );
                    }),
                  ),
                ),

                const SizedBox(height: 20),

                /// 🔹 TITLE
                const Text(
                  'Welcome back',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),

                const SizedBox(height: 6),

                // Text(
                //   'Sign in to continue on realstore',
                //   style: TextStyle(
                //     fontSize: 13,
                //     color: Colors.black54,
                //   ),
                // ),
                Text(
                  'Access ${widget.domainCtrl.organizationName.value} account under realstore or Continue with your Textido Account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    height: 1.5,
                  ),
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
                          onPressed: () {
                            Get.to(
                              () => ForgotPassword1(
                                organizationId: widget.organizationId,
                                slug: widget.slug,
                              ),
                            );
                          },
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
                      onPressed: () => Get.to(
                        () => EarnSignUp1(
                          organizationId: widget.organizationId,
                          slug: widget.slug,
                        ),
                      ),
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
                  '${widget.domainCtrl.organizationDescription.value}',
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

/// Sign up page

class EarnSignUp1 extends StatefulWidget {
  final String organizationId;
  final String slug;
  EarnSignUp1({super.key, required this.organizationId, required this.slug});

  final nav = Get.put(EcommerceLiveNavController());
  final domainCtrl = Get.find<DomainController>();

  String get orgId => domainCtrl.organizationId.value;

  @override
  State<EarnSignUp1> createState() => _EarnSignUp1State();
}

class _EarnSignUp1State extends State<EarnSignUp1> {
  // late Blockchain blockchainInstance;
  late AuthController1 authController;

  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();

  // 🔹 Focus nodes
  final FocusNode nameFocus = FocusNode();
  final FocusNode emailFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();

  // 🔹 Logo size
  double logoSize = 96;

  @override
  void initState() {
    super.initState();
    // blockchainInstance = Blockchain();
    authController = Get.put(AuthController1());

    // 🔹 Listen for focus changes
    nameFocus.addListener(_handleFocusChange);
    emailFocus.addListener(_handleFocusChange);
    passwordFocus.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    final hasFocus =
        nameFocus.hasFocus || emailFocus.hasFocus || passwordFocus.hasFocus;

    setState(() {
      logoSize = hasFocus ? 20 : 96;
    });
  }

  @override
  void dispose() {
    nameFocus.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    nameCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: Colors.black,
          ),
          onPressed: () {
            Get.back();
          },
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            const Text(
              'Sign Up',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.black,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
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
                    color: Colors.white,
                    child: Obx(() {
                      final domainCtrl = Get.find<DomainController>();
                      if (domainCtrl.organizationLogo.value.isNotEmpty) {
                        return Image.network(
                          domainCtrl.organizationLogo.value,
                          fit: BoxFit.cover,
                        );
                      }

                      return const Center(
                        child: Icon(Icons.store, size: 32, color: Colors.black),
                      );
                    }),
                  ),
                ),

                const SizedBox(height: 20),

                /// 🔹 TITLE
                const Text(
                  'Create account',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),

                const SizedBox(height: 6),

                // Text(
                //   'Join realstore and get started',
                //   style: TextStyle(
                //     fontSize: 13,
                //     color: Colors.black54,
                //   ),
                // ),
                Text(
                  'Create a ${widget.domainCtrl.organizationName.value} account under realstore or Continue with your Textido Account.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    height: 1.5,
                  ),
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
                      onPressed: () {
                        Get.to(
                          () => EarnLogin1(
                            organizationId: widget.organizationId,
                            slug: widget.slug,
                          ),
                        );
                      },
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
                  '${widget.domainCtrl.organizationDescription.value}',
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

//forgot password page

class ForgotPassword1 extends StatefulWidget {
  final String organizationId;
  final String slug;

  ForgotPassword1({
    super.key,
    required this.organizationId,
    required this.slug,
  });

  final nav = Get.put(EcommerceLiveNavController());
  final domainCtrl = Get.find<DomainController>();

  String get orgId => domainCtrl.organizationId.value;

  @override
  State<ForgotPassword1> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword1> {
  late AuthController1 authController;

  final TextEditingController emailCtrl = TextEditingController();

  // 🔹 Focus node
  final FocusNode emailFocus = FocusNode();

  // 🔹 Logo size
  double logoSize = 96;

  @override
  void initState() {
    super.initState();

    authController = Get.put(AuthController1());

    // 🔹 Listen for focus changes
    emailFocus.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    setState(() {
      logoSize = emailFocus.hasFocus ? 20 : 96;
    });
  }

  @override
  void dispose() {
    emailFocus.dispose();
    emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: Colors.black,
          ),
          onPressed: () {
            Get.back();
          },
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            const Text(
              'Forgot Password',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.black,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
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
                    color: Colors.white,
                    child: Obx(() {
                      final domainCtrl = Get.find<DomainController>();
                      if (domainCtrl.organizationLogo.value.isNotEmpty) {
                        return Image.network(
                          domainCtrl.organizationLogo.value,
                          fit: BoxFit.cover,
                        );
                      }

                      return const Center(
                        child: Icon(Icons.store, size: 32, color: Colors.black),
                      );
                    }),
                  ),
                ),

                const SizedBox(height: 20),

                /// 🔹 TITLE
                const Text(
                  'Forgot password?',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),

                const SizedBox(height: 6),

                Text(
                  'Enter your email to reset your password',
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

                      const SizedBox(height: 20),

                      /// RESET BUTTON
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
                                    if (emailCtrl.text.isEmpty) {
                                      Get.snackbar(
                                        'Error',
                                        'Please enter your email',
                                        snackPosition: SnackPosition.BOTTOM,
                                      );
                                      return;
                                    }

                                    authController.sendPasswordResetEmail(
                                      emailCtrl.text.trim(),
                                    );
                                  },
                            child: authController.isLoading.value
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    'Send Email',
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

                /// SIGN UP LINK
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account?",
                      style: TextStyle(fontSize: 13),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.to(
                          () => EarnSignUp1(
                            organizationId: widget.organizationId,
                            slug: widget.slug,
                          ),
                        );
                      },
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
                  '${widget.domainCtrl.organizationDescription.value}',
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
