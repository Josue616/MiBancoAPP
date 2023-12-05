import 'package:flutter/material.dart';

class ClienteScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Página del Cliente"),
      ),
      body: Center(
        child: Text("Bienvenido Cliente"),
      ),
    );
  }
}
