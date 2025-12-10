import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner_plus/flutter_barcode_scanner_plus.dart';
import 'package:intl/intl.dart';
import 'package:juan_million/services/add_wallet.dart';
import 'package:juan_million/utlis/app_constants.dart';
import 'package:juan_million/utlis/colors.dart';
import 'package:juan_million/widgets/text_widget.dart';
import 'package:juan_million/widgets/toast_widget.dart';

class CoordinatorWallet extends StatefulWidget {
  const CoordinatorWallet({super.key});

  @override
  State<CoordinatorWallet> createState() => _CoordinatorWalletState();
}

class _CoordinatorWalletState extends State<CoordinatorWallet> {
  final pts = TextEditingController();
  String selected = '';
  bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    final Stream<DocumentSnapshot> userData = FirebaseFirestore.instance
        .collection('Coordinator')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWeb = constraints.maxWidth > 800;
          double horizontalPadding = isWeb ? 40.0 : 20.0;
          double cardWidth =
              isWeb ? constraints.maxWidth * 0.8 : double.infinity;

          return StreamBuilder<DocumentSnapshot>(
            stream: userData,
            builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: primary),
                      const SizedBox(height: 20),
                      TextWidget(
                        text: 'Loading...',
                        fontSize: 18,
                        color: grey,
                      ),
                    ],
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 64, color: Colors.red[400]),
                      const SizedBox(height: 20),
                      TextWidget(
                        text: 'Something went wrong',
                        fontSize: 18,
                        color: Colors.red[400],
                      ),
                    ],
                  ),
                );
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(color: primary),
                );
              }

              final docSnapshot = snapshot.data;
              final docData = docSnapshot?.data() as Map<String, dynamic>?;

              if (docData == null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.account_circle,
                          size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 20),
                      TextWidget(
                        text: 'Coordinator profile not found',
                        fontSize: 18,
                        color: grey,
                      ),
                    ],
                  ),
                );
              }

              final data = docData;

              return CustomScrollView(
                slivers: [
                  // Wallet Header Section
                  SliverToBoxAdapter(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: 30,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            primary,
                            primary.withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Wallet Title
                          TextWidget(
                            text: 'My Wallet',
                            fontSize: isWeb ? 20 : 18,
                            color: Colors.white,
                            fontFamily: 'Medium',
                          ),

                          const SizedBox(height: 20),

                          // Balance Display
                          Container(
                            padding: EdgeInsets.all(isWeb ? 30 : 25),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                TextWidget(
                                  text: 'Available Balance',
                                  fontSize: isWeb ? 16 : 14,
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontFamily: 'Regular',
                                ),
                                const SizedBox(height: 10),
                                TextWidget(
                                  text: AppConstants.formatNumberWithPeso(
                                      (data['wallet'] is num)
                                          ? (data['wallet'] as num).toInt()
                                          : 0),
                                  fontSize: isWeb ? 48 : 42,
                                  fontFamily: 'Bold',
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 30),

                          // Transfer Button
                          MouseRegion(
                            onEnter: (_) => setState(() => isHovering = true),
                            onExit: (_) => setState(() => isHovering = false),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    selected = 'Business';
                                  });
                                  showAmountDialog();
                                },
                                icon: const Icon(Icons.sync_alt,
                                    color: Colors.white),
                                label: TextWidget(
                                  text: 'Transfer to Affiliate',
                                  fontSize: isWeb ? 16 : 14,
                                  color: Colors.white,
                                  fontFamily: 'Medium',
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Colors.white.withValues(alpha: 0.2),
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isWeb ? 30 : 25,
                                    vertical: isWeb ? 15 : 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    side: BorderSide(
                                      color:
                                          Colors.white.withValues(alpha: 0.5),
                                      width: 1,
                                    ),
                                  ),
                                  elevation: isHovering && isWeb ? 8 : 4,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),

                  // Transactions Section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: horizontalPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 30),
                          Row(
                            children: [
                              Icon(Icons.history, color: primary, size: 28),
                              const SizedBox(width: 10),
                              TextWidget(
                                text: 'Transaction History',
                                fontSize: isWeb ? 24 : 20,
                                fontFamily: 'Bold',
                                color: primary,
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),

                  // Transaction List
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('Wallets')
                        .orderBy('dateTime', descending: true)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError) {
                        return SliverToBoxAdapter(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 50),
                              child: Column(
                                children: [
                                  Icon(Icons.error_outline,
                                      size: 64, color: Colors.red[400]),
                                  const SizedBox(height: 20),
                                  TextWidget(
                                    text: 'Error loading transactions',
                                    fontSize: 18,
                                    color: Colors.red[400],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 50),
                            child: Center(
                              child: CircularProgressIndicator(color: primary),
                            ),
                          ),
                        );
                      }

                      final data = snapshot.requireData;
                      final filteredData = data.docs
                          .where((doc) =>
                              doc['uid'] ==
                                  FirebaseAuth.instance.currentUser!.uid ||
                              doc['from'] ==
                                  FirebaseAuth.instance.currentUser!.uid)
                          .toList();

                      if (filteredData.isEmpty) {
                        return SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 50),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(Icons.receipt_long,
                                      size: 64, color: grey),
                                  const SizedBox(height: 20),
                                  TextWidget(
                                    text: 'No transactions found',
                                    fontSize: 18,
                                    color: grey,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      return SliverPadding(
                        padding:
                            EdgeInsets.symmetric(horizontal: horizontalPadding),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                margin: const EdgeInsets.only(bottom: 15),
                                child: Container(
                                  width: cardWidth,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(isWeb ? 20 : 15),
                                    child: Row(
                                      children: [
                                        // Transaction Icon
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color:
                                                filteredData[index]['pts'] > 0
                                                    ? Colors.green
                                                        .withValues(alpha: 0.1)
                                                    : Colors.red
                                                        .withValues(alpha: 0.1),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Icon(
                                            filteredData[index]['pts'] > 0
                                                ? Icons.arrow_downward
                                                : Icons.arrow_upward,
                                            color:
                                                filteredData[index]['pts'] > 0
                                                    ? Colors.green
                                                    : Colors.red,
                                            size: isWeb ? 24 : 20,
                                          ),
                                        ),

                                        const SizedBox(width: 15),

                                        // Transaction Details
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              TextWidget(
                                                text: filteredData[index]
                                                        ['type'] ??
                                                    'Transaction',
                                                fontSize: isWeb ? 16 : 14,
                                                fontFamily: 'Medium',
                                                color: Colors.black87,
                                              ),
                                              const SizedBox(height: 5),
                                              TextWidget(
                                                text: DateFormat.yMMMd()
                                                    .add_jm()
                                                    .format(filteredData[index]
                                                            ['dateTime']
                                                        .toDate()),
                                                fontSize: isWeb ? 12 : 10,
                                                color: grey,
                                                fontFamily: 'Regular',
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Amount
                                        TextWidget(
                                          text:
                                              '${filteredData[index]['pts'] > 0 ? '+' : ''}${AppConstants.formatNumberWithPeso(filteredData[index]['pts'].abs())}',
                                          fontSize: isWeb ? 18 : 16,
                                          fontFamily: 'Bold',
                                          color: filteredData[index]['pts'] > 0
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                            childCount: filteredData.length,
                          ),
                        ),
                      );
                    },
                  ),

                  // Bottom padding
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 30),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  showAmountDialog() {
    bool isWeb = MediaQuery.of(context).size.width > 800;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: isWeb ? 450 : null,
          padding: EdgeInsets.all(isWeb ? 30 : 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextWidget(
                    text: 'Transfer Funds',
                    fontSize: isWeb ? 22 : 20,
                    fontFamily: 'Bold',
                    color: primary,
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close, color: grey),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Amount Input
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget(
                      text: 'Enter Amount',
                      fontSize: isWeb ? 16 : 14,
                      color: grey,
                      fontFamily: 'Medium',
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: pts,
                      keyboardType: TextInputType.number,
                      style: TextStyle(
                        fontSize: isWeb ? 24 : 20,
                        fontFamily: 'Bold',
                        color: primary,
                      ),
                      decoration: InputDecoration(
                        prefixText: '₱',
                        prefixStyle: TextStyle(
                          fontSize: isWeb ? 24 : 20,
                          fontFamily: 'Bold',
                          color: primary,
                        ),
                        hintText: '0.00',
                        hintStyle: TextStyle(
                          fontSize: isWeb ? 24 : 20,
                          fontFamily: 'Bold',
                          color: Colors.grey[400],
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // Information Note
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: primary, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextWidget(
                        text:
                            'You will need to scan the affiliate\'s QR code after entering the amount',
                        fontSize: isWeb ? 14 : 12,
                        color: primary,
                        fontFamily: 'Regular',
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(vertical: isWeb ? 15 : 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: primary),
                      ),
                      child: TextWidget(
                        text: 'Cancel',
                        fontSize: isWeb ? 16 : 14,
                        color: primary,
                        fontFamily: 'Medium',
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (pts.text.isNotEmpty) {
                          scanQRCode();
                          Navigator.of(context).pop();
                        } else {
                          showToast('Please enter an amount');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        padding:
                            EdgeInsets.symmetric(vertical: isWeb ? 15 : 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: TextWidget(
                        text: 'Continue to QR Scan',
                        fontSize: isWeb ? 16 : 14,
                        color: Colors.white,
                        fontFamily: 'Medium',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String qrCode = 'Unknown';

  Future<void> scanQRCode() async {
    try {
      final qrCode = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666',
        'Cancel',
        true,
        ScanMode.QR,
      );

      if (!context.mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: primary),
                  const SizedBox(height: 20),
                  TextWidget(
                    text: 'Processing transfer...',
                    fontSize: 18,
                    fontFamily: 'Medium',
                    color: primary,
                  ),
                  const SizedBox(height: 10),
                  TextWidget(
                    text: 'Please wait while we process your transaction',
                    fontSize: 14,
                    color: grey,
                    fontFamily: 'Regular',
                  ),
                ],
              ),
            ),
          );
        },
      );

      if (!mounted) return;

      setState(() {
        this.qrCode = qrCode;
      });

      final DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('Coordinator')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      if (!context.mounted) return;

      if (documentSnapshot['wallet'] > int.parse(pts.text)) {
        await FirebaseFirestore.instance
            .collection(selected)
            .doc(qrCode)
            .update({
          'wallet': FieldValue.increment(int.parse(pts.text)),
        });
        await FirebaseFirestore.instance
            .collection('Coordinator')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({
          'wallet': FieldValue.increment(-int.parse(pts.text)),
        });

        // Add transaction
        addWallet(int.parse(pts.text), qrCode,
            FirebaseAuth.instance.currentUser!.uid, 'Receive & Transfers', '');

        // Close loading dialog
        Navigator.of(context).pop();

        // Show success dialog
        if (!context.mounted) return;

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle,
                        color: Color(0xFF4CAF50), size: 50),
                  ),
                  const SizedBox(height: 20),
                  TextWidget(
                    text: 'Transfer Successful!',
                    fontSize: 20,
                    fontFamily: 'Bold',
                    color: primary,
                  ),
                  const SizedBox(height: 10),
                  TextWidget(
                    text:
                        'You have successfully transferred ${AppConstants.formatNumberWithPeso(int.parse(pts.text))}',
                    fontSize: 16,
                    color: grey,
                    fontFamily: 'Regular',
                    align: TextAlign.center,
                  ),
                  const SizedBox(height: 25),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: TextWidget(
                      text: 'Done',
                      fontSize: 16,
                      color: Colors.white,
                      fontFamily: 'Medium',
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      } else {
        if (context.mounted) {
          Navigator.of(context).pop(); // Close loading dialog
        }
        showToast('Your wallet balance is not enough!');
      }
    } on PlatformException {
      qrCode = 'Failed to get platform version.';
    }
  }
}
