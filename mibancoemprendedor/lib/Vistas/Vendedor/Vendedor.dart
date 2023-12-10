import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mibancoemprendedor/Controller/session_manager.dart';
import 'package:mibancoemprendedor/Vistas/Vendedor/explorar.dart';
import 'package:mibancoemprendedor/main.dart';
import 'package:mibancoemprendedor/Vistas/Vendedor/negocio.dart';
import 'package:mibancoemprendedor/Vistas/Vendedor/cupones.dart';
import 'escanear.dart';

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

  void _mostrarDialogoMigrarCupon(int idCupon) {
    TextEditingController numeroTelefonoController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Migrar Cupón'),
          content: TextField(
            controller: numeroTelefonoController,
            decoration: InputDecoration(hintText: "Ingrese número de teléfono"),
            keyboardType: TextInputType.number,
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Migrar'),
              onPressed: () {
                _migrarCupon(idCupon, numeroTelefonoController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _cargarDatos() async {
    await _obtenerSaldo();
    await _obtenerCupones();
  }

  Future<void> _migrarCupon(int idCupon, String numeroTelefono) async {
    var url = 'http://161.132.37.95:5000/migrar-cupon';
    var response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "id_cupon": idCupon,
        "numero_telefono": numeroTelefono,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Cupón migrado con éxito')));
      _refrescarPantalla();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error al migrar cupón')));
    }
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
                  SizedBox(
                      height: 10), // Espacio agregado entre saldo y botones
                  _buildBotones(),
                  SizedBox(
                      height:
                          10), // Espacio agregado entre botones y lista de cupones
                  _buildListaCuponesConScroll(), // Lista de cupones con scroll propio
                  _buildBotonSalir(),
                ],
              ),
      ),
    );
  }

  Widget _buildSaldo() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Column(
        mainAxisSize: MainAxisSize
            .min, // Para que la columna ocupe solo el espacio necesario
        children: [
          Text(
            'Saldo Disponible', // Texto adicional encima del saldo
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12, // Tamaño de texto más pequeño
              fontWeight: FontWeight.bold,
              color: Colors.grey, // Color gris para el texto "Saldo"
            ),
          ),
          Text(
            'S/. $saldo', // Texto del saldo
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.bold,
              color: Colors.green,
              // fontStyle removido para no tener texto en cursiva
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotones() {
    return Wrap(
      spacing: 0, // Espacio horizontal entre los botones
      runSpacing: 10, // Espacio vertical entre las líneas
      alignment: WrapAlignment.spaceEvenly,
      children: <Widget>[
        _buildRoundButton(
          title: "Negocios",
          subtitle: "Crear Negocio",
          icon: Icons
              .store, // Cambiado a un icono más representativo para "Negocios"
          iconColor: Colors.green,
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
          subtitle: "Crear Cupón",
          icon: Icons
              .local_offer, // Cambiado a un icono más representativo para "Cupones"
          iconColor: Colors.green,
          heroTag: 'cuponesBtn',
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  CuponesScreen(numeroTelefono: widget.numeroTelefono),
            ),
          ),
        ),
        /*_buildRoundButton(
          title: "Migrar",
          subtitle: "Enviar Cupón",
          icon: Icons
              .send, // Cambiado a un icono más representativo para "Migrar"
          iconColor: Colors.green,
          heroTag: 'migrarBtn',
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => MigrarScreen(),
            ),
          ),
        ),*/
        // Nuevo botón para Escanear Cupón
        _buildRoundButton(
          title: "Escanear",
          subtitle: "Escanear Cupón",
          icon: Icons.qr_code_scanner,
          iconColor: Colors.green,
          heroTag: 'escanearCuponBtn',
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => EscanearScreen(),
            ),
          ),
        ),
        // Nuevo botón para Explorar
        _buildRoundButton(
          title: "Explorar",
          subtitle: "Explorar",
          icon: Icons.explore,
          iconColor: Colors.green,
          heroTag: 'explorarBtn',
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ExplorarScreen(),
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
    required String subtitle, // Subtítulo añadido
    required IconData icon,
    required Color iconColor, // Color del ícono añadido
    required String heroTag,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          backgroundColor:
              Color.fromARGB(255, 252, 252, 252), // Color del botón
          onPressed: onPressed,
          child: Icon(icon, color: iconColor), // Color del ícono aplicado
          tooltip: title,
          heroTag: heroTag,
        ),
        SizedBox(height: 8), // Espacio entre el botón y el texto
        Text(
          subtitle, // Texto debajo del botón
          style: TextStyle(
            color: Colors.grey, // Color del texto
            fontSize: 12, // Tamaño del texto
          ),
        ),
      ],
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

  Widget _buildListaCuponesConScroll() {
    double cuponesHeight = 300.0; // Ajusta según necesidades

    return Container(
      height: cuponesHeight,
      child: ListView.builder(
        itemCount: cupones.length,
        itemBuilder: (context, index) {
          var cupon = cupones[index];
          return Card(
            child: ListTile(
              title: Text(cupon['nombre_tienda']),
              subtitle: Text('Valor: S/. ${cupon['valor_descuento']}'),
              onTap: () => _mostrarDialogoMigrarCupon(cupon['id_cupon']),
            ),
          );
        },
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
