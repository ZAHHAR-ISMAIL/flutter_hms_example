import 'dart:async';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:huawei_location/huawei_location.dart';

class HmsLocException implements Exception {
  final String message;
  const HmsLocException(this.message);
  @override
  String toString() => message;
}

class HmsLocServiceDisabled extends HmsLocException {
  const HmsLocServiceDisabled() : super('Location services are disabled.');
}

class HmsLocPermissionDenied extends HmsLocException {
  const HmsLocPermissionDenied() : super('Location permission denied.');
}

class HmsLocPermissionDeniedForever extends HmsLocException {
  const HmsLocPermissionDeniedForever()
      : super('Location permission denied forever.');
}

class HmsLocationHelper {
  final FusedLocationProviderClient _client = FusedLocationProviderClient();
  bool _inited = false;

  Future<void> init() async {
    if (_inited) return;
    await _client.initFusedLocationService();
    _inited = true;
  }

  // Open settings without permission_handler
  Future<bool> openAppSettings() => Geolocator.openAppSettings();
  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();

  Future<void> ensureReady() async {
    await init();

    // Permission (use geolocator like you asked)
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied) throw const HmsLocPermissionDenied();
    if (perm == LocationPermission.deniedForever) {
      throw const HmsLocPermissionDeniedForever();
    }

    // Device location enabled (HMS way)
    final ok = await _isHmsLocationUsable();
    if (!ok) throw const HmsLocServiceDisabled();
  }

  /// Cached only. HMS: does NOT proactively request location (uses cache). :contentReference[oaicite:3]{index=3}
  Future<Location?> getLastKnown(
      {Duration maxAge = const Duration(minutes: 5)}) async {
    await ensureReady();

    final loc = await _client.getLastLocation();
    if (!_looksValid(loc)) return null;

    final now = DateTime.now().millisecondsSinceEpoch;
    final locTime = loc.time;
    if (locTime == null) return null;
    final ageMs = now - locTime;
    if (ageMs < 0 || ageMs > maxAge.inMilliseconds) return null;

    return loc;
  }

  /// One-shot update (NOT continuous): request numUpdates=1 then stop.
  Future<Location> getCurrentOnce({
    Duration timeout = const Duration(seconds: 14),
  }) async {
    await init();

    final stream = _client.onLocationData;
    if (stream == null) {
      throw const HmsLocException(
        'HMS onLocationData is null. Make sure service is initialized.',
      );
    }

    final req = LocationRequest()
      ..interval = 500
      ..priority = LocationRequest.PRIORITY_HIGH_ACCURACY;
    // Don’t rely on numUpdates=1 alone — we remove updates ourselves after first hit.

    final completer = Completer<Location>();
    StreamSubscription<Location>? sub;
    int? requestCode;

    try {
      // 1) Listen first (same as Huawei sample)
      sub = stream.listen((loc) {
        if (!completer.isCompleted && _looksValid(loc)) {
          completer.complete(loc);
        }
      });

      // 2) Request updates
      requestCode = await _client.requestLocationUpdates(req);
      if (requestCode == null) {
        throw const HmsLocException('requestLocationUpdates returned null.');
      }

      // 3) Wait for first location
      return await completer.future.timeout(timeout);
    } on TimeoutException {
      throw const HmsLocException('Timeout getting HMS location.');
    } on PlatformException catch (e) {
      throw HmsLocException(e.message ?? e.toString());
    } finally {
      // 4) Always cleanup
      await sub?.cancel();
      if (requestCode != null) {
        try {
          await _client.removeLocationUpdates(requestCode);
        } catch (_) {}
      }
    }
  }

  /// What your Map screen should call:
  /// lastKnown (fast) -> currentOnce (fresh)
  Future<Location> getForMap() async {
    final last = await getLastKnown();
    if (last != null) return last;
    return getCurrentOnce();
  }

  Future<bool> _isHmsLocationUsable() async {
    final req = LocationRequest()
      ..priority = LocationRequest.PRIORITY_HIGH_ACCURACY;
    final settingsReq =
        LocationSettingsRequest(requests: <LocationRequest>[req]);

    try {
      final states = await _client.checkLocationSettings(
          settingsReq); // :contentReference[oaicite:8]{index=8}
      // These fields exist in the plugin docs. :contentReference[oaicite:9]{index=9}
      return (states.locationUsable == true) ||
          (states.gpsUsable == true) ||
          (states.networkLocationUsable == true);
    } catch (_) {
      return false;
    }
  }

  bool _looksValid(Location loc) {
    // Docs: if no lat/long available, 0.0 is returned. :contentReference[oaicite:10]{index=10}
    return !(loc.latitude == 0.0 && loc.longitude == 0.0);
  }
}
