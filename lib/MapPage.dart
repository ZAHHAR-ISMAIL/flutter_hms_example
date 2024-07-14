import 'package:flutter/material.dart';
import 'package:flutter_hms_example/components/MapGms.dart';
import 'package:flutter_hms_example/components/MapHms.dart';
import 'package:flutter_hms_gms_availability/flutter_hms_gms_availability.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  bool gms = false, hms = false;

  @override
  void initState() {
    super.initState();

    FlutterHmsGmsAvailability.isGmsAvailable.then((t) {
      setState(() {
        gms = t;
      });
    });
    FlutterHmsGmsAvailability.isHmsAvailable.then((t) {
      setState(() {
        hms = t;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (hms == true && gms == false) {
      return const MapHmsWidget();
    } else {
      return const MapGmsWidget();
    }
  }
}
