// // google_play_service.dart
// import 'package:google_api_availability/google_api_availability.dart';
//
// class GooglePlayService {
//   static Future<void> checkAndUpdatePlayServices() async {
//     // Use the factory constructor to access the API
//     final availability = GoogleApiAvailability.instance;
//
//     final status = await availability.checkGooglePlayServicesAvailability();
//
//     if (status != GooglePlayServicesAvailability.success) {
//       // Handle the issue (ask the user to update Google Play Services)
//       print("Google Play Services is not available or needs an update.");
//       // You can prompt the user to update or install Google Play Services here
//     } else {
//       print("Google Play Services is available.");
//     }
//   }
// }
