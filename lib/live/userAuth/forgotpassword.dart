import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
//import 'package:otp_text_field/otp_text_field.dart';
//import 'package:otp_text_field/style.dart';

import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/style.dart';
import 'package:realstore/constant/colors.dart';
import 'package:realstore/live/userAuth/authController.dart';

// Make sure this imports your AuthController

// class ForgotPassword extends StatefulWidget {
//   const ForgotPassword({super.key});

//   @override
//   _ForgotPasswordState createState() => _ForgotPasswordState();
// }

// class _ForgotPasswordState extends State<ForgotPassword> {
//   late Blockchain blockchainInstance;
//   late AuthController _authController;

//   final TextEditingController _emailController = TextEditingController();
//   bool isHovered = false;

//   @override
//   void initState() {
//     super.initState();

//     blockchainInstance = Blockchain(); // ✅ Initialize here
//     _authController = Get.put(
//         AuthController(blockchainInstance)); // ✅ Pass Blockchain instance
//   }

//   @override
//   Widget build(BuildContext context) {
//     Color mainColor = getMainColor(context);
//     return Scaffold(
//       body: SingleChildScrollView(
//         child: Container(
//           // height: 700,
//           width: double.infinity,
//           decoration: BoxDecoration(
//             image: DecorationImage(
//               image: AssetImage('assets/images/whiteb1.jpg'),
//               fit: BoxFit.cover,
//             ),
//           ),
//           child: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 // Padding(
//                 //   padding: const EdgeInsets.all(8.0),
//                 //   child: Row(
//                 //     children: [
//                 //       IconButton(
//                 //         icon: const Icon(Icons.arrow_back_ios),
//                 //         onPressed: () {
//                 //           Get.toNamed("/elogin");
//                 //         },
//                 //       ),
//                 //     ],
//                 //   ),
//                 // ),
//                 SizedBox(height: 10),
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Container(
//                     height: 500,
//                     width: 400,
//                     decoration: BoxDecoration(
//                       color: Colors.black.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Column(
//                       children: [
//                         Container(
//                           color: Colors.transparent,
//                           width: 350,
//                           child: Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.start,
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   'Forgot Password',
//                                   style: TextStyle(
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.bold,
//                                     color: mainColor,
//                                   ),
//                                 ),
//                                 SizedBox(height: 20),
//                                 TextField(
//                                   controller: _emailController,
//                                   keyboardType: TextInputType.emailAddress,
//                                   inputFormatters: [
//                                     FilteringTextInputFormatter.deny(
//                                         RegExp(r'\s')), // Disallows spaces
//                                   ],
//                                   decoration: InputDecoration(
//                                     border: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(12),
//                                     ),
//                                     focusedBorder: OutlineInputBorder(
//                                       // Black border when focused
//                                       borderRadius: BorderRadius.circular(12),
//                                       borderSide: BorderSide(
//                                           color: Colors.black, width: 2),
//                                     ),
//                                     prefixIcon: const Icon(Icons.email),
//                                     labelText: 'Email',
//                                     labelStyle: TextStyle(
//                                       color: Colors.black.withOpacity(0.65),
//                                     ),
//                                     hintText: 'Enter your email',
//                                   ),
//                                 ),
//                                 SizedBox(height: 15),
//                               ],
//                             ),
//                           ),
//                         ),
//                         SizedBox(height: 10),
//                         Center(
//                           child: SizedBox(
//                             width: 180,
//                             child: MouseRegion(
//                               onEnter: (_) => setState(() => isHovered = true),
//                               onExit: (_) => setState(() => isHovered = false),
//                               child: Obx(() => ElevatedButton(
//                                     style: ElevatedButton.styleFrom(
//                                       padding: const EdgeInsets.symmetric(
//                                           vertical: 15),
//                                       backgroundColor: isHovered
//                                           ? mainColor.withOpacity(0.9)
//                                           : mainColor,
//                                       shadowColor:
//                                           Colors.black.withOpacity(0.4),
//                                       elevation: 10,
//                                       shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(30),
//                                       ),
//                                     ),
//                                     child: _authController.isLoading.value
//                                         ? CircularProgressIndicator(
//                                             color: Colors.white,
//                                           )
//                                         : const Text(
//                                             'Confirm Email',
//                                             style: TextStyle(
//                                               fontSize: 15,
//                                               color: Colors.white,
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                           ),
//                                     onPressed: () {
//                                       if (_emailController.text.isNotEmpty) {
//                                         _authController.sendPasswordResetEmail(
//                                           _emailController.text,
//                                         );
//                                       } else {
//                                         Get.snackbar(
//                                           'Error',
//                                           'Please enter an email address',
//                                           snackPosition: SnackPosition.BOTTOM,
//                                         );
//                                       }
//                                     },
//                                   )),
//                             ),
//                           ),
//                         ),
//                         SizedBox(height: 10),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 20),
//                           child: Column(
//                             children: [
//                               Text(
//                                 'Don\'t have an account yet?',
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.black,
//                                 ),
//                               ),
//                               TextButton(
//                                 onPressed: () {
//                                   Get.toNamed("/signup");
//                                 },
//                                 child: Text(
//                                   'Click here to get one',
//                                   style: TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.black.withOpacity(0.65),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         SizedBox(height: 50),
//                         Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Column(
//                             children: [
//                               Text(
//                                 'Textido',
//                                 style: TextStyle(
//                                   fontSize: 20,
//                                   fontWeight: FontWeight.bold,
//                                   //color: Colors.black,
//                                   color: Colors.black.withOpacity(0.65),
//                                 ),
//                               ),
//                               Text(
//                                 'A text-first social platform',
//                                 style: TextStyle(
//                                   fontSize: 10,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.black,
//                                   fontStyle: FontStyle.italic,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 Container(
//                   height: 300,
//                   color: Colors.transparent,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class ForgotPassword extends StatefulWidget {
//   const ForgotPassword({super.key});

//   @override
//   State<ForgotPassword> createState() => _ForgotPasswordState();
// }

// class _ForgotPasswordState extends State<ForgotPassword> {
//   late Blockchain blockchainInstance;
//   late AuthController authController;

//   final TextEditingController emailCtrl = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     blockchainInstance = Blockchain();
//     authController = Get.put(AuthController(blockchainInstance));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 24),
//           child: ConstrainedBox(
//             constraints: const BoxConstraints(maxWidth: 420),
//             child: Column(
//               children: [
//                 /// 🔹 LOGO
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(22),
//                   child: Image.asset(
//                     'assets/images/Textido Logo.jpeg',
//                     width: 96,
//                     height: 96,
//                     fit: BoxFit.cover,
//                   ),
//                 ),

//                 const SizedBox(height: 20),

//                 /// 🔹 TITLE
//                 const Text(
//                   'Forgot password?',
//                   style: TextStyle(
//                     fontSize: 22,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),

//                 const SizedBox(height: 6),

//                 Text(
//                   'Enter your email to reset your password',
//                   style: TextStyle(
//                     fontSize: 13,
//                     color: Colors.black54,
//                   ),
//                 ),

//                 const SizedBox(height: 30),

//                 /// 🔹 CARD
//                 Container(
//                   padding: const EdgeInsets.all(24),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(20),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.08),
//                         blurRadius: 30,
//                         offset: const Offset(0, 14),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     children: [
//                       /// EMAIL
//                       TextField(
//                         controller: emailCtrl,
//                         keyboardType: TextInputType.emailAddress,
//                         decoration: InputDecoration(
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide:
//                                 const BorderSide(color: Colors.black, width: 2),
//                           ),
//                           prefixIcon: const Icon(Icons.email),
//                           labelText: 'Email',
//                           labelStyle: TextStyle(
//                             color: Colors.black.withOpacity(0.65),
//                           ),
//                           hintText: 'Enter your email',
//                         ),
//                       ),

//                       const SizedBox(height: 20),

//                       /// RESET BUTTON
//                       Obx(() => SizedBox(
//                             width: double.infinity,
//                             height: 50,
//                             child: ElevatedButton(
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.black,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(30),
//                                 ),
//                               ),
//                               onPressed: authController.isLoading.value
//                                   ? null
//                                   : () {
//                                       if (emailCtrl.text.isEmpty) {
//                                         Get.snackbar(
//                                           'Error',
//                                           'Please enter your email',
//                                           snackPosition: SnackPosition.BOTTOM,
//                                         );
//                                         return;
//                                       }

//                                       authController.sendPasswordResetEmail(
//                                         emailCtrl.text.trim(),
//                                       );
//                                     },
//                               child: authController.isLoading.value
//                                   ? const CircularProgressIndicator(
//                                       color: Colors.white,
//                                     )
//                                   : const Text(
//                                       'Send Email',
//                                       style: TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.w700,
//                                         color: Colors.white,
//                                       ),
//                                     ),
//                             ),
//                           )),
//                     ],
//                   ),
//                 ),

//                 const SizedBox(height: 22),

//                 /// SIGN UP LINK
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Text(
//                       "Don't have an account?",
//                       style: TextStyle(fontSize: 13),
//                     ),
//                     TextButton(
//                       onPressed: () => Get.toNamed('/signup'),
//                       child: Text(
//                         'Sign up',
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black.withOpacity(0.65),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 14),

//                 /// FOOTER
//                 Text(
//                   'A text-first social platform',
//                   style: TextStyle(
//                     fontSize: 11,
//                     fontStyle: FontStyle.italic,
//                     color: Colors.black45,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  //late Blockchain blockchainInstance;
  late AuthController authController;

  final TextEditingController emailCtrl = TextEditingController();

  // 🔹 Focus node
  final FocusNode emailFocus = FocusNode();

  // 🔹 Logo size
  double logoSize = 96;

  @override
  void initState() {
    super.initState();
    // blockchainInstance = Blockchain();
    authController = Get.put(AuthController());

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
                      'assets/images/Textido Logo.jpeg',
                      fit: BoxFit.cover,
                    ),
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
                  'A text-first social platform',
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

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  // late Blockchain blockchainInstance;
  late AuthController _authController;

  String? newPassword;
  String? confirmPassword;
  bool isHovered = false;

  @override
  void initState() {
    super.initState();

    //blockchainInstance = Blockchain(); // ✅ Initialize here
    _authController = Get.put(AuthController()); // ✅ Pass Blockchain instance
  }

  @override
  Widget build(BuildContext context) {
    Color mainColor = getMainColor(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios),
                      onPressed: () {
                        Get.toNamed("/elogin");
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 25,
                    height: 25,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Image.asset(
                      'assets/images/RealStore Logo.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Afia Splendid LTD',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: mainColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                width: 350,
                decoration: BoxDecoration(
                  color: mainColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Change Login Password',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'The password should contain numbers that cannot be repeated or consecutive',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'New login password',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 5),
                      OTPTextField(
                        length: 6,
                        width: MediaQuery.of(context).size.width,
                        fieldWidth: 40,
                        style: const TextStyle(fontSize: 17),
                        textFieldAlignment: MainAxisAlignment.spaceAround,
                        fieldStyle: FieldStyle.box,
                        onCompleted: (pin) {
                          setState(() {
                            newPassword = pin;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Confirm new login password',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 5),
                      OTPTextField(
                        length: 6,
                        width: MediaQuery.of(context).size.width,
                        fieldWidth: 40,
                        style: const TextStyle(fontSize: 17),
                        textFieldAlignment: MainAxisAlignment.spaceAround,
                        fieldStyle: FieldStyle.box,
                        onCompleted: (pin) {
                          setState(() {
                            confirmPassword = pin;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Center(
                child: SizedBox(
                  width: 180,
                  child: MouseRegion(
                    onEnter: (_) => setState(() => isHovered = true),
                    onExit: (_) => setState(() => isHovered = false),
                    child: Obx(
                      () => ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          backgroundColor: isHovered
                              ? mainColor.withOpacity(0.9)
                              : mainColor,
                          shadowColor: Colors.black.withOpacity(0.4),
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: _authController.isLoading.value
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Verify',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                        onPressed: () {
                          if (newPassword == confirmPassword) {
                            _authController.changePassword(newPassword!);
                          } else {
                            Get.snackbar(
                              'Error',
                              'Passwords do not match',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 180),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account?',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.toNamed("/elogin");
                      },
                      child: Text(
                        'Login',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: mainColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
