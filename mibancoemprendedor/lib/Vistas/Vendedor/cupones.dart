import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CuponesScreen extends StatefulWidget {
  final String numeroTelefono;

  CuponesScreen({Key? key, required this.numeroTelefono}) : super(key: key);

  @override
  _CuponesScreenState createState() => _CuponesScreenState();
}

class _CuponesScreenState extends State<CuponesScreen> {
  List<dynamic> _tiendas = [];
  String? _tiendaSeleccionada;
  TextEditingController _valorDescuentoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarTiendas();
  }

  Future<void> _cargarTiendas() async {
    var url =
        'http://161.132.37.95:5000/obtener-tiendas/${widget.numeroTelefono}';
    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var datos = json.decode(response.body);
      setState(() {
        _tiendas = datos['tiendas'];
        if (_tiendas.isNotEmpty) {
          _tiendaSeleccionada = _tiendas.first['id'].toString();
        }
      });
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error al cargar tiendas')));
    }
  }

  Future<void> _crearCupon() async {
    if (_tiendaSeleccionada == null || _valorDescuentoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Por favor seleccione una tienda y un valor para el cupón')));
      return;
    }

    var url = 'http://161.132.37.95:5000/agregar-cupon';
    var response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "numero_telefono": widget.numeroTelefono,
        "id_tienda": _tiendaSeleccionada,
        "valor_descuento": _valorDescuentoController.text,
      }),
    );

    if (response.statusCode == 200) {
      var datos = json.decode(response.body);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(datos['message'])));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error al crear cupón')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Generar Cupón'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_tiendas.isNotEmpty)
              DropdownButtonFormField(
                value: _tiendaSeleccionada,
                onChanged: (String? newValue) {
                  setState(() {
                    _tiendaSeleccionada = newValue;
                  });
                },
                items: _tiendas.map<DropdownMenuItem<String>>((dynamic tienda) {
                  return DropdownMenuItem<String>(
                    value: tienda['id'].toString(),
                    child: Text(tienda['nombre']),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Selecciona una tienda',
                  border: OutlineInputBorder(),
                ),
              ),
            SizedBox(height: 20),
            TextField(
              controller: _valorDescuentoController,
              decoration: InputDecoration(
                labelText: 'Valor del descuento',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _crearCupon,
              child: Text('Crear Cupón'),
            ),
          ],
        ),
      ),
    );
  }
}
