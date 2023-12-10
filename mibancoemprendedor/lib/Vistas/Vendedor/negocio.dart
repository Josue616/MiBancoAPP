import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:latlong2/latlong.dart';

class NegocioScreen extends StatefulWidget {
  final String numeroTelefono;

  NegocioScreen({Key? key, required this.numeroTelefono}) : super(key: key);

  @override
  _NegocioScreenState createState() => _NegocioScreenState();
}

class _NegocioScreenState extends State<NegocioScreen> {
  final _nombreController = TextEditingController();
  final _latitudController = TextEditingController();
  final _longitudController = TextEditingController();
  String _rubroSeleccionado = 'Electrónica y Tecnología';
  LatLng _posicionActual =
      LatLng(-18.013937, -70.250862); // Posición inicial en el mapa

  void _onTap(LatLng position) {
    setState(() {
      _posicionActual = position;
      _latitudController.text = position.latitude.toString();
      _longitudController.text = position.longitude.toString();
    });
  }

  Future<void> _agregarNegocio() async {
    var url = 'http://161.132.37.95:5000/agregar-negocio';
    var response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "numero_telefono": widget.numeroTelefono,
        "nombre": _nombreController.text,
        "latitud": _latitudController.text,
        "longitud": _longitudController.text,
        "rubro": _rubroSeleccionado,
      }),
    );

    if (response.statusCode == 200) {
      final datos = json.decode(response.body);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(datos['message'])));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error al agregar negocio')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Agregar Negocio"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextField(
                controller: _nombreController,
                decoration: InputDecoration(labelText: 'Nombre del Negocio'),
              ),
              SizedBox(height: 10),
              Container(
                height: 300,
                child: FlutterMap(
                  options: MapOptions(
                    center: _posicionActual,
                    zoom: 13.0,
                    onTap: (_, position) => _onTap(position),
                  ),
                  layers: [
                    TileLayerOptions(
                      urlTemplate:
                          "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: ['a', 'b', 'c'],
                    ),
                    MarkerLayerOptions(
                      markers: [
                        Marker(
                          point: _posicionActual,
                          builder: (context) => Icon(
                            Icons.location_on,
                            size: 40.0,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _latitudController,
                decoration: InputDecoration(labelText: 'Latitud'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              TextField(
                controller: _longitudController,
                decoration: InputDecoration(labelText: 'Longitud'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              DropdownButton<String>(
                value: _rubroSeleccionado,
                onChanged: (String? newValue) {
                  setState(() {
                    _rubroSeleccionado = newValue!;
                  });
                },
                items: <String>[
                  'Electrónica y Tecnología',
                  'Moda y Accesorios',
                  'Alimentos y Bebidas',
                  'Salud y Belleza',
                  'Deportes y Entretenimiento',
                  'Juguetes y Juegos',
                  'Libros y Educación',
                  'Hogar y Jardinería',
                  'Automotriz y Herramientas',
                  'Arte y Artesanía',
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              ElevatedButton(
                onPressed: _agregarNegocio,
                child: Text('Agregar Negocio'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
