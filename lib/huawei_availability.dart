import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:huawei_hmsavailability/huawei_hmsavailability.dart';

class HuaweiAvailability {
  HuaweiAvailability({HmsApiAvailability? api})
      : hmsApiAvailability = api ?? HmsApiAvailability();

  final HmsApiAvailability hmsApiAvailability;
  String _result = 'HMS availability result code: unknown';
  final List<String> _eventList = <String>[
    'Availability result events will be listed'
  ];

  String get result => _result;
  List<String> get events => List.unmodifiable(_eventList);

  /// Returns true only if the device looks like a Huawei/Honor Android device
  /// and HMS core reports available.
  Future<bool> isHuaweiWithHms({
    int dialogRequestCode = 1000,
    bool showDialog = false,
  }) async {
    if (!Platform.isAndroid) return false;

    final info = await DeviceInfoPlugin().androidInfo;
    final brand = info.brand?.toLowerCase() ?? '';
    final manufacturer = info.manufacturer?.toLowerCase() ?? '';
    final isHuaweiBrand =
        brand.contains('huawei') || manufacturer.contains('huawei');
    if (!isHuaweiBrand) return false;

    return checkAvailability(
      dialogRequestCode: dialogRequestCode,
      showDialog: showDialog,
    );
  }

  Future<bool> checkAvailability({
    int dialogRequestCode = 1000,
    bool showDialog = true,
  }) async {
    try {
      final int resultCode = await hmsApiAvailability.isHMSAvailable();
      _result = 'HMS availability result code: $resultCode';

      if (resultCode != 0) {
        hmsApiAvailability.setResultListener = (AvailabilityEvent? event) {
          if (event != null) {
            _eventList.add('Availability event: ${describeEnum(event)}');
          }
        };
        if (showDialog) {
          hmsApiAvailability.getErrorDialog(
            resultCode,
            dialogRequestCode,
            true,
          );
        }
        return false;
      }
      return true;
    } catch (e) {
      _eventList.add('$e');
      _result = 'HMS availability result error: $e';
      return false;
    }
  }
}
