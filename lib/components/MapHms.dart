import 'package:flutter/material.dart';
import 'package:huawei_map/huawei_map.dart';

class MapHmsWidget extends StatefulWidget {
  const MapHmsWidget({super.key});

  @override
  State<MapHmsWidget> createState() => _MapHmsWidgetState();
}

class _MapHmsWidgetState extends State<MapHmsWidget> {
  late HuaweiMapController mapController;

  @override
  void initState() {
    _initHMSMap();
    super.initState();
  }

  void _initHMSMap() {
    HuaweiMapInitializer.initializeMap();
  }

  void _onMapCreated(HuaweiMapController controller) {
    mapController = controller;
  }

  void animateMap() {
    CameraUpdate cameraUpdate = CameraUpdate.newCameraPosition(
        const CameraPosition(
            bearing: 2.2, target: LatLng(1, 1), tilt: 13, zoom: 13));
    mapController.animateCamera(cameraUpdate);
  }

  void _showToast(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: const Text('onCameraIdle'),
        action: SnackBarAction(
            label: 'UNDO', onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Map"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_to_drive),
            tooltip: 'Animate Camera',
            onPressed: () {
              // handle the press
              animateMap();
            },
          ),
          IconButton(
            icon: const Icon(Icons.location_on),
            tooltip: 'Open Location',
            onPressed: () {
              // handle the press
              Navigator.pushNamed(context, '/LocationPage');
            },
          ),
        ],
      ),
      body: Stack(children: <Widget>[
        HuaweiMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(41.012959, 28.997438),
              zoom: 10,
            ),
            onMapCreated: _onMapCreated,
            mapType: MapType.normal,
            // tiltGesturesEnabled: true,
            buildingsEnabled: true,
            compassEnabled: true,
            zoomControlsEnabled: true,
            rotateGesturesEnabled: true,
            myLocationEnabled: true,
            onCameraIdle: () {
              _showToast(context);
            })
      ]),
    );
  }
}
