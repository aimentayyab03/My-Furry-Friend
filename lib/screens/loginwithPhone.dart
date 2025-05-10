// import 'package:flutter/material.dart';
// import 'package:mff/screens/OtpPage.dart';
// import '../services/auth.dart';
//
// class Loginwithphone extends StatefulWidget {
//   const Loginwithphone({super.key});
//
//   @override
//   State<Loginwithphone> createState() => _LoginwithphoneState();
// }
//
// class _LoginwithphoneState extends State<Loginwithphone> {
//   TextEditingController phonenumber = TextEditingController();
//   final AuthService _authService = AuthService();
//   String? verificationId; // To store the verification ID received from Firebase
//
//   sendCode() async {
//     final phoneNumber = "+92" + phonenumber.text.trim(); // Getting phone number
//
//     await _authService.sendCode(phoneNumber, (String id) {
//       setState(() {
//         verificationId = id; // Store verificationId when received
//       });
//       print("Verification ID received: $verificationId"); // Debugging
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Column(
//           children: [
//             // OTP Image
//             Center(
//               child: SizedBox(
//                 width: 200, // Set desired width
//                 height: 200, // Set desired height
//                 child: Image.asset('assets/images/otp.png'),
//               ),
//             ),
//             Center(
//               child: Text(
//                 "Enter your phone number",
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 6),
//               child: Text("We will send you one-time OTP"),
//             ),
//             SizedBox(height: 20),
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: 50),
//               child: TextField(
//                 controller: phonenumber,
//                 keyboardType: TextInputType.number,
//                 decoration: InputDecoration(
//                   prefix: Text("+92"),
//                   prefixIcon: Icon(Icons.phone),
//                   labelText: 'Enter Phone Number',
//                   hintStyle: TextStyle(color: Colors.grey),
//                   labelStyle: TextStyle(color: Colors.grey),
//                   enabledBorder: UnderlineInputBorder(
//                     borderSide: BorderSide(color: Colors.black),
//                   ),
//                   focusedBorder: UnderlineInputBorder(
//                     borderSide: BorderSide(color: Colors.black),
//                   ),
//                 ),
//               ),
//             ),
//             SizedBox(height: 50),
//       ElevatedButton(
//         onPressed: () async {
//           // Ensure phone number is not empty
//           if (phonenumber.text.trim().isEmpty) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text("Please enter a valid phone number.")),
//             );
//             return;
//           }
//
//           // Send OTP
//           await sendCode();
//
//           // Check if verificationId is received
//           if (verificationId != null && verificationId!.isNotEmpty) {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => OtpPage(vid: verificationId!), // Pass verificationId
//               ),
//             );
//           } else {
//             // If verificationId is missing, show error
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text("Verification ID is missing.")),
//             );
//           }
//         },
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.purple,
//           padding: const EdgeInsets.all(16.0),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 90),
//           child: Text(
//             'Receive OTP',
//             style: TextStyle(fontSize: 18.0, color: Colors.white, fontWeight: FontWeight.bold),
//           ),
//         ),
//       )
//           ],
//         ),
//       ),
//     );
//   }
// }
