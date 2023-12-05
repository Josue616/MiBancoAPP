import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mibancoemprendedor/Controller/session_manager.dart';
import 'package:mibancoemprendedor/main.dart';
import 'package:mibancoemprendedor/Vistas/Vendedor/negocio.dart';

class VendedorScreen extends StatefulWidget {
  final String numeroTelefono;

  VendedorScreen({Key? key, required this.numeroTelefono}) : super(key: key);

  @override
  _VendedorScreenState createState() => _VendedorScreenState();
}

class _VendedorScreenState extends State<VendedorScreen> {
  double saldo = 0.0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _obtenerSaldo();
  }

  Future<void> _obtenerSaldo() async {
    var url =
        'http://161.132.37.95:5000/obtener-saldo/${widget.numeroTelefono}';
    try {
      var response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var datos = json.decode(response.body);
        setState(() {
          saldo = double.tryParse(datos['saldo'] ?? '0.0') ?? 0.0;
          isLoading = false;
        });
      } else {
        _mostrarError('Error al obtener el saldo: ${response.statusCode}');
      }
    } catch (e) {
      _mostrarError('Excepción al obtener el saldo: $e');
    }
  }

  void _mostrarError(String mensaje) {
    setState(() {
      isLoading = false;
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensaje)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 20),
                _buildSaldo(),
                _buildBotones(),
                SizedBox(height: 20),
                _buildBotonSalir(),
              ],
            ),
    );
  }

  Widget _buildSaldo() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Text(
        'Saldo: S/. $saldo',
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.green,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _buildBotones() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        _buildRoundButton(
          title: "Negocios",
          icon: Icons.business,
          heroTag: 'negociosBtn',
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  NegocioScreen(numeroTelefono: widget.numeroTelefono),
            ),
          ),
        ),
        // ... [Otros botones]
      ],
    );
  }

  Widget _buildRoundButton({
    required String title,
    required IconData icon,
    required String heroTag,
    required VoidCallback onPressed,
  }) {
    return FloatingActionButton(
      onPressed: onPressed,
      child: Icon(icon),
      tooltip: title,
      heroTag: heroTag,
    );
  }

  Widget _buildBotonSalir() {
    return ElevatedButton(
      onPressed: _logout,
      child: Text('SALIR'),
      style: ElevatedButton.styleFrom(
        primary: Colors.red,
        onPrimary: Colors.white,
      ),
    );
  }

  void _logout() async {
    print("Iniciando cierre de sesión");
    await SessionManager.clearSession();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }
}
