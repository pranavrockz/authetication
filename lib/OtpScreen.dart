import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'OptionsScreen.dart';
 // Make sure you have this file

class OtpScreen extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;
  final int? resendToken;

  const OtpScreen({super.key, 
    required this.phoneNumber,
    required this.verificationId,
    this.resendToken,
  });

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  late String _verificationId;  // Store verificationId in the state
  int? _resendToken;            // Store resendToken in the state

  @override
  void initState() {
    super.initState();
    _verificationId = widget.verificationId;  // Initialize from widget
    _resendToken = widget.resendToken;        // Initialize from widget
  }

  void signInWithCode(BuildContext context, String smsCode) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: _verificationId,  // Use the local state variable
      smsCode: smsCode,
    );
    try {
      await FirebaseAuth.instance.signInWithCredential(credential);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OptionsScreen()),  // Make sure OptionsScreen exists
      );
    } catch (e) {
      print('Failed to sign in: $e');
    }
  }

  void resendCode() async {
    if (_resendToken == null) {
      print("Resend token is not available.");
      return;
    }

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: widget.phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await FirebaseAuth.instance.signInWithCredential(credential);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OptionsScreen()),
        );
      },
      verificationFailed: (FirebaseAuthException e) {
        if (e.code == 'invalid-phone-number') {
          print('The provided phone number is not valid.');
        } else {
          print('Verification failed: ${e.message}');
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;  // Update the state variable
          _resendToken = resendToken;        // Update the state variable
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() {
          _verificationId = verificationId;  // Update the state variable
        });
      },
      forceResendingToken: _resendToken,  // Pass the local resend token
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Phone'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Code is sent to ${widget.phoneNumber}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _otpController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter OTP',
              ),
              keyboardType: TextInputType.number,
              maxLength: 6,
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: resendCode,
              child: const Text("Didn’t receive the code? Request Again"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_otpController.text.length == 6) {
                  signInWithCode(context, _otpController.text);
                } else {
                  print('Please enter a valid 6-digit OTP');
                }
              },
              child: const Text('VERIFY AND CONTINUE'),
            ),
          ],
        ),
      ),
    );
  }
}
