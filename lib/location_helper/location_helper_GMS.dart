// import 'dart:async';

// import 'package:geolocator/geolocator.dart';

// enum LocationStatus {
//   ok,
//   serviceDisabled,
//   permissionDenied,
//   permissionDeniedForever,
//   timeout,
//   error,
// }

// class LocationResult {
//   final LocationStatus status;
//   final Position? position;
//   final String? message;

//   const LocationResult._(this.status, {this.position, this.message});

//   factory LocationResult.ok(Position p) =>
//       LocationResult._(LocationStatus.ok, position: p);

//   factory LocationResult.fail(LocationStatus s, {String? message}) =>
//       LocationResult._(s, message: message);
// }

// class LocationHelper {
//   const LocationHelper();

//   /// Map use-case: fast marker -> lastKnown (if fresh) then current.
//   Future<LocationResult> getForMap({
//     Duration lastKnownMaxAge = const Duration(minutes: 5),
//     LocationAccuracy accuracy = LocationAccuracy.high,
//     Duration timeLimit = const Duration(seconds: 10),
//   }) async {
//     // 1) Services enabled?
//     final servicesEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!servicesEnabled) {
//       return LocationResult.fail(LocationStatus.serviceDisabled,
//           message: 'Location services are OFF.');
//     }

//     // 2) Permission
//     final perm = await _ensurePermission();
//     if (perm == LocationPermission.denied) {
//       return LocationResult.fail(LocationStatus.permissionDenied,
//           message: 'Location permission denied.');
//     }
//     if (perm == LocationPermission.deniedForever) {
//       return LocationResult.fail(LocationStatus.permissionDeniedForever,
//           message: 'Location permission denied forever.');
//     }

//     // 3) Try last known first (fast)
//     final last = await Geolocator.getLastKnownPosition();
//     if (last != null && last.timestamp != null) {
//       final age = DateTime.now().difference(last.timestamp!);
//       if (age <= lastKnownMaxAge) {
//         return LocationResult.ok(last);
//       }
//     }

//     // 4) Fresh current position
//     try {
//       final pos = await Geolocator.getCurrentPosition(
//         locationSettings: LocationSettings(
//           accuracy: accuracy,
//           timeLimit: timeLimit,
//         ),
//       );
//       return LocationResult.ok(pos);
//     } on TimeoutException {
//       return LocationResult.fail(LocationStatus.timeout,
//           message: 'Timed out getting location.');
//     } catch (e) {
//       return LocationResult.fail(LocationStatus.error, message: e.toString());
//     }
//   }

//   Future<LocationPermission> _ensurePermission() async {
//     var perm = await Geolocator.checkPermission();
//     if (perm == LocationPermission.denied) {
//       perm = await Geolocator.requestPermission();
//     }
//     return perm;
//   }

//   Future<bool> openAppSettings() => Geolocator.openAppSettings();
//   Future<bool> openLocationSettings() => Geolocator.openLocationSettings();
// }
