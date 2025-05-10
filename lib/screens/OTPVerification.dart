// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:my_furry_friend/screens/OtpPage.dart';

// class Otpverification extends StatefulWidget {
//   final String email;

//   const Otpverification({Key? key, required this.email}) : super(key: key);

//   @override
//   State<Otpverification> createState() => _OtpverificationState();
// }

// class _OtpverificationState extends State<Otpverification> {
//   final phoneController = TextEditingController();
//   bool isSendingOtp = false;

//   @override
//   void dispose() {
//     phoneController.dispose();
//     super.dispose();
//   }

//   Future<void> sendOtp(BuildContext context) async {
//     setState(() {
//       isSendingOtp = true;
//     });

//     try {
//       await FirebaseAuth.instance.verifyPhoneNumber(
//         phoneNumber: phoneController.text.trim(),
//         verificationCompleted: (PhoneAuthCredential credential) async {
//           // Automatically sign in the user if the OTP is auto-filled
//           await FirebaseAuth.instance.signInWithCredential(credential);
//           Navigator.pushReplacementNamed(context, '/dashboard');
//         },
//         verificationFailed: (FirebaseAuthException e) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Verification failed: ${e.message}')),
//           );
//         },
//         codeSent: (String verificationId, int? resendToken) {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => OtpPage(verificationId: verificationId),
//             ),
//           );
//         },
//         codeAutoRetrievalTimeout: (String verificationId) {
//           // Handle timeout if necessary
//         },
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: ${e.toString()}')),
//       );
//     } finally {
//       setState(() {
//         isSendingOtp = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Phone Verification'),
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Text(
//               'Enter your phone number',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 20),
//             TextField(
//               controller: phoneController,
//               keyboardType: TextInputType.phone,
//               decoration: InputDecoration(
//                 labelText: 'Phone Number',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 30),
//             isSendingOtp
//                 ? const CircularProgressIndicator()
//                 : ElevatedButton(
//                     onPressed: () => sendOtp(context),
//                     child: const Text('Send OTP'),
//                   ),
//           ],
//         ),
//       ),
//     );
//   }
// }
