import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:juan_million/screens/admin_tabs/wallets/business_wallets.dart';
import 'package:juan_million/screens/admin_tabs/wallets/company_wallet.dart';
import 'package:juan_million/screens/admin_tabs/wallets/it_wallet.dart';
import 'package:juan_million/screens/admin_tabs/wallets/member_wallets.dart';
import 'package:juan_million/utlis/app_constants.dart';
import 'package:juan_million/widgets/text_widget.dart';

import '../../utlis/colors.dart';

class WalletTab extends StatelessWidget {
  const WalletTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Community Wallet')
                    .doc('business')
                    .snapshots(),
                builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: Text('Loading'));
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('Something went wrong'));
                  } else if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  dynamic walletdata = snapshot.data;
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => CompanyWallet(
                                total: walletdata['pts'],
                              )));
                    },
                    child: Container(
                      width: 170,
                      height: 150,
                      decoration: BoxDecoration(
                        color: primary,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          TextWidget(
                            text: AppConstants.formatNumberWithPeso(
                                walletdata['pts']),
                            fontSize: 32,
                            fontFamily: 'Bold',
                            color: Colors.white,
                          ),
                          TextWidget(
                            text: 'Company Income',
                            fontSize: 12,
                            fontFamily: 'Regular',
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
            StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Community Wallet')
                    .doc('it')
                    .snapshots(),
                builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: Text('Loading'));
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('Something went wrong'));
                  } else if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  dynamic walletdata = snapshot.data;
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ITWallet(
                                total: walletdata['pts'],
                              )));
                    },
                    child: Container(
                      width: 170,
                      height: 150,
                      decoration: BoxDecoration(
                        color: primary,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          TextWidget(
                            text: AppConstants.formatNumberWithPeso(
                                walletdata['pts']),
                            fontSize: 32,
                            fontFamily: 'Bold',
                            color: Colors.white,
                          ),
                          TextWidget(
                            text: 'Tech Support Income',
                            fontSize: 12,
                            fontFamily: 'Regular',
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const BusinessWallets()));
              },
              child: Container(
                width: 170,
                height: 150,
                decoration: BoxDecoration(
                  color: secondary,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.business,
                      size: 75,
                      color: Colors.white,
                    ),
                    TextWidget(
                      text: 'Affiliates',
                      fontSize: 12,
                      fontFamily: 'Regular',
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const MemberWallets()));
              },
              child: Container(
                width: 170,
                height: 150,
                decoration: BoxDecoration(
                  color: secondary,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.person,
                      size: 75,
                      color: Colors.white,
                    ),
                    TextWidget(
                      text: 'Members',
                      fontSize: 12,
                      fontFamily: 'Regular',
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
