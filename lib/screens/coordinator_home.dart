import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show toBeginningOfSentenceCase;
import 'package:juan_million/utlis/app_constants.dart';
import 'package:juan_million/utlis/colors.dart';
import 'package:juan_million/widgets/button_widget.dart';
import 'package:juan_million/widgets/text_widget.dart';
import 'package:juan_million/widgets/toast_widget.dart';

class CoordinatorHomeScreen extends StatefulWidget {
  const CoordinatorHomeScreen({super.key});

  @override
  State<CoordinatorHomeScreen> createState() => _CoordinatorHomeScreenState();
}

class _CoordinatorHomeScreenState extends State<CoordinatorHomeScreen> {
  final searchController = TextEditingController();
  String nameSearched = '';

  @override
  Widget build(BuildContext context) {
    final Stream<DocumentSnapshot> userData = FirebaseFirestore.instance
        .collection('Coordinator')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots();

    return Container(
      color: const Color(0xFFF8F9FA),
      child: LayoutBuilder(
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

              dynamic mydata = snapshot.data;

              return CustomScrollView(
                slivers: [
                  // Header Section
                  SliverToBoxAdapter(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: 20,
                      ),
                      decoration: BoxDecoration(
                        color: primary,
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          // Welcome Section
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextWidget(
                                      text: 'Welcome back,',
                                      fontSize: isWeb ? 20 : 18,
                                      color: Colors.white,
                                      fontFamily: 'Regular',
                                    ),
                                    const SizedBox(height: 5),
                                    TextWidget(
                                      text: mydata['name'] ?? 'Coordinator',
                                      fontSize: isWeb ? 28 : 24,
                                      color: Colors.white,
                                      fontFamily: 'Bold',
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  children: [
                                    Icon(Icons.account_balance_wallet,
                                        color: Colors.white,
                                        size: isWeb ? 30 : 24),
                                    const SizedBox(height: 5),
                                    TextWidget(
                                      text: AppConstants.formatNumberWithPeso(
                                          mydata['wallet'] ?? 0),
                                      fontSize: isWeb ? 18 : 16,
                                      color: Colors.white,
                                      fontFamily: 'Bold',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 25),
                          // Search Bar
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: searchController,
                              onSubmitted: (value) {
                                setState(() {
                                  nameSearched = value;
                                });
                              },
                              decoration: InputDecoration(
                                hintText: 'Search Affiliates...',
                                hintStyle: TextStyle(
                                  color: grey,
                                  fontFamily: 'Regular',
                                  fontSize: isWeb ? 16 : 14,
                                ),
                                prefixIcon: Icon(Icons.search, color: grey),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: isWeb ? 20 : 15,
                                  vertical: isWeb ? 20 : 15,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),

                  // Pending Verifications Section
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
                              Icon(Icons.pending_actions,
                                  color: primary, size: 28),
                              const SizedBox(width: 10),
                              TextWidget(
                                text: 'Pending Verifications',
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

                  // Business List
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('Business')
                        .where('verified', isEqualTo: false)
                        .where('name',
                            isGreaterThanOrEqualTo:
                                toBeginningOfSentenceCase(nameSearched))
                        .where('name',
                            isLessThan:
                                '${toBeginningOfSentenceCase(nameSearched)}z')
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
                                    text: 'Error loading data',
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

                      if (data.docs.isEmpty) {
                        return SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 50),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(Icons.search_off, size: 64, color: grey),
                                  const SizedBox(height: 20),
                                  TextWidget(
                                    text: 'No pending verifications found',
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
                              return Container(
                                margin: const EdgeInsets.only(bottom: 20),
                                child: Container(
                                  width: cardWidth,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.08),
                                        blurRadius: 15,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: () => verifyDialog(
                                        data.docs[index], mydata['wallet']),
                                    child: Padding(
                                      padding: EdgeInsets.all(isWeb ? 25 : 20),
                                      child: Row(
                                        children: [
                                          // Business Logo
                                          Container(
                                            width: isWeb ? 120 : 100,
                                            height: isWeb ? 120 : 100,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[100],
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.05),
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 3),
                                                ),
                                              ],
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              child: Image.network(
                                                data.docs[index]['logo'],
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return Icon(Icons.business,
                                                      color: grey,
                                                      size: isWeb ? 50 : 40);
                                                },
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 20),
                                          // Business Details
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                TextWidget(
                                                  text: data.docs[index]
                                                      ['name'],
                                                  fontSize: isWeb ? 22 : 18,
                                                  fontFamily: 'Bold',
                                                  color: primary,
                                                ),
                                                const SizedBox(height: 8),
                                                Row(
                                                  children: [
                                                    Icon(Icons.email_outlined,
                                                        color: grey,
                                                        size: isWeb ? 18 : 16),
                                                    const SizedBox(width: 5),
                                                    Expanded(
                                                      child: TextWidget(
                                                        text: data.docs[index]
                                                            ['email'],
                                                        fontSize:
                                                            isWeb ? 14 : 12,
                                                        color: grey,
                                                        fontFamily: 'Regular',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 5),
                                                Row(
                                                  children: [
                                                    Icon(
                                                        Icons
                                                            .location_on_outlined,
                                                        color: grey,
                                                        size: isWeb ? 18 : 16),
                                                    const SizedBox(width: 5),
                                                    Expanded(
                                                      child: TextWidget(
                                                        text: data.docs[index]
                                                            ['address'],
                                                        fontSize:
                                                            isWeb ? 14 : 12,
                                                        color: grey,
                                                        fontFamily: 'Regular',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 15),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 12,
                                                          vertical: 6),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            primary.withValues(
                                                                alpha: 0.1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                      ),
                                                      child: TextWidget(
                                                        text: AppConstants
                                                            .formatNumberWithPeso(
                                                                data.docs[index]
                                                                    [
                                                                    'packagePayment']),
                                                        fontSize:
                                                            isWeb ? 16 : 14,
                                                        fontFamily: 'Bold',
                                                        color: primary,
                                                      ),
                                                    ),
                                                    ButtonWidget(
                                                      width: isWeb ? 120 : 100,
                                                      height: isWeb ? 45 : 40,
                                                      radius: 25,
                                                      fontSize: isWeb ? 16 : 14,
                                                      label: 'Verify',
                                                      color: primary,
                                                      onPressed: () {
                                                        verifyDialog(
                                                            data.docs[index],
                                                            mydata['wallet']);
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                            childCount: data.docs.length,
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

  verifyDialog(data, int mywallet) {
    bool isWeb = MediaQuery.of(context).size.width > 800;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: isWeb ? 500 : null,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(isWeb ? 30 : 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with logo and close button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 40),
                      TextWidget(
                        text: 'Business Verification',
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

                  // Business Logo
                  Center(
                    child: Container(
                      width: isWeb ? 180 : 150,
                      height: isWeb ? 180 : 150,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          data['logo'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.business,
                                color: grey, size: isWeb ? 60 : 50);
                          },
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Business Name
                  TextWidget(
                    text: data['name'],
                    fontSize: isWeb ? 24 : 22,
                    fontFamily: 'Bold',
                    color: primary,
                  ),

                  const SizedBox(height: 5),

                  // Business Email
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.email_outlined, color: grey, size: 16),
                      const SizedBox(width: 5),
                      Expanded(
                        child: TextWidget(
                          text: data['email'],
                          fontSize: isWeb ? 16 : 14,
                          color: grey,
                          fontFamily: 'Regular',
                          align: TextAlign.center,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // Information Cards
                  _buildInfoCard(
                    title: 'Address',
                    content: data['address'],
                    icon: Icons.location_on_outlined,
                    isWeb: isWeb,
                  ),

                  const SizedBox(height: 15),

                  _buildInfoCard(
                    title: 'Business Type',
                    content: data['clarification'],
                    icon: Icons.business_center_outlined,
                    isWeb: isWeb,
                  ),

                  const SizedBox(height: 15),

                  _buildInfoCard(
                    title: 'Representative',
                    content: data['representative'],
                    icon: Icons.person_outline,
                    isWeb: isWeb,
                  ),

                  const SizedBox(height: 25),

                  // Payment Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextWidget(
                              text: 'Verification Fee',
                              fontSize: isWeb ? 16 : 14,
                              color: grey,
                              fontFamily: 'Regular',
                            ),
                            TextWidget(
                              text: 'This will be deducted from your wallet',
                              fontSize: isWeb ? 12 : 10,
                              color: grey,
                              fontFamily: 'Regular',
                            ),
                          ],
                        ),
                        TextWidget(
                          text: AppConstants.formatNumberWithPeso(
                              data['packagePayment']),
                          fontSize: isWeb ? 24 : 20,
                          fontFamily: 'Bold',
                          color: primary,
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
                        child: ButtonWidget(
                          label: 'Verify Business',
                          height: isWeb ? 55 : 50,
                          fontSize: isWeb ? 16 : 14,
                          radius: 12,
                          color: mywallet >=
                                  (data['packagePayment'] is num
                                      ? (data['packagePayment'] as num).toInt()
                                      : 2000)
                              ? primary
                              : Colors.grey,
                          onPressed: () async {
                            final int verificationFee =
                                data['packagePayment'] is num
                                    ? (data['packagePayment'] as num).toInt()
                                    : 2000;

                            if (mywallet < verificationFee) {
                              showToast('Your wallet balance is not enough!');
                              return;
                            }

                            Navigator.of(context).pop();

                            await FirebaseFirestore.instance
                                .collection('Business')
                                .doc(data.id)
                                .update({
                              'verified': true,
                              'wallet': 100,
                            });

                            await FirebaseFirestore.instance
                                .collection('Coordinator')
                                .doc(FirebaseAuth.instance.currentUser!.uid)
                                .update({
                              'wallet': FieldValue.increment(-verificationFee),
                            });

                            showToast('Business verified successfully!');
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String content,
    required IconData icon,
    required bool isWeb,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: primary, size: isWeb ? 20 : 18),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(
                  text: title,
                  fontSize: isWeb ? 12 : 10,
                  color: grey,
                  fontFamily: 'Regular',
                ),
                const SizedBox(height: 5),
                TextWidget(
                  text: content,
                  fontSize: isWeb ? 16 : 14,
                  fontFamily: 'Medium',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
