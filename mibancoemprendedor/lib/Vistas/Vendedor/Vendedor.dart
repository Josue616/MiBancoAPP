import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mibancoemprendedor/Controller/session_manager.dart';
import 'package:mibancoemprendedor/main.dart';
import 'package:mibancoemprendedor/Vistas/Vendedor/negocio.dart';
import 'package:mibancoemprendedor/Vistas/Vendedor/cupones.dart';
import 'migrar.dart';

class VendedorScreen extends StatefulWidget {
  final String numeroTelefono;

  VendedorScreen({Key? key, required this.numeroTelefono}) : super(key: key);

  @override
  _VendedorScreenState createState() => _VendedorScreenState();
}

class _VendedorScreenState extends State<VendedorScreen> {
  double saldo = 0.0;
  bool isLoading = true;
  List<dynamic> cupones = [];
  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    await _obtenerSaldo();
    await _obtenerCupones();
  }

  Future<void> _obtenerSaldo() async {
    var url =
        'http://161.132.37.95:5000/obtener-saldo/${widget.numeroTelefono}';
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
  }

  Future<void> _obtenerCupones() async {
    var urlCupones =
        'http://161.132.37.95:5000/obtener-cupones/${widget.numeroTelefono}';
    var responseCupones = await http.get(Uri.parse(urlCupones));
    if (responseCupones.statusCode == 200) {
      setState(() {
        cupones = json.decode(responseCupones.body);
      });
    } else {
      _mostrarError('Error al obtener cupones: ${responseCupones.statusCode}');
    }
  }

  Future<void> _refrescarPantalla() async {
    await _obtenerSaldo();
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
      body: RefreshIndicator(
        onRefresh: _cargarDatos,
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView(
                padding: EdgeInsets.all(20),
                children: [
                  _buildSaldo(),
                  _buildBotones(),
                  ..._buildListaCupones(),
                  _buildBotonSalir(),
                ],
              ),
      ),
    );
  }

  Widget _buildSaldo() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Center(
        // Añadido Center para centrar el contenido
        child: Text(
          'Saldo: S/. $saldo',
          textAlign: TextAlign.center, // Alineación del texto centrada
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.green,
            fontStyle: FontStyle.italic,
          ),
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
        _buildRoundButton(
          title: "Cupones",
          icon: Icons.star,
          heroTag: 'cuponesBtn',
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  CuponesScreen(numeroTelefono: widget.numeroTelefono),
            ),
          ),
        ),
        _buildRoundButton(
          title: "Migrar",
          icon: Icons.person,
          heroTag: 'migrarBtn',
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => MigrarScreen(),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildListaCupones() {
    return cupones.map((cupon) {
      return Card(
        child: ListTile(
          title: Text(cupon['nombre_tienda']),
          subtitle: Text('Valor: S/. ${cupon['valor_descuento']}'),
        ),
      );
    }).toList();
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
      child: ElevatedButton(
        onPressed: _logout,
        child: Text('SALIR'),
        style: ElevatedButton.styleFrom(
          primary: Colors.red,
          onPrimary: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
          ),
        ),
      ),
    );
  }

  void _logout() async {
    await SessionManager.clearSession();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }
}
