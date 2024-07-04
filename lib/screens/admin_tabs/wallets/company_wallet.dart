import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:juan_million/utlis/app_constants.dart';
import 'package:juan_million/utlis/colors.dart';

import '../../../widgets/text_widget.dart';

import 'package:intl/intl.dart' show DateFormat, toBeginningOfSentenceCase;

class CompanyWallet extends StatefulWidget {
  int total;

  CompanyWallet({
    super.key,
    required this.total,
  });

  @override
  State<CompanyWallet> createState() => _CompanyWalletState();
}

class _CompanyWalletState extends State<CompanyWallet> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextWidget(
                      text: 'Total Company Income',
                      fontSize: 14,
                      fontFamily: 'Regular',
                      color: Colors.black,
                    ),
                    TextWidget(
                      text: AppConstants.formatNumberWithPeso(widget.total),
                      fontSize: 28,
                      fontFamily: 'Bold',
                      color: primary,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('History')
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError) {
                        print(snapshot.error);
                        return const Center(child: Text('Error'));
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.only(top: 50),
                          child: Center(
                              child: CircularProgressIndicator(
                            color: Colors.black,
                          )),
                        );
                      }

                      final data = snapshot.requireData;

                      return DataTable(columns: [
                        DataColumn(
                          label: TextWidget(
                            text: 'Member',
                            fontSize: 16,
                            fontFamily: 'Bold',
                          ),
                        ),
                        DataColumn(
                          label: TextWidget(
                            text: 'Received',
                            fontSize: 16,
                            fontFamily: 'Bold',
                          ),
                        ),
                        DataColumn(
                          label: TextWidget(
                            text: 'Company Income',
                            fontSize: 16,
                            fontFamily: 'Bold',
                          ),
                        ),
                      ], rows: [
                        for (int i = 0; i < data.docs.length; i++)
                          DataRow(cells: [
                            DataCell(TextWidget(
                              text: data.docs[i]['name'],
                              fontSize: 14,
                            )),
                            DataCell(TextWidget(
                              text: 'P 5,500',
                              fontSize: 14,
                            )),
                            DataCell(TextWidget(
                              text: 'P 2,400',
                              fontSize: 14,
                            )),
                          ])
                      ]);
                    })
              ],
            ),
          ),
        ),
      ),
    );
  }
}
