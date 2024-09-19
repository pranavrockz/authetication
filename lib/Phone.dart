import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:country_picker/country_picker.dart';
import 'package:libphonenumber/libphonenumber.dart';

import 'OtpScreen.dart';


class Phone extends StatefulWidget {
  const Phone({super.key});

  @override
  _PhoneAuthScreenState createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<Phone> {

  final TextEditingController _phoneController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String verificationId = '';
  bool codeSent = false;
  String _selectedCountryCode = '+91'; // Default country code (India)
  String? _phoneNumberError; // Variable to store validation error message

  void verifyPhoneNumber() async {
    String fullPhoneNumber = '$_selectedCountryCode${_phoneController.text}';
    print('Full phone number for verification: $fullPhoneNumber');

    // Validate phone number
    bool isValid = await _validatePhoneNumber(fullPhoneNumber, _selectedCountryCode);
    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid phone number format.'),
          backgroundColor: Colors.red,
        ),
      );
      return; // Exit if phone number is invalid
    }

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: fullPhoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Automatically sign in the user if the SMS code is auto-detected
          await _auth.signInWithCredential(credential);
          print('User signed in with auto-detected code.');
        },
        verificationFailed: (FirebaseAuthException e) {
          String errorMessage;
          switch (e.code) {
            case 'invalid-phone-number':
              errorMessage = 'The provided phone number is not valid.';
              break;
            case 'too-many-requests':
              errorMessage = 'Too many requests. Please try again later.';
              break;
            case 'network-request-failed':
              errorMessage = 'Network error. Please check your connection.';
              break;
            default:
              errorMessage = 'An error occurred. Please try again.';
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            this.verificationId = verificationId;
            codeSent = true;
          });
          print('Verification code sent to $fullPhoneNumber.');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtpScreen(
                phoneNumber: fullPhoneNumber,
                verificationId: verificationId,
              ),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          setState(() {
            this.verificationId = verificationId;
          });
          print('Auto retrieval timeout for verification ID: $verificationId');
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An unexpected error occurred: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<bool> _validatePhoneNumber(String phoneNumber, String countryCode) async {
    try {
      // Remove '+' from the country code and construct full phone number
      String isoCode = countryCode.substring(1); // e.g., '+91' -> '91'
      String fullPhoneNumber = '$countryCode$phoneNumber'; // e.g., '+919876543210'

      // Print for debugging purposes
      print('Validating phone number: $fullPhoneNumber with ISO code: $isoCode');

      // Validate phone number using the PhoneNumberUtil
      bool? isValid = await PhoneNumberUtil.isValidPhoneNumber(
        phoneNumber: phoneNumber,
        isoCode: isoCode,
      );

      // Update state based on validation result
      if (isValid != null && isValid) {
        setState(() {
          _phoneNumberError = null; // No error if phone number is valid
        });
        return true; // Indicate that the phone number is valid
      } else {
        setState(() {
          _phoneNumberError = "Invalid phone number"; // Set error message for invalid number
        });
        return false; // Indicate that the phone number is invalid
      }
    } catch (e) {
      // Handle unexpected errors
      setState(() {
        _phoneNumberError = "Error validating phone number: $e"; // Set error message
      });
      return false; // Indicate that there was an error during validation
    }
  }


  void _showCountryPicker() {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      onSelect: (Country country) {
        setState(() {
          _selectedCountryCode = '+${country.phoneCode}';
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phone Authentication'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Please enter your mobile number",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold, // Makes the text bold
                color: Colors.black, // Change the color if needed
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                GestureDetector(
                  onTap: _showCountryPicker,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Text(_selectedCountryCode), // Display selected country code
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText: 'Mobile Number',
                      errorText: _phoneNumberError,
                    ),
                    keyboardType: TextInputType.phone,
                    onChanged: (phoneNumber) {
                      _validatePhoneNumber(phoneNumber, _selectedCountryCode);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              "You'll receive a 6-digit code to verify next.",
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: verifyPhoneNumber,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: const Text(
                'NEXT',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
