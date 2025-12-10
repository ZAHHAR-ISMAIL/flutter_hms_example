import 'package:flutter/material.dart';
import 'package:flutter_hms_example/components/Loading.dart';
import 'package:flutter_hms_example/location_helper/location_helper_HMS.dart';
import 'package:flutter_hms_example/location_helper/location_helper_GMS.dart';
import 'package:flutter_hms_example/huawei_availability.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  double? _lat;
  double? _long;

  final _hmsHelper = HmsLocationHelper();
  final _gmsHelper = const LocationHelper();
  final _hmsAvailability = HuaweiAvailability();

  Future<void> _getLocation() async {
    LoadingIndicatorDialog().show(context);
    try {
      final useHms = await _hmsAvailability.isHuaweiWithHms(showDialog: false);
      if (useHms) {
        await _getHmsLocationSafe();
      } else {
        await _getGmsLocationSafe();
      }
    } catch (e) {
      _snack('Location error: $e');
    } finally {
      if (mounted) LoadingIndicatorDialog().dismiss();
    }
  }

  Future<void> _getHmsLocationSafe() async {
    try {
      final l = await _hmsHelper.getForMap();
      if (!mounted) return;
      setState(() {
        _lat = l.latitude;
        _long = l.longitude;
      });
    } on HmsLocServiceDisabled {
      await _showDialog(
        title: 'Location is OFF',
        msg: 'Enable device location (GPS) to show your marker.',
        button: 'Open Location Settings',
        action: _hmsHelper.openLocationSettings,
      );
    } on HmsLocPermissionDeniedForever {
      await _showDialog(
        title: 'Permission needed',
        msg: 'Enable location permission from App Settings.',
        button: 'Open App Settings',
        action: _hmsHelper.openAppSettings,
      );
    } on HmsLocPermissionDenied {
      _snack('Permission denied. Tap again and allow it.');
    }
  }

  Future<void> _getGmsLocationSafe() async {
    final res = await _gmsHelper.getForMap();
    if (!mounted) return;
    switch (res.status) {
      case LocationStatus.ok:
        setState(() {
          _lat = res.position?.latitude;
          _long = res.position?.longitude;
        });
        break;
      case LocationStatus.serviceDisabled:
        await _showDialog(
          title: 'Location is OFF',
          msg: 'Enable device location (GPS) to show your marker.',
          button: 'Open Location Settings',
          action: _gmsHelper.openLocationSettings,
        );
        break;
      case LocationStatus.permissionDeniedForever:
        await _showDialog(
          title: 'Permission needed',
          msg: 'Enable location permission from App Settings.',
          button: 'Open App Settings',
          action: _gmsHelper.openAppSettings,
        );
        break;
      case LocationStatus.permissionDenied:
        _snack('Permission denied. Tap again and allow it.');
        break;
      case LocationStatus.timeout:
        _snack('Timed out getting location.');
        break;
      case LocationStatus.error:
        _snack(res.message ?? 'Location error');
        break;
    }
  }

  void _snack(String s) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s)));

  Future<void> _showDialog({
    required String title,
    required String msg,
    required String button,
    required Future<bool> Function() action,
  }) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(msg),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await action();
              if (mounted) Navigator.pop(context);
            },
            child: Text(button),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Location Page')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Latitude'),
            Text('${_lat ?? "-"}',
                style: Theme.of(context).textTheme.headlineMedium),
            const Text('Longitude'),
            Text('${_long ?? "-"}',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _getLocation,
              child: const Text('get Location'),
            ),
          ],
        ),
      ),
    );
  }
}
