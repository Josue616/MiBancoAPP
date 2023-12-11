import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class EscanearScreen extends StatefulWidget {
  @override
  _EscanearScreenState createState() => _EscanearScreenState();
}

class _EscanearScreenState extends State<EscanearScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  Barcode? result;

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
        if (result != null) {
          controller.pauseCamera();
          // Asegúrate de que result.code no sea null antes de usarlo
          _showQRPopup(result!.code ?? 'Código QR no encontrado');
        }
      });
    });
  }

  void _showQRPopup(String qrCode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('QR Code'),
        content: Text('El código es: $qrCode'),
        actions: <Widget>[
          TextButton(
            // Aquí se reemplazó FlatButton por TextButton
            child: Text('Cerrar'),
            onPressed: () {
              Navigator.of(context).pop();
              controller?.resumeCamera();
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Escanear QR')),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.red,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: MediaQuery.of(context).size.width * 0.8,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: (result != null)
                  ? Text(
                      'Código de barras Tipo: ${result!.format}   Datos: ${result!.code}')
                  : Text('Escanea un código'),
            ),
          ),
        ],
      ),
    );
  }
}

void main() => runApp(MaterialApp(home: EscanearScreen()));
