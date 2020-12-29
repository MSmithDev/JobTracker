import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

void main() {
  runApp(MaterialApp(
    title: 'Scan Job Folder',
    home: ScanPage(),
  ));
}



class ScanPage extends StatefulWidget {


  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  QRViewController controller;


  Barcode result;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  int _counter = 0;

  void _incrementCounter() {
    setState(() {

      _counter++;
    });
  }
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller.pauseCamera();
    } else if (Platform.isIOS) {
      controller.resumeCamera();
    }
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.

      ),
      body: Center(

        child: Column(

          children: <Widget>[
            Expanded(flex: 4, child: _buildQrView(context)),
            Text(
              'Scan a job folder to begin',
              style: TextStyle(fontSize: 62),
            ),


          ],
        ),
      ),
    );
  }
  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
        MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return NotificationListener<SizeChangedLayoutNotification>(
        onNotification: (notification) {
          Future.microtask(
                  () => controller?.updateDimensions(qrKey, scanArea: scanArea));
          return false;
        },
        child: SizeChangedLayoutNotifier(
            key: const Key('qr-size-notifier'),
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.red,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: scanArea,
              ),
            )));
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      controller.pauseCamera();
      Navigator.push(context, MaterialPageRoute(builder: (context) => JobPage(scannedCode: scanData,)));

      // setState(() {
      //
      //   result = scanData;
      // });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class JobPage extends StatefulWidget {
  final Barcode scannedCode;
  JobPage({Key key, @required this.scannedCode}) : super(key: key);

  @override
  _JobPageState createState() => _JobPageState();
}

class _JobPageState extends State<JobPage> {


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("Job Info"),
      ),
      body: Text(widget.scannedCode.code),
    );
  }




}