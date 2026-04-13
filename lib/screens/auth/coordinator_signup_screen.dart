import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:juan_million/utlis/colors.dart';
import 'package:juan_million/widgets/button_widget.dart';
import 'package:juan_million/widgets/text_widget.dart';
import 'package:juan_million/widgets/textfield_widget.dart';
import 'package:juan_million/widgets/toast_widget.dart';

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

  // Store picked files locally — upload happens after auth is created
  PlatformFile? _dtiFile;
  PlatformFile? _contractFile;
  PlatformFile? _idFile;

  bool isSubmitting = false;

  String _getContentTypeFromExtension(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      default:
        return 'application/octet-stream';
    }
  }

  /// Pick a file and store it locally — no upload until registration.
  Future<void> pickDocument(String docType) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        withData: true,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
      );

      if (result == null || result.files.isEmpty) return;

      final pickedFile = result.files.single;

      // On web bytes is populated; on mobile fall back to reading from path.
      if (pickedFile.bytes == null && pickedFile.path == null) {
        showToast('Could not read file. Please try again.');
        return;
      }

      if (!mounted) return;
      setState(() {
        if (docType == 'dti') {
          _dtiFile = pickedFile;
        } else if (docType == 'contract') {
          _contractFile = pickedFile;
        } else if (docType == 'id') {
          _idFile = pickedFile;
        }
      });
    } catch (err) {
      if (kDebugMode) print(err);
      showToast('Failed to select file. Please try again.');
    }
  }

  /// Upload a single PlatformFile to Firebase Storage and return its download URL.
  Future<String> _uploadFile(PlatformFile file, String storagePath) async {
    Uint8List? bytes = file.bytes;

    // On mobile, bytes may be null — read from path instead.
    if (bytes == null && file.path != null && !kIsWeb) {
      bytes = await File(file.path!).readAsBytes();
    }

    if (bytes == null) {
      throw Exception('Could not read file bytes for ${file.name}');
    }

    final contentType = _getContentTypeFromExtension(file.name);
    final ref = firebase_storage.FirebaseStorage.instance.ref(storagePath);

    await ref.putData(
      bytes,
      firebase_storage.SettableMetadata(contentType: contentType),
    );

    return await ref.getDownloadURL();
  }

  Future<void> registerCoordinator(BuildContext context) async {
    if (name.text.trim().isEmpty ||
        username.text.trim().isEmpty ||
        password.text.isEmpty) {
      showToast('Please fill in all required fields.');
      return;
    }

    if (_dtiFile == null || _contractFile == null || _idFile == null) {
      showToast('Please select all required documents before registering.');
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    // Show uploading dialog
    if (!mounted) return;
    final navigator = Navigator.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) => const Padding(
        padding: EdgeInsets.only(left: 30, right: 30),
        child: AlertDialog(
          title: Row(
            children: [
              CircularProgressIndicator(color: Colors.black),
              SizedBox(width: 20),
              Expanded(
                child: Text(
                  'Uploading documents & registering...',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'QRegular',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    UserCredential? userCredential;

    try {
      final email = '${username.text.trim()}@coordinator.com';

      Map<String, dynamic> defaults = <String, dynamic>{};
      try {
        final defaultsDoc = await FirebaseFirestore.instance
            .collection('AdminConfig')
            .doc('SignupDefaults')
            .get();
        defaults = defaultsDoc.data() ?? <String, dynamic>{};
      } catch (_) {}

      final int initialWallet = (defaults['coordinatorInitialWallet'] is num)
          ? (defaults['coordinatorInitialWallet'] as num).toInt()
          : 0;
      final bool autoApproved = defaults['coordinatorAutoApproved'] == true;

      // Step 1: Create Firebase Auth account so we are authenticated for Storage.
      userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: email,
            password: password.text,
          );

      final uid = userCredential.user!.uid;

      // Step 2: Upload documents now that the user is authenticated.
      final String dtiUrl = await _uploadFile(
        _dtiFile!,
        'CoordinatorDocs/dti/${uid}_${_dtiFile!.name}',
      );
      final String contractUrl = await _uploadFile(
        _contractFile!,
        'CoordinatorDocs/contract/${uid}_${_contractFile!.name}',
      );
      final String idUrl = await _uploadFile(
        _idFile!,
        'CoordinatorDocs/id/${uid}_${_idFile!.name}',
      );

      // Step 3: Create Firestore document.
      await FirebaseFirestore.instance.collection('Coordinator').doc(uid).set({
        'name': name.text.trim(),
        'email': email,
        'wallet': initialWallet,
        'dtiSecUrl': dtiUrl,
        'contractUrl': contractUrl,
        'govIdUrl': idUrl,
        'approved': autoApproved,
        'createdAt': DateTime.now(),
      });

      // Step 4: Sign out — account awaits admin approval.
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      // Dismiss uploading dialog.
      if (navigator.canPop()) navigator.pop();

      showToast(
        'Registration submitted. Please wait for admin approval, then log in.',
      );

      navigator.pop();
    } on FirebaseAuthException catch (e) {
      if (navigator.canPop()) navigator.pop();

      // If the account was created but upload failed, clean up the auth account.
      if (userCredential != null) {
        try {
          await userCredential.user?.delete();
        } catch (_) {}
        await FirebaseAuth.instance.signOut();
      }

      if (e.code == 'weak-password') {
        showToast('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        showToast('The account already exists for that username.');
      } else if (e.code == 'invalid-email') {
        showToast('The generated email address is not valid.');
      } else {
        showToast(e.message ?? 'Registration failed.');
      }
    } on firebase_storage.FirebaseException catch (e) {
      if (navigator.canPop()) navigator.pop();

      // Clean up the created auth account since documents failed to upload.
      if (userCredential != null) {
        try {
          await userCredential.user?.delete();
        } catch (_) {}
        await FirebaseAuth.instance.signOut();
      }

      if (kDebugMode) print('Storage error: ${e.code} — ${e.message}');
      showToast('Failed to upload documents. Please try again.');
    } catch (e) {
      if (navigator.canPop()) navigator.pop();

      if (userCredential != null) {
        try {
          await userCredential.user?.delete();
        } catch (_) {}
        await FirebaseAuth.instance.signOut();
      }

      if (kDebugMode) print('Registration error: $e');
      showToast('An error occurred during registration. Please try again.');
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
              const SizedBox(height: 40),
              Image.asset('assets/images/Juan4All 2.png', height: 160),
              const SizedBox(height: 10),
              TextWidget(
                text: 'Coordinator Registration',
                fontSize: 28,
                fontFamily: 'Bold',
                color: primary,
              ),
              const SizedBox(height: 20),
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
              const SizedBox(height: 15),
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
              const SizedBox(height: 15),
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
              const SizedBox(height: 25),
              _buildUploadCard(
                title: 'DTI or SEC Registration',
                description:
                    'Upload a clear photo or scan of your DTI/SEC document.',
                selectedFile: _dtiFile,
                onPressed: () => pickDocument('dti'),
              ),
              _buildUploadCard(
                title: 'Signed Contract',
                description: 'Upload the signed coordinator contract.',
                selectedFile: _contractFile,
                onPressed: () => pickDocument('contract'),
              ),
              _buildUploadCard(
                title: 'Valid Government ID',
                description:
                    'Upload a clear photo of your valid government ID.',
                selectedFile: _idFile,
                onPressed: () => pickDocument('id'),
              ),
              const SizedBox(height: 25),
              ButtonWidget(
                width: 350,
                label: isSubmitting ? 'Submitting...' : 'Register',
                onPressed: () {
                  if (isSubmitting) return;
                  registerCoordinator(context);
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadCard({
    required String title,
    required String description,
    required PlatformFile? selectedFile,
    required VoidCallback onPressed,
  }) {
    final bool hasFile = selectedFile != null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        width: 350,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: blue.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
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
              const SizedBox(height: 6),
              TextWidget(
                text: description,
                fontSize: 12,
                fontFamily: 'Regular',
                color: Colors.grey,
                maxLines: 3,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          hasFile
                              ? Icons.check_circle
                              : Icons.cloud_upload_outlined,
                          color: hasFile ? primary : blue,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: TextWidget(
                            text: hasFile
                                ? selectedFile.name
                                : 'No file selected',
                            fontSize: 12,
                            fontFamily: 'Regular',
                            color: hasFile ? primary : Colors.grey,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: onPressed,
                    child: TextWidget(
                      text: hasFile ? 'Change' : 'Select',
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
