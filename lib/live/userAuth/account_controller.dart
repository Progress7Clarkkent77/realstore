import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:Textido/BlockChain/blockchain_controller.dart';
import 'package:Textido/CowriexController/e_login_controller.dart';
import 'package:Textido/earn/host_edit.dart';
import 'package:Textido/earn/seed_phrase.dart';

//import 'package:the_splendid_market/CowriexController/history_controller.dart';

class AccountController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController authController = Get.find<AuthController>();
  // Blockchain blockchain = Blockchain();

//RxString walletAddress = "".obs; // Define observable wallet address

  var publicKey = ''.obs;
  var walletAddress = ''.obs; // Observable wallet address
  var cowriexBalance = 0.0.obs;
  var userBalance = 0.0.obs;
  var isBalanceVisible = true.obs;
  var userName = 'Null'.obs;
  var userEmail = 'Null'.obs;
  RxDouble loadingProgress = 0.0.obs;
  RxInt dailyTapCount = 0.obs;
  DateTime? lastTapDate;
  var walletName = "Wallet".obs; // Default value
  var addressName = "Address".obs; // Default address name

  RxString fullWalletAddress = "".obs; // Full wallet address
  RxString fullPublicKey = "".obs; // Full public key
  RxString avatarName = ''.obs;

  static const int maxTaps = 100;

  Timer? _balanceTimer;

  // void startRealtimeBalance() {
  //   _balanceTimer?.cancel();
  //   _balanceTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
  //     await fetchBalances();
  //   });
  // }

  @override
  void onInit() {
    super.onInit();
    fetchWalletDetails();
    fetchWalletAddress(); // Fetch wallet address on initialization
    fetchWalletData(); // Fetch both address & publicKey on init
    fetchUserInfo(); // <- Add this

    // Real-time updates for user data
    final user = authController.currentUser;
    if (user != null) {
      _firestore
          .collection('e-users')
          .doc(user.uid)
          .snapshots()
          .listen((snapshot) {
        final data = snapshot.data();
        if (data != null) {
          userBalance.value = (data['acc_bal'] as num? ?? 0).toDouble();
          isBalanceVisible.value = data['is_balance_visible'] ?? true;

          // update name & email dynamically
          userName.value = data['name'] ?? user.displayName ?? "Unknown";
          userEmail.value = data['email'] ?? user.email ?? "Unknown";
        }
      });
    }
    // startRealtimeBalance(); // Start blockchain polling
  }

  @override
  void onClose() {
    _balanceTimer?.cancel();
    super.onClose();
  }

  Future<void> setAvatar(String avatarName) async {
    final user = authController.currentUser;
    if (user == null) return;

    await _firestore.collection('e-users').doc(user.uid).set({
      'avatar': avatarName,
    }, SetOptions(merge: true));

    this.avatarName.value = avatarName;
  }

  Future<void> fetchUserInfo() async {
    final user = authController.currentUser;
    if (user == null) return;

    try {
      final doc = await _firestore.collection('e-users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        userName.value = data['name'] ?? user.displayName ?? "Unknown";
        userEmail.value = data['email'] ?? user.email ?? "Unknown";
        // ✅ AVATAR
        avatarName.value = data['avatar'] ?? '';
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch user info");
    }
  }

  // Future<void> fetchBalances() async {
  //   try {
  //     final user = authController.currentUser;
  //     if (user != null) {
  //       final userDocRef = _firestore.collection('e-users').doc(user.uid);
  //       final userSnapshot = await userDocRef.get();

  //       if (userSnapshot.exists) {
  //         final data = userSnapshot.data()!;
  //         String walletAddress = data['wallet_address'] ?? '';

  //         if (walletAddress.isNotEmpty) {
  //         //  Blockchain blockchain = Blockchain();
  //           double walletBalance =
  //               (await blockchain.getWalletBalance(walletAddress)).toDouble();

  //           userBalance.value = walletBalance;

  //           // Ensure Firestore stores it as a double
  //           await userDocRef.update({'acc_bal': walletBalance.toDouble()});
  //         } else {
  //           userBalance.value = 0.0;
  //           await userDocRef.update({'acc_bal': 0.0});
  //         }
  //       }
  //     }
  //   } catch (e) {
  //     Get.snackbar("Poor Network", "Guy your area no get network");
  //   }
  // }

  Future<void> deleteAccount() async {
    final user = authController.currentUser;
    if (user == null) {
      Get.snackbar("Error", "No user is currently signed in.");
      return;
    }

    final String email = user.email ?? "";
    final TextEditingController passwordController = TextEditingController();

    Get.defaultDialog(
      title: "Confirm Password",
      titleStyle: TextStyle(
        color: Colors.black.withOpacity(0.69),
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
      content: Column(
        children: [
          Text(
            "For your security, please re-enter your password to permanently delete your account.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          SizedBox(height: 12),
          TextField(
            controller: passwordController,
            obscureText: true,
            maxLength: 8,
            decoration: InputDecoration(
              hintText: "Password",
              counterText: "",
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.black),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.black, width: 1),
              ),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.deny(RegExp(r"\s")),
            ],
          ),
          SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final String password = passwordController.text.trim();

              if (password.isEmpty) {
                Get.snackbar("Error", "Please enter your password");
                return;
              }

              // loading dialog
              Get.dialog(
                StatefulBuilder(
                  builder: (context, setState) {
                    final AnimationController _controller = AnimationController(
                      vsync: Navigator.of(context),
                      duration: Duration(seconds: 1),
                    )..repeat();

                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RotationTransition(
                            turns: _controller,
                            child: Image.asset(
                              'assets/images/Textido Logo.jpeg',
                              width: 50,
                              height: 50,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Deleting Account...",
                            style: TextStyle(
                              color: Colors.deepOrange,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                barrierDismissible: false,
              );

              try {
                // 1. Re-authenticate — required by Firebase before deletion
                final bool isValid =
                    await authController.verifyPassword(email, password);

                if (!isValid) {
                  Get.back(); // close loading
                  Get.snackbar("Error", "Incorrect password. Try again.");
                  return;
                }

                // 2. Delete Firestore user doc
                await _firestore.collection('e-users').doc(user.uid).delete();

                // 3. Delete the Firebase Auth account itself
                await user.delete();

                // Close loading + password dialogs
                Get.back();
                Get.back();

                Get.offAllNamed('/login');

                Get.snackbar("Account Deleted",
                    "Your account has been permanently deleted.");
              } on FirebaseAuthException catch (e) {
                Get.back(); // close loading
                if (e.code == 'requires-recent-login') {
                  Get.snackbar("Error",
                      "Please log in again before deleting your account.");
                } else {
                  Get.snackbar(
                      "Error", e.message ?? "Failed to delete account.");
                }
              } catch (e) {
                Get.back(); // close loading
                Get.snackbar(
                    "Error", "Something went wrong. Please try again.");
              }
            },
            child:
                Text("Confirm Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> fetchWalletData() async {
    try {
      final user = authController.currentUser;
      if (user != null) {
        String email = user.email ?? "";

        QuerySnapshot walletQuery = await _firestore
            .collection('wallets')
            .where('email', isEqualTo: email)
            .get();

        if (walletQuery.docs.isNotEmpty) {
          DocumentSnapshot walletDoc = walletQuery.docs.first;

          // Fetch and store wallet address
          String fullAddress = walletDoc['address'] ?? "No Address Found";
          fullWalletAddress.value = fullAddress;
          walletAddress.value = formatString(fullAddress);

          // Fetch and store public key
          String fullPubKey = walletDoc['publicKey'] ?? "No Public Key Found";
          fullPublicKey.value = fullPubKey;
          publicKey.value = formatString(fullPubKey);
        }
      }
    } catch (e) {
      //  print("Error fetching wallet details: $e");
    }
  }

  // Function to format the address or public key (e.g., 43ff2d...acf2)
  String formatString(String value) {
    if (value.length > 10) {
      return "${value.substring(0, 6)}...${value.substring(value.length - 4)}";
    }
    return value;
  }

  Future<void> fetchWalletAddress() async {
    try {
      final user = authController.currentUser;
      if (user != null) {
        String email = user.email ?? "";

        QuerySnapshot walletQuery = await _firestore
            .collection('wallets')
            .where('email', isEqualTo: email)
            .get();

        if (walletQuery.docs.isNotEmpty) {
          DocumentSnapshot walletDoc = walletQuery.docs.first;
          String fullAddress = walletDoc['address'] ?? "No Address Found";

          // Format address
          if (fullAddress.length > 10) {
            walletAddress.value =
                "${fullAddress.substring(0, 6)}...${fullAddress.substring(fullAddress.length - 4)}";
          } else {
            walletAddress.value = fullAddress; // Show full if too short
          }
        }
      }
    } catch (e) {
      //   print("Error fetching wallet address: $e");
    }
  }

  /// Fetch wallet name and address name by finding the document where email matches the current user
  Future<void> fetchWalletDetails() async {
    try {
      final user = authController.currentUser;
      if (user != null) {
        String email = user.email ?? "";

        QuerySnapshot walletQuery = await _firestore
            .collection('wallets')
            .where('email', isEqualTo: email)
            .get();

        if (walletQuery.docs.isNotEmpty) {
          DocumentSnapshot walletDoc = walletQuery.docs.first;
          walletName.value = walletDoc['walletName'] ?? "Wallet";
          addressName.value = walletDoc['addressName'] ?? "Address";
        }
      }
    } catch (e) {
      //   print("Error fetching wallet details: $e");
    }
  }

  /// Update the address name in Firestore
  Future<void> updateAddressName(String newAddressName) async {
    try {
      final user = authController.currentUser;
      if (user != null) {
        String email = user.email ?? "";

        QuerySnapshot walletQuery = await _firestore
            .collection('wallets')
            .where('email', isEqualTo: email)
            .get();

        if (walletQuery.docs.isNotEmpty) {
          DocumentSnapshot walletDoc = walletQuery.docs.first;
          await _firestore.collection('wallets').doc(walletDoc.id).update({
            'addressName': newAddressName,
          });

          addressName.value = newAddressName; // Update UI dynamically
          Get.snackbar("Success", "Address name updated successfully!");
        } else {
          Get.snackbar("Error", "Wallet not found for this user.");
        }
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to update address name");
    }
  }

  /// Update the wallet name in Firestore under the found wallet document
  Future<void> updateWalletName(String newWalletName) async {
    try {
      final user = authController.currentUser;
      if (user != null) {
        String email = user.email ?? "";

        QuerySnapshot walletQuery = await _firestore
            .collection('wallets')
            .where('email', isEqualTo: email)
            .get();

        if (walletQuery.docs.isNotEmpty) {
          DocumentSnapshot walletDoc = walletQuery.docs.first;
          await _firestore.collection('wallets').doc(walletDoc.id).update({
            'walletName': newWalletName,
          });

          walletName.value = newWalletName; // Update UI dynamically
          Get.snackbar("Success", "Wallet name updated successfully!");
        } else {
          Get.snackbar("Error", "Wallet not found for this user.");
        }
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to update wallet name");
    }
  }

  /// Check if all daily tasks are completed
  Future<bool> areAllDailyTasksCompleted() async {
    try {
      final user = authController.currentUser;
      if (user != null) {
        final userDoc =
            await _firestore.collection('e-users').doc(user.uid).get();

        if (userDoc.exists) {
          final taskData = userDoc.data()?['tasks'] ?? {};
          final dailyTasks = [
            "Survey this Products for 3min",
            "Survey this Services for 3min",
            "Survey this Agents for 3min",
            "Read The Word for 4min"
          ];

          // Check if all daily tasks are marked as true
          for (var task in dailyTasks) {
            if (taskData[task] != true) {
              return false; // At least one task is incomplete
            }
          }

          // Check if the last daily reset was yesterday
          final lastDailyResetDate = userDoc.data()?['last_daily_reset_date'];
          if (lastDailyResetDate != null) {
            final lastResetDate = (lastDailyResetDate as Timestamp).toDate();
            final currentDate = DateTime.now();
            if (currentDate.day != lastResetDate.day &&
                currentDate.year == lastResetDate.year &&
                currentDate.month == lastResetDate.month) {
              return false; // If the last reset was yesterday, treat as incomplete
            }
          }

          return true; // All tasks are completed
        }
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to check task statuses: $e");
    }
    return false; // Default to false if any error occurs
  }

  /// Toggle balance visibility and update Firestore
  void toggleBalanceVisibility() async {
    final user = authController.currentUser;
    if (user != null) {
      isBalanceVisible.value = !isBalanceVisible.value;
      try {
        await _firestore
            .collection('e-users')
            .doc(user.uid)
            .update({'is_balance_visible': isBalanceVisible.value});
      } catch (e) {
        Get.snackbar("Error", "Failed to update balance visibility");
      }
    }
  }

  Future<void> verifyAndNavigate() async {
    TextEditingController passwordController = TextEditingController();

    Get.defaultDialog(
      title: "Enter Password",
      titleStyle: TextStyle(
        color: Colors.black.withOpacity(0.69),
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
      content: Column(
        children: [
          TextField(
            controller: passwordController,
            obscureText: true,
            maxLength: 8, // Limit password input to 8 characters
            decoration: InputDecoration(
              hintText: "Password",
              counterText: "", // Hide character counter
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.black), // Black border
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                    color: Colors.black,
                    width: 1), // Thicker black border when focused
              ),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.deny(RegExp(r"\s")), // Disable spaces
            ],
          ),
          SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black, // Button color
            ),
            onPressed: () async {
              String password = passwordController.text.trim();
              String email = authController.currentUser?.email ?? "";

              if (password.isEmpty) {
                Get.snackbar("Error", "Please enter your password");
                return;
              }

              // Show loading dialog
              // Get.dialog(
              //   Center(
              //     child: CircularProgressIndicator(
              //       color: Colors.black,
              //     ),
              //   ),
              //   barrierDismissible: false, // Prevent dismissing during loading
              // );

              Get.dialog(
                StatefulBuilder(
                  builder: (context, setState) {
                    final AnimationController _controller = AnimationController(
                      vsync: Navigator.of(context),
                      duration: Duration(seconds: 1),
                    )..repeat();

                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RotationTransition(
                            turns: _controller,
                            child: Image.asset(
                              'assets/images/progress_logo.png', // Replace with your image path
                              width: 50,
                              height: 50,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Verifying Password...",
                            style: TextStyle(
                              color: Colors.deepOrange,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                barrierDismissible: false,
              );

              bool isValid =
                  await authController.verifyPassword(email, password);

              // Simulate a 4-second delay before navigation
              await Future.delayed(Duration(seconds: 4));

              // Close loading dialog
              Get.back();

              if (isValid) {
                Get.back(); // Close dialog
                Get.toNamed('/walletaddress'); // Navigate only if correct
              } else {
                Get.snackbar("Error", "Incorrect Password. Try again.");
              }
            },
            child: Text(
              "Confirm",
              style: TextStyle(
                color: Colors.white, // Text color
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> verifyAndNavigate1() async {
    TextEditingController passwordController = TextEditingController();

    Get.defaultDialog(
      title: "Enter Password",
      titleStyle: TextStyle(
        color: Colors.black.withOpacity(0.69),
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
      content: Column(
        children: [
          TextField(
            controller: passwordController,
            obscureText: true,
            maxLength: 8, // Limit password input to 8 characters
            decoration: InputDecoration(
              hintText: "Password",
              counterText: "", // Hide character counter
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.black), // Black border
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                    color: Colors.black,
                    width: 1), // Thicker black border when focused
              ),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.deny(RegExp(r"\s")), // Disable spaces
            ],
          ),
          SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black, // Button color
            ),
            onPressed: () async {
              String password = passwordController.text.trim();
              String email = authController.currentUser?.email ?? "";

              if (password.isEmpty) {
                Get.snackbar("Error", "Please enter your password");
                return;
              }

              // Show loading dialog
              // Get.dialog(
              //   Center(
              //     child: CircularProgressIndicator(
              //       color: Colors.black,
              //     ),
              //   ),
              //   barrierDismissible: false, // Prevent dismissing during loading
              // );

              Get.dialog(
                StatefulBuilder(
                  builder: (context, setState) {
                    final AnimationController _controller = AnimationController(
                      vsync: Navigator.of(context),
                      duration: Duration(seconds: 1),
                    )..repeat();

                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RotationTransition(
                            turns: _controller,
                            child: Image.asset(
                              'assets/images/progress_logo.png', // Replace with your image path
                              width: 50,
                              height: 50,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Verifying Password...",
                            style: TextStyle(
                              color: Colors.deepOrange,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                barrierDismissible: false,
              );

              bool isValid =
                  await authController.verifyPassword(email, password);

              // Simulate a 4-second delay before navigation
              await Future.delayed(Duration(seconds: 4));

              // Close loading dialog
              Get.back();

              if (isValid) {
                Get.back(); // Close dialog
                Get.toNamed('/publickey'); // Navigate only if correct
              } else {
                Get.snackbar("Error", "Incorrect Password. Try again.");
              }
            },
            child: Text(
              "Confirm",
              style: TextStyle(
                color: Colors.white, // Text color
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Future<void> verifyAndNavigate2() async {
  //   TextEditingController passwordController = TextEditingController();

  //   Get.defaultDialog(
  //     title: "Enter Password",
  //     titleStyle: TextStyle(
  //       color: Colors.black.withOpacity(0.69),
  //       fontSize: 14,
  //       fontWeight: FontWeight.bold,
  //     ),
  //     content: Column(
  //       children: [
  //         TextField(
  //           controller: passwordController,
  //           obscureText: true,
  //           maxLength: 8, // Limit password input to 8 characters
  //           decoration: InputDecoration(
  //             hintText: "Password",
  //             counterText: "", // Hide character counter
  //             enabledBorder: OutlineInputBorder(
  //               borderRadius: BorderRadius.circular(10),
  //               borderSide: BorderSide(color: Colors.black), // Black border
  //             ),
  //             focusedBorder: OutlineInputBorder(
  //               borderRadius: BorderRadius.circular(10),
  //               borderSide: BorderSide(
  //                   color: Colors.black,
  //                   width: 1), // Thicker black border when focused
  //             ),
  //           ),
  //           inputFormatters: [
  //             FilteringTextInputFormatter.deny(RegExp(r"\s")), // Disable spaces
  //           ],
  //         ),
  //         SizedBox(height: 10),
  //         ElevatedButton(
  //           style: ElevatedButton.styleFrom(
  //             backgroundColor: Colors.black, // Button color
  //           ),
  //           onPressed: () async {
  //             String password = passwordController.text.trim();
  //             String email = authController.currentUser?.email ?? "";

  //             if (password.isEmpty) {
  //               Get.snackbar("Error", "Please enter your password");
  //               return;
  //             }

  //             // Show loading dialog
  //             // Get.dialog(
  //             //   Center(
  //             //     child: CircularProgressIndicator(
  //             //       color: Colors.black,
  //             //     ),
  //             //   ),
  //             //   barrierDismissible: false, // Prevent dismissing during loading
  //             // );

  //             Get.dialog(
  //               StatefulBuilder(
  //                 builder: (context, setState) {
  //                   final AnimationController _controller = AnimationController(
  //                     vsync: Navigator.of(context),
  //                     duration: Duration(seconds: 1),
  //                   )..repeat();

  //                   return Center(
  //                     child: Column(
  //                       mainAxisSize: MainAxisSize.min,
  //                       children: [
  //                         RotationTransition(
  //                           turns: _controller,
  //                           child: Image.asset(
  //                             'assets/images/progress_logo.png', // Replace with your image path
  //                             width: 50,
  //                             height: 50,
  //                           ),
  //                         ),
  //                         SizedBox(height: 10),
  //                         Text(
  //                           "Verifying Password...",
  //                           style: TextStyle(
  //                             color: Colors.deepOrange,
  //                             fontSize: 12,
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   );
  //                 },
  //               ),
  //               barrierDismissible: false,
  //             );

  //             bool isValid =
  //                 await authController.verifyPassword(email, password);

  //             if (isValid) {
  //               // Fetch the wallet from Firestore
  //               DocumentSnapshot walletDoc = await FirebaseFirestore.instance
  //                   .collection('wallets')
  //                   .where('email', isEqualTo: email)
  //                   .limit(1)
  //                   .get()
  //                   .then((snapshot) => snapshot.docs.first);

  //               if (walletDoc.exists) {
  //                 String mnemonic = walletDoc['mnemonic'];

  //                 // Close loading dialog and navigate
  //                 Get.back(); // Close loading dialog
  //                 Get.back(); // Close password dialog
  //               //  Get.to(() => SeedPhrase(mnemonic: mnemonic));
  //               } else {
  //                 Get.back(); // Close loading dialog
  //                 Get.snackbar("Error", "Wallet not found.");
  //               }
  //             } else {
  //               Get.back(); // Close loading dialog
  //               Get.snackbar("Error", "Incorrect Password. Try again.");
  //             }
  //           },
  //           child: Text(
  //             "Confirm",
  //             style: TextStyle(
  //               color: Colors.white, // Text color
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Future<void> verifyAndNavigate4() async {
    TextEditingController passwordController = TextEditingController();

    Get.defaultDialog(
      title: "Enter Password",
      titleStyle: TextStyle(
        color: Colors.black.withOpacity(0.69),
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
      content: Column(
        children: [
          TextField(
            controller: passwordController,
            obscureText: true,
            maxLength: 8, // Limit password input to 8 characters
            decoration: InputDecoration(
              hintText: "Password",
              counterText: "", // Hide character counter
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.black), // Black border
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                    color: Colors.black,
                    width: 1), // Thicker black border when focused
              ),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.deny(RegExp(r"\s")), // Disable spaces
            ],
          ),
          SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black, // Button color
            ),
            onPressed: () async {
              String password = passwordController.text.trim();
              String email = authController.currentUser?.email ?? "";

              if (password.isEmpty) {
                Get.snackbar("Error", "Please enter your password");
                return;
              }

              // Show loading dialog
              // Get.dialog(
              //   Center(
              //     child: CircularProgressIndicator(
              //       color: Colors.black,
              //     ),
              //   ),
              //   barrierDismissible: false, // Prevent dismissing during loading
              // );

              Get.dialog(
                StatefulBuilder(
                  builder: (context, setState) {
                    final AnimationController _controller = AnimationController(
                      vsync: Navigator.of(context),
                      duration: Duration(seconds: 1),
                    )..repeat();

                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RotationTransition(
                            turns: _controller,
                            child: Image.asset(
                              'assets/images/progress_logo.png', // Replace with your image path
                              width: 50,
                              height: 50,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Verifying Password...",
                            style: TextStyle(
                              color: Colors.deepOrange,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                barrierDismissible: false,
              );

              bool isValid =
                  await authController.verifyPassword(email, password);

              // Simulate a 4-second delay before navigation
              await Future.delayed(Duration(seconds: 4));

              // Close loading dialog
              Get.back();

              if (isValid) {
                Get.back(); // Close dialog
                Get.toNamed('/publickey'); // Navigate only if correct
              } else {
                Get.snackbar("Error", "Incorrect Password. Try again.");
              }
            },
            child: Text(
              "Confirm",
              style: TextStyle(
                color: Colors.white, // Text color
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> verifyAndNavigate3(String hostAddress) async {
    TextEditingController publicKeyController = TextEditingController();

    Get.defaultDialog(
      title: "Enter Public Key",
      titleStyle: TextStyle(
        color: Colors.black.withOpacity(0.69),
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
      content: Column(
        children: [
          TextField(
            controller: publicKeyController,
            decoration: InputDecoration(
              hintText: "Public Key",
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.black),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.black, width: 1),
              ),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.deny(RegExp(r"\s")), // No spaces
            ],
          ),
          SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
            onPressed: () async {
              String publicKey = publicKeyController.text.trim();

              if (publicKey.isEmpty) {
                _showAlertDialog(
                    "Error", "Please enter a public key", Colors.red);
                return;
              }

              // Show loading dialog
              // Get.dialog(
              //   Center(child: CircularProgressIndicator(color: Colors.black)),
              //   barrierDismissible: false,
              // );

              Get.dialog(
                StatefulBuilder(
                  builder: (context, setState) {
                    final AnimationController _controller = AnimationController(
                      vsync: Navigator.of(context),
                      duration: Duration(seconds: 1),
                    )..repeat();

                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RotationTransition(
                            turns: _controller,
                            child: Image.asset(
                              'assets/images/progress_logo.png', // Replace with your image path
                              width: 50,
                              height: 50,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Verifying Key...",
                            style: TextStyle(
                              color: Colors.deepOrange,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                barrierDismissible: false,
              );

              try {
                // Fetch user with this public key
                var userQuery = await FirebaseFirestore.instance
                    .collection('e-users')
                    .where('public_key', isEqualTo: publicKey)
                    .limit(1)
                    .get();

                if (userQuery.docs.isNotEmpty) {
                  var userData = userQuery.docs.first.data();
                  String userAddress = userData["wallet_address"];

                  if (userAddress == hostAddress) {
                    // Fetch host details from Firestore
                    var hostQuery = await FirebaseFirestore.instance
                        .collection('HostPxp')
                        .where('owner', isEqualTo: hostAddress)
                        .limit(1)
                        .get();

                    if (hostQuery.docs.isNotEmpty) {
                      var hostDetails = hostQuery.docs.first.data();

                      Get.back(); // Close loading
                      Get.back(); // Close dialog
                      // Get.to(() => HostEdit(exchangeDetails: hostDetails));
                    } else {
                      Get.back();
                      _showAlertDialog(
                          "Error", "Host details not found.", Colors.red);
                    }
                  } else {
                    Get.back();
                    _showAlertDialog("Error",
                        "Public key does not match host address.", Colors.red);
                  }
                } else {
                  Get.back();
                  _showAlertDialog("Error", "Invalid public key.", Colors.red);
                }
              } catch (e) {
                Get.back();
                _showAlertDialog("Error", "An error occurred: $e", Colors.red);
              }
            },
            child: Text("Confirm", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

/// Show alert dialog instead of Snackbar
void _showAlertDialog(String title, String message, Color color) {
  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              title == "Success" ? Icons.check_circle : Icons.error,
              color: color,
              size: 50,
            ),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => Get.back(),
              child: Text("OK", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    ),
    barrierDismissible: false, // User must tap OK to dismiss
  );
}
