import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hms_example/components/Loading.dart';
import 'package:huawei_location/huawei_location.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  double? _lat = 0.0;
  double? _long = 0.0;

  final FusedLocationProviderClient _locationService =
      FusedLocationProviderClient();
  final LocationRequest _locationRequest = LocationRequest()..interval = 500;

  late LocationSettingsRequest _locationSettingsRequest;

  @override
  void initState() {
    super.initState();
    _locationSettingsRequest =
        LocationSettingsRequest(requests: <LocationRequest>[_locationRequest]);
    // _requestPermission();
  }

  void _getLastLocation() async {
    debugPrint("HMSO::03");
    LoadingIndicatorDialog().show(context);
    try {
      final LocationSettingsStates states = await _locationService
          .checkLocationSettings(_locationSettingsRequest);
      final Location location = await _locationService.getLastLocation();
      _setLatitude(location.latitude);
      _setLongitude(location.longitude);
      LoadingIndicatorDialog().dismiss();
    } on PlatformException catch (e) {
      debugPrint("HMSO::3x");
      LoadingIndicatorDialog().dismiss();
    }
  }

  void _setLatitude([double? n = 0.0]) {
    setState(() {
      _lat = n;
    });
  }

  void _setLongitude([double? n = 0.0]) {
    setState(() {
      _long = n;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Latitude',
            ),
            Text(
              '$_lat',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const Text(
              'Longitude',
            ),
            Text(
              '$_long',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            ElevatedButton(
              child: const Text('get Location'),
              onPressed: () {
                _getLastLocation();
              },
            ),
          ],
        ),
      ),
    );
  }
}
