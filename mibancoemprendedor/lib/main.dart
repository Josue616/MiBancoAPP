import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'Vistas/Vendedor/Vendedor.dart';
import 'Vistas/Cliente/cliente.dart';

void main() {
  runApp(MiApp());
}

class MiApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi Banco Emprendedor',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: FutureBuilder<Map<String, dynamic>>(
        future: _getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else {
            String? userType = snapshot.data?['userType'];
            if (userType == 'Cliente') {
              return ClienteScreen();
            } else if (userType == 'Vendedor') {
              String numeroTelefono = snapshot.data?['numeroTelefono'] ?? '';
              return VendedorScreen(numeroTelefono: numeroTelefono);
            }
            return LoginScreen();
          }
        },
      ),
    );
  }

  Future<Map<String, dynamic>> _getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return {
      'userType': prefs.getString('userType') ?? '',
      'numeroTelefono': prefs.getString('numeroTelefono') ?? '',
    };
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    var response = await http.post(
      Uri.parse('http://161.132.37.95:5000/login'),
      body: {
        'numero_telefono': _phoneController.text,
        'contrasena': _passwordController.text,
      },
    );

    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      var userType = responseBody['user']['TipoUsuario'];
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('userType', userType);
      await prefs.setString('numeroTelefono', _phoneController.text);

      if (userType == 'Cliente') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => ClienteScreen()),
        );
      } else if (userType == 'Vendedor') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (context) =>
                  VendedorScreen(numeroTelefono: _phoneController.text)),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error en el login'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Colors.white, Colors.green.withOpacity(0.2)],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'MiBanco',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              Text(
                'EMPRENDEDOR',
                style: TextStyle(
                  fontSize: 24,
                  fontStyle: FontStyle.italic,
                  color: Colors.yellow,
                ),
              ),
              SizedBox(height: 30),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Número de Celular',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                child: Text('Iniciar Sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
