import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:juan_million/screens/main_coordinator_home.dart';
import 'package:juan_million/screens/auth/coordinator_signup_screen.dart';
import 'package:juan_million/utlis/colors.dart';
import 'package:juan_million/widgets/button_widget.dart';
import 'package:juan_million/widgets/text_widget.dart';
import 'package:juan_million/widgets/textfield_widget.dart';
import 'package:juan_million/widgets/toast_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final username = TextEditingController();
  final password = TextEditingController();
  bool isHovering = false;

  Future<void> _sendPasswordReset(String value) async {
    final v = value.trim();
    if (v.isEmpty) {
      showToast('Please enter your username to reset password.');
      return;
    }

    final email = v.contains('@') ? v : '$v@coordinator.com';

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      showToast('Password reset email sent. Please check your inbox.');
    } on FirebaseAuthException catch (e) {
      showToast(e.message ?? 'Failed to send password reset email.');
    } catch (_) {
      showToast('Failed to send password reset email.');
    }
  }

  void _showForgotPasswordDialog() {
    final controller = TextEditingController(text: username.text.trim());
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Reset Password',
            style: TextStyle(fontFamily: 'Bold'),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFieldWidget(
                fontStyle: FontStyle.normal,
                hint: 'Username or email',
                borderColor: blue,
                radius: 12,
                width: 350,
                prefixIcon: Icons.email_outlined,
                isRequred: false,
                controller: controller,
                label: 'Username or email',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _sendPasswordReset(controller.text);
              },
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Determine if we're on web/desktop based on screen width
          bool isWeb = constraints.maxWidth > 600;

          // Calculate responsive dimensions
          double headerHeight = isWeb ? constraints.maxHeight * 0.35 : 225;
          double logoHeight = isWeb ? constraints.maxHeight * 0.25 : 200;
          double formWidth = isWeb ? 400 : 300;
          double titleFontSize = isWeb ? 38 : 32;
          double containerPadding = isWeb ? 40 : 20;
          double borderRadius = isWeb ? 200 : 150;

          return SingleChildScrollView(
            child: Column(
              children: [
                // Header with background image
                Container(
                  width: double.infinity,
                  height: headerHeight,
                  decoration: BoxDecoration(
                    image: const DecorationImage(
                      fit: BoxFit.cover,
                      image: AssetImage('assets/images/newbackground.png'),
                    ),
                    border: Border.all(color: blue, width: isWeb ? 12 : 10),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(borderRadius),
                      bottomRight: Radius.circular(borderRadius),
                    ),
                  ),
                ),

                // Main content container
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: containerPadding,
                    vertical: isWeb ? 40 : 20,
                  ),
                  child: Column(
                    children: [
                      // Logo
                      Image.asset(
                        'assets/images/Juan4All 2.png',
                        height: logoHeight,
                      ),

                      const SizedBox(height: 20),

                      // Title
                      TextWidget(
                        text: 'Hello Coordinator!',
                        fontSize: titleFontSize,
                        fontFamily: 'Bold',
                        color: primary,
                      ),

                      const SizedBox(height: 30),

                      // Login form container
                      Container(
                        width: isWeb ? formWidth + 40 : double.infinity,
                        padding: EdgeInsets.all(isWeb ? 30 : 20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFFFF),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF9E9E9E)
                                  .withValues(alpha: 0.1),
                              spreadRadius: 1,
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Username field
                            TextFieldWidget(
                              fontStyle: FontStyle.normal,
                              hint: 'Username',
                              borderColor: blue,
                              radius: 12,
                              width: formWidth,
                              prefixIcon: Icons.person_3_outlined,
                              isRequred: false,
                              controller: username,
                              label: 'Username',
                            ),

                            const SizedBox(height: 25),

                            // Password field
                            TextFieldWidget(
                              showEye: true,
                              isObscure: true,
                              fontStyle: FontStyle.normal,
                              hint: 'Password',
                              borderColor: blue,
                              radius: 12,
                              width: formWidth,
                              prefixIcon: Icons.lock_open_outlined,
                              isRequred: false,
                              controller: password,
                              label: 'Password',
                            ),

                            const SizedBox(height: 35),

                            // Login button with hover effect
                            MouseRegion(
                              onEnter: (_) => setState(() => isHovering = true),
                              onExit: (_) => setState(() => isHovering = false),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                child: ButtonWidget(
                                  width: formWidth,
                                  height: 55,
                                  fontSize: 20,
                                  radius: 12,
                                  label: 'Log in',
                                  color: isHovering && isWeb
                                      ? const Color(0xff0066CC)
                                      : blue,
                                  onPressed: () async {
                                    login(context);
                                  },
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _showForgotPasswordDialog,
                                child: TextWidget(
                                  text: 'Forgot password?',
                                  fontSize: isWeb ? 14 : 12,
                                  decoration: TextDecoration.underline,
                                  color: primary,
                                ),
                              ),
                            ),

                            // Uncomment this section if you want to add signup link
                            // SizedBox(height: isWeb ? 20 : 10),
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.center,
                            //   children: [
                            //     TextWidget(
                            //       text: 'Don't have an account yet?',
                            //       fontSize: isWeb ? 14 : 12,
                            //       color: blue,
                            //     ),
                            //     TextButton(
                            //       onPressed: () {
                            //         if (widget.inCustomer) {
                            //           Navigator.of(context).push(MaterialPageRoute(
                            //               builder: (context) => const CustomerSignupScreen()));
                            //         } else {
                            //           Navigator.of(context).push(MaterialPageRoute(
                            //               builder: (context) => const SignupScreen()));
                            //         }
                            //       },
                            //       child: TextWidget(
                            //         text: 'Create account',
                            //         fontSize: isWeb ? 16 : 14,
                            //         decoration: TextDecoration.underline,
                            //         color: primary,
                            //       ),
                            //     ),
                            //   ],
                            // ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextWidget(
                                  text:
                                      'Don\'t have a coordinator account yet?',
                                  fontSize: isWeb ? 14 : 12,
                                  color: blue,
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const CoordinatorSignupScreen(),
                                      ),
                                    );
                                  },
                                  child: TextWidget(
                                    text: 'Register',
                                    fontSize: isWeb ? 16 : 14,
                                    decoration: TextDecoration.underline,
                                    color: primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  login(context) async {
    try {
      final email = '${username.text}@coordinator.com';

      final userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password.text,
      );

      final uid = userCredential.user!.uid;

      final doc = await FirebaseFirestore.instance
          .collection('Coordinator')
          .doc(uid)
          .get();

      final data = doc.data();
      final isApproved = data != null && (data['approved'] == true);

      if (!isApproved) {
        await FirebaseAuth.instance.signOut();
        showToast('Your coordinator account is pending admin approval.');
        return;
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (context) => const MainCoordinatorHomeScreen()),
      );
    } on FirebaseAuthException {
      showToast('Invalid coordinator credentials!');
    } catch (_) {
      showToast("An error occurred during login");
    }
  }
}
