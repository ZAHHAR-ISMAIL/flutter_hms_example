import 'package:flutter/material.dart';
import 'package:huawei_map/huawei_map.dart' as huawei;

class MapHmsWidget extends StatefulWidget {
  const MapHmsWidget({super.key});

  @override
  State<MapHmsWidget> createState() => _MapHmsWidgetState();
}

class _MapHmsWidgetState extends State<MapHmsWidget> {
  @override
  void initState() {
    _initHMSMap();
    super.initState();
  }

  void _initHMSMap() {
    huawei.HuaweiMapInitializer.initializeMap();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Map"),
        actions: [
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
      body: const Stack(children: <Widget>[
        huawei.HuaweiMap(
          initialCameraPosition: huawei.CameraPosition(
            target: huawei.LatLng(41.012959, 28.997438),
            zoom: 10,
          ),
          mapType: huawei.MapType.normal,
          // tiltGesturesEnabled: true,
          buildingsEnabled: true,
          compassEnabled: true,
          zoomControlsEnabled: true,
          rotateGesturesEnabled: true,
          myLocationEnabled: true,
        )

        // HuaweiMap(
        //   initialCameraPosition: CameraPosition(
        //     target: LatLng(41.012959, 28.997438),
        //     zoom: 12,
        //   ),
        //   mapType: MapType.normal,
        //   tiltGesturesEnabled: true,
        //   myLocationButtonEnabled: true,
        //   myLocationEnabled: true,
        // )
      ]),
    );
  }
}
