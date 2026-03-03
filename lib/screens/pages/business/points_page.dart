import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:juan_million/screens/pages/store_page.dart';
import 'package:juan_million/utlis/colors.dart';
import 'package:juan_million/widgets/text_widget.dart';

class PointsPage extends StatelessWidget {
  const PointsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Stream<DocumentSnapshot> userData = FirebaseFirestore.instance
        .collection('Business')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots();

    return Scaffold(
      backgroundColor: blue,
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
            dynamic mydata = snapshot.data;
            return SafeArea(
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
                      text: 'Total Points',
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextWidget(
                        text: mydata['pts'].toString(),
                        fontFamily: 'Bold',
                        fontSize: 75,
                        color: Colors.white,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  StorePage(inbusiness: true)));
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                              color: Colors.white, shape: BoxShape.circle),
                          child: Icon(
                            Icons.add,
                            color: primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextWidget(
                          text: 'Transactions',
                          fontSize: 18,
                          color: Colors.white,
                          fontFamily: 'Bold',
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          height: 400,
                          child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('Points')
                                .where('uid',
                                    isEqualTo: FirebaseAuth
                                        .instance.currentUser!.uid)
                                .orderBy('dateTime', descending: true)
                                .snapshots(),
                            builder: (context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (!snapshot.hasData) {
                                return const Center(
                                    child: CircularProgressIndicator(
                                        color: Colors.white));
                              } else if (snapshot.hasError) {
                                return const Center(
                                    child: Text('Something went wrong',
                                        style:
                                            TextStyle(color: Colors.white)));
                              }
                              final docs = snapshot.requireData.docs;
                              if (docs.isEmpty) {
                                return Center(
                                  child: TextWidget(
                                    text: 'No transactions yet',
                                    fontSize: 14,
                                    color: Colors.white70,
                                    fontFamily: 'Regular',
                                  ),
                                );
                              }
                              return ListView.builder(
                                itemCount: docs.length,
                                itemBuilder: (context, index) {
                                  final doc = docs[index];
                                  final dynamic rawPts = doc['pts'];
                                  final int pts = rawPts is num
                                      ? rawPts.toInt()
                                      : 0;
                                  final dynamic rawDate = doc['dateTime'];
                                  final DateTime dateTime =
                                      rawDate is Timestamp
                                          ? rawDate.toDate()
                                          : DateTime.now();
                                  final String type =
                                      doc['type']?.toString() ?? 'Transaction';
                                  return Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: ListTile(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          15,
                                        ),
                                      ),
                                      tileColor: Colors.white,
                                      leading: Icon(
                                        Icons.volunteer_activism_outlined,
                                        color: secondary,
                                        size: 32,
                                      ),
                                      title: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          TextWidget(
                                            text: DateFormat('MMM d, yyyy h:mm a')
                                                .format(dateTime),
                                            fontSize: 11,
                                            color: Colors.grey,
                                            fontFamily: 'Medium',
                                          ),
                                          TextWidget(
                                            text: '$type — $pts pts',
                                            fontSize: 14,
                                            color: Colors.black,
                                            fontFamily: 'Medium',
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
    );
  }
}
