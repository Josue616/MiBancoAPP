import 'package:flutter/material.dart';
import 'package:mibancoemprendedor/Controller/session_manager.dart';
import 'package:mibancoemprendedor/main.dart';

class ClienteScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Página del Cliente"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Bienvenido Cliente"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await SessionManager.clearSession();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              child: Text('Salir'),
            ),
          ],
        ),
      ),
    );
  }
}
