import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scan Code',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  TextEditingController scannedCode = TextEditingController(text: "QR Code");
  QRViewController? controller;

  @override
  Widget build(BuildContext context) {
    var scanArea = 300.0;
    return Scaffold(
        body: Column(
          children: <Widget>[
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  QRView(
                    key: qrKey,
                    overlay: QrScannerOverlayShape(
                        borderColor: Colors.red,
                        borderRadius: 10,
                        borderLength: 40,
                        borderWidth: 10,
                        cutOutSize: scanArea),
                    onQRViewCreated: _onQRViewCreated,
                  ),
                ],
              ),
            ),
          ],
        ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      controller.pauseCamera();
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("QR code decoded"),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Do you want go to site: ${scanData.code}'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('CANCEL'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('GO!'),
                onPressed: () {
                  Navigator.of(context).pop();
                  _launchUrl(scanData.code ?? "");
                },
              ),
            ],
          );
        },
      );
      controller.resumeCamera();
    });
  }

  void _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      await launchUrl(uri);
    } catch(ex) {
      print(ex);
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
