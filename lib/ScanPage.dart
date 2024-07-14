import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:huawei_scan/huawei_scan.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  String? resultScan;
  int? codeFormatScan;
  int? resultTypeScan;

  @override
  void initState() {
    super.initState();
  }

  void requestScanPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.storage,
    ].request();

    if (await Permission.camera.status.isGranted) {
      try {
        DefaultViewRequest request = DefaultViewRequest(
          scanType: HmsScanTypes.AllScanType,
          viewType: 1,
          errorCheck: true,
        );
        ScanResponse response = await HmsScanUtils.startDefaultView(request);
        setState(() {
          resultScan = response.originalValue;
          codeFormatScan = response.scanType;
          resultTypeScan = response.scanTypeForm;
        });
      } on PlatformException catch (err) {
        if (err.code == HmsScanErrors.scanUtilNoCameraPermission.errorCode) {
          debugPrint(HmsScanErrors.scanUtilNoCameraPermission.errorMessage);
        }
      }
    } else {
      openAppSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Scan Results: ',
            ),
            Text(
              '$resultScan',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              '$codeFormatScan',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              '$resultTypeScan',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            ElevatedButton(
              child: const Text('Scan Qr'),
              onPressed: () {
                requestScanPermissions();
              },
            ),
          ],
        ),
      ),
    );
  }
}
