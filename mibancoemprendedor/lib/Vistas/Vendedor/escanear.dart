import 'package:flutter/material.dart';
import 'package:barcode_scan2/barcode_scan2.dart';

class EscanearScreen extends StatefulWidget {
  @override
  _EscanearScreenState createState() => _EscanearScreenState();
}

class _EscanearScreenState extends State<EscanearScreen> {
  String qrCodeResult = "No escaneado aún";

  Future<void> _scanQR() async {
    try {
      var result = await BarcodeScanner.scan();
      setState(() => qrCodeResult = result.rawContent);
    } catch (e) {
      setState(() => qrCodeResult = 'Error: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Escanear QR"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Resultado del Escaneo",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              qrCodeResult,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () => _scanQR(),
              child: Text("Escanear QR"),
              style: TextButton.styleFrom(
                primary: Colors.white, // Color del texto
                backgroundColor: Colors.blue, // Color del fondo
              ),
            )
          ],
        ),
      ),
    );
  }
}
