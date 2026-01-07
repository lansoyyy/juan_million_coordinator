import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner_plus/flutter_barcode_scanner_plus.dart';
import 'package:juan_million/utlis/colors.dart';
import 'package:juan_million/widgets/text_widget.dart';
import 'package:qr_flutter/qr_flutter.dart';

class MyQRPage extends StatefulWidget {
  const MyQRPage({super.key});

  @override
  State<MyQRPage> createState() => _MyQRPageState();
}

class _MyQRPageState extends State<MyQRPage> {
  bool _showBalance = false;

  @override
  Widget build(BuildContext context) {
    final Stream<DocumentSnapshot> userData = FirebaseFirestore.instance
        .collection('Coordinator')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots();
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
          stream: userData,
          builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: Text('Loading'));
            } else if (snapshot.hasError) {
              return const Center(child: Text('Something went wrong'));
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final doc = snapshot.data;
            final data = doc?.data() as Map<String, dynamic>?;
            if (doc == null || data == null) {
              return const Center(child: Text('Coordinator profile not found'));
            }
            final name = (data['name'] ?? '').toString();
            final wallet = (data['wallet'] is num)
                ? (data['wallet'] as num).toInt()
                : int.tryParse((data['wallet'] ?? '0').toString()) ?? 0;
            return Column(
              children: [
                Container(
                  height: 500,
                  decoration: BoxDecoration(
                    color: blue,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(50),
                      bottomRight: Radius.circular(50),
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(
                                Icons.arrow_back_ios_rounded,
                                color: Colors.white,
                              )),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Center(
                          child: TextWidget(
                            text: name,
                            fontSize: 18,
                            color: Colors.white,
                            fontFamily: 'Bold',
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Center(
                          child: Container(
                            width: 250,
                            height: 250,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                15,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: QrImageView(data: doc.id),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _showBalance = !_showBalance;
                              });
                            },
                            child: Column(
                              children: [
                                TextWidget(
                                  text: _showBalance
                                      ? 'P${wallet.toString()}.00'
                                      : 'P••••.00',
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontFamily: 'Bold',
                                ),
                                TextWidget(
                                  text: _showBalance
                                      ? 'Tap to hide'
                                      : 'Wallet Balance (tap to reveal)',
                                  fontSize: 9,
                                  color: Colors.white,
                                  fontFamily: 'Medium',
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Image.asset(
                  'assets/images/Juan4All 2.png',
                  height: 150,
                ),
              ],
            );
          }),
    );
  }

  String qrCode = 'Unknown';
  String store = '';
  String pts = '';

  Future<void> scanQRCode() async {
    try {
      final qrCode = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666',
        'Cancel',
        true,
        ScanMode.QR,
      );

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
              ],
            ),
          );
        },
      );

      if (!mounted) return;

      setState(() {
        this.qrCode = qrCode;
      });

      await FirebaseFirestore.instance
          .collection('Users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        'pts': FieldValue.increment(int.parse(qrCode)),
      }).whenComplete(() {
        // Add transaction
        Navigator.pop(context);
      });
    } on PlatformException {
      qrCode = 'Failed to get platform version.';
    }
  }
}
