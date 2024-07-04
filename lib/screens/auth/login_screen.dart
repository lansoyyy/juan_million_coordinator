import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:juan_million/screens/admin_home.dart';
import 'package:juan_million/screens/auth/customer_signup_screen.dart';
import 'package:juan_million/screens/auth/signup_screen.dart';
import 'package:juan_million/screens/business_home_screen.dart';
import 'package:juan_million/screens/customer_home_screen.dart';
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 225,
              decoration: BoxDecoration(
                image: const DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage(
                    'assets/images/newbackground.png',
                  ),
                ),
                border: Border.all(color: blue, width: 10),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(
                    150,
                  ),
                  bottomRight: Radius.circular(
                    150,
                  ),
                ),
              ),
            ),
            Image.asset(
              'assets/images/Juan4All 2.png',
              height: 200,
            ),
            TextWidget(
              text: 'Hello Admin!',
              fontSize: 32,
              fontFamily: 'Bold',
              color: primary,
            ),
            const SizedBox(
              height: 10,
            ),
            TextFieldWidget(
              fontStyle: FontStyle.normal,
              hint: 'Email',
              borderColor: blue,
              radius: 12,
              width: 300,
              prefixIcon: Icons.person_3_outlined,
              isRequred: false,
              controller: username,
              label: 'Email',
            ),
            const SizedBox(
              height: 20,
            ),
            TextFieldWidget(
              showEye: true,
              isObscure: true,
              fontStyle: FontStyle.normal,
              hint: 'Password',
              borderColor: blue,
              radius: 12,
              width: 300,
              prefixIcon: Icons.lock_open_outlined,
              isRequred: false,
              controller: password,
              label: 'Password',
            ),

            const SizedBox(
              height: 30,
            ),
            ButtonWidget(
              width: 300,
              label: 'Log in',
              onPressed: () {
                if (username.text == 'admin@juan4all.com' &&
                    password.text == 'juan4all') {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => const AdminHome()));
                } else {
                  showToast('Invalid admin credentials!');
                }
              },
            ),
            // const SizedBox(
            //   height: 10,
            // ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     TextWidget(
            //       text: 'Don’t have an account yet?',
            //       fontSize: 12,
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
            //         fontSize: 14,
            //         decoration: TextDecoration.underline,
            //         color: primary,
            //       ),
            //     ),
            //   ],
            // ),
            const SizedBox(
              height: 50,
            ),
          ],
        ),
      ),
    );
  }
}
