// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class OtpPage extends StatefulWidget {
//   final String verificationId;

//   const OtpPage({Key? key, required this.verificationId}) : super(key: key);

//   @override
//   State<OtpPage> createState() => _OtpPageState();
// }

// class _OtpPageState extends State<OtpPage> {
//   final otpController = TextEditingController();
//   bool isVerifying = false;

//   @override
//   void dispose() {
//     otpController.dispose();
//     super.dispose();
//   }

//   Future<void> verifyOtp(BuildContext context) async {
//     setState(() {
//       isVerifying = true;
//     });

//     try {
//       final credential = PhoneAuthProvider.credential(
//         verificationId: widget.verificationId,
//         smsCode: otpController.text.trim(),
//       );

//       // Sign in with the credential
//       await FirebaseAuth.instance.signInWithCredential(credential);

//       // Navigate to the next screen (e.g., user profile or dashboard)
//       Navigator.pushReplacementNamed(context, '/dashboard');
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Invalid OTP. Please try again.')),
//       );
//     } finally {
//       setState(() {
//         isVerifying = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Verify OTP'),
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Text(
//               'Enter the OTP sent to your phone',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 20),
//             TextField(
//               controller: otpController,
//               keyboardType: TextInputType.number,
//               decoration: InputDecoration(
//                 labelText: 'OTP',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 30),
//             isVerifying
//                 ? const CircularProgressIndicator()
//                 : ElevatedButton(
//                     onPressed: () => verifyOtp(context),
//                     child: const Text('Verify OTP'),
//                   ),
//           ],
//         ),
//       ),
//     );
//   }
// }
