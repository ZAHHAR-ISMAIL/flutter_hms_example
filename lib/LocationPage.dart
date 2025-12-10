import 'package:flutter/material.dart';
import 'package:flutter_hms_example/components/Loading.dart';
import 'package:flutter_hms_example/location_helper/location_helper_HMS.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  double? _lat;
  double? _long;

  final _loc = HmsLocationHelper();

  Future<void> _getLocation() async {
    LoadingIndicatorDialog().show(context);
    try {
      final l = await _loc.getForMap();
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
        action: _loc.openLocationSettings,
      );
    } on HmsLocPermissionDeniedForever {
      await _showDialog(
        title: 'Permission needed',
        msg: 'Enable location permission from App Settings.',
        button: 'Open App Settings',
        action: _loc.openAppSettings,
      );
    } on HmsLocPermissionDenied {
      _snack('Permission denied. Tap again and allow it.');
    } catch (e) {
      _snack('Location error: $e');
    } finally {
      if (mounted) LoadingIndicatorDialog().dismiss();
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
