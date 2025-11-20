import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:juan_million/screens/main_coordinator_home.dart';
import 'package:juan_million/utlis/colors.dart';
import 'package:juan_million/widgets/button_widget.dart';
import 'package:juan_million/widgets/text_widget.dart';
import 'package:juan_million/widgets/textfield_widget.dart';
import 'package:juan_million/widgets/toast_widget.dart';
import 'package:path/path.dart' as path;

class CoordinatorSignupScreen extends StatefulWidget {
  const CoordinatorSignupScreen({super.key});

  @override
  State<CoordinatorSignupScreen> createState() =>
      _CoordinatorSignupScreenState();
}

class _CoordinatorSignupScreenState extends State<CoordinatorSignupScreen> {
  final name = TextEditingController();
  final username = TextEditingController();
  final password = TextEditingController();

  String dtiUrl = '';
  String contractUrl = '';
  String idUrl = '';

  bool isSubmitting = false;

  Future<void> uploadDocument(String docType) async {
    final picker = ImagePicker();
    XFile? pickedImage;

    try {
      pickedImage = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
      );

      if (pickedImage == null) {
        return;
      }

      final fileName = path.basename(pickedImage.path);

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => const Padding(
          padding: EdgeInsets.only(left: 30, right: 30),
          child: AlertDialog(
            title: Row(
              children: [
                CircularProgressIndicator(
                  color: Colors.black,
                ),
                SizedBox(
                  width: 20,
                ),
                Text(
                  'Uploading . . .',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'QRegular',
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      try {
        final ref = firebase_storage.FirebaseStorage.instance
            .ref('CoordinatorDocs/$docType/$fileName');

        final bytes = await pickedImage.readAsBytes();

        await ref.putData(
          bytes,
          firebase_storage.SettableMetadata(
            contentType: 'image/jpeg',
          ),
        );

        final downloadUrl = await ref.getDownloadURL();

        if (!mounted) return;

        setState(() {
          if (docType == 'dti') {
            dtiUrl = downloadUrl;
          } else if (docType == 'contract') {
            contractUrl = downloadUrl;
          } else if (docType == 'id') {
            idUrl = downloadUrl;
          }
        });

        Navigator.of(context).pop();
        showToast('File uploaded!');
      } on firebase_storage.FirebaseException catch (error) {
        if (kDebugMode) {
          print(error);
        }
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
        showToast('Failed to upload file.');
      }
    } catch (err) {
      if (kDebugMode) {
        print(err);
      }
    }
  }

  Future<void> registerCoordinator(BuildContext context) async {
    if (name.text.trim().isEmpty ||
        username.text.trim().isEmpty ||
        password.text.isEmpty) {
      showToast('Please fill in all required fields.');
      return;
    }

    if (dtiUrl.isEmpty || contractUrl.isEmpty || idUrl.isEmpty) {
      showToast('Please upload all required documents.');
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      final email = '${username.text.trim()}@coordinator.com';

      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password.text,
      );

      await FirebaseFirestore.instance
          .collection('Coordinator')
          .doc(userCredential.user!.uid)
          .set({
        'name': name.text.trim(),
        'email': email,
        'wallet': 0,
        'dtiSecUrl': dtiUrl,
        'contractUrl': contractUrl,
        'govIdUrl': idUrl,
        'approved': false,
        'createdAt': DateTime.now(),
      });

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const MainCoordinatorHomeScreen(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        showToast('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        showToast('The account already exists for that username.');
      } else if (e.code == 'invalid-email') {
        showToast('The generated email address is not valid.');
      } else {
        showToast(e.message ?? 'Registration failed.');
      }
    } catch (e) {
      showToast('An error occurred during registration.');
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 40,
              ),
              Image.asset(
                'assets/images/Juan4All 2.png',
                height: 160,
              ),
              const SizedBox(
                height: 10,
              ),
              TextWidget(
                text: 'Coordinator Registration',
                fontSize: 28,
                fontFamily: 'Bold',
                color: primary,
              ),
              const SizedBox(
                height: 20,
              ),
              TextFieldWidget(
                fontStyle: FontStyle.normal,
                hint: 'Full Name',
                borderColor: blue,
                radius: 12,
                width: 350,
                isRequred: false,
                prefixIcon: Icons.person_3_outlined,
                controller: name,
                label: 'Full Name',
              ),
              const SizedBox(
                height: 15,
              ),
              TextFieldWidget(
                fontStyle: FontStyle.normal,
                hint: 'Username',
                borderColor: blue,
                radius: 12,
                width: 350,
                isRequred: false,
                prefixIcon: Icons.account_circle_outlined,
                controller: username,
                label: 'Username',
              ),
              const SizedBox(
                height: 15,
              ),
              TextFieldWidget(
                showEye: true,
                isObscure: true,
                prefixIcon: Icons.lock_open_outlined,
                fontStyle: FontStyle.normal,
                hint: 'Password',
                borderColor: blue,
                radius: 12,
                width: 350,
                isRequred: false,
                controller: password,
                label: 'Password',
              ),
              const SizedBox(
                height: 25,
              ),
              _buildUploadCard(
                title: 'DTI or SEC Registration',
                description:
                    'Upload a clear photo or scan of your DTI/SEC document.',
                isUploaded: dtiUrl.isNotEmpty,
                onPressed: () => uploadDocument('dti'),
              ),
              _buildUploadCard(
                title: 'Signed Contract',
                description: 'Upload the signed coordinator contract.',
                isUploaded: contractUrl.isNotEmpty,
                onPressed: () => uploadDocument('contract'),
              ),
              _buildUploadCard(
                title: 'Valid Government ID',
                description:
                    'Upload a clear photo of your valid government ID.',
                isUploaded: idUrl.isNotEmpty,
                onPressed: () => uploadDocument('id'),
              ),
              const SizedBox(
                height: 25,
              ),
              ButtonWidget(
                width: 350,
                label: isSubmitting ? 'Submitting...' : 'Register',
                onPressed: () {
                  if (isSubmitting) return;
                  registerCoordinator(context);
                },
              ),
              const SizedBox(
                height: 40,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadCard({
    required String title,
    required String description,
    required bool isUploaded,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        width: 350,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: blue.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextWidget(
                text: title,
                fontSize: 14,
                fontFamily: 'Bold',
                color: blue,
              ),
              const SizedBox(
                height: 6,
              ),
              TextWidget(
                text: description,
                fontSize: 12,
                fontFamily: 'Regular',
                color: Colors.grey,
                maxLines: 3,
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        isUploaded
                            ? Icons.check_circle
                            : Icons.cloud_upload_outlined,
                        color: isUploaded ? primary : blue,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      TextWidget(
                        text: isUploaded ? 'File uploaded' : 'No file uploaded',
                        fontSize: 12,
                        fontFamily: 'Regular',
                        color: isUploaded ? primary : Colors.grey,
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: onPressed,
                    child: TextWidget(
                      text: isUploaded ? 'Re-upload' : 'Upload',
                      fontSize: 12,
                      fontFamily: 'Bold',
                      color: blue,
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
}
