import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapGmsWidget extends StatefulWidget {
  const MapGmsWidget({super.key});

  @override
  State<MapGmsWidget> createState() => _MapGmsWidgetState();
}

class _MapGmsWidgetState extends State<MapGmsWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text("Map"),
        ),
        body: GoogleMap(
          mapType: MapType.terrain,
          myLocationEnabled: true,
          trafficEnabled: true,
          compassEnabled: true,
          initialCameraPosition: const CameraPosition(
              target: LatLng(39.92516916823261, 32.83695462676608), zoom: 12),
          markers: <Marker>{
            const Marker(
                markerId: MarkerId("1"),
                position: LatLng(39.92516916823261, 32.83695462676608))
          },
        ),
      ),
    );
  }
}
