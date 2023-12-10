import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class ExplorarScreen extends StatefulWidget {
  ExplorarScreen({Key? key}) : super(key: key);

  @override
  _ExplorarScreenState createState() => _ExplorarScreenState();
}

class _ExplorarScreenState extends State<ExplorarScreen> {
  final List<Map<String, dynamic>> negocios = [
    {
      'nombre': 'Electrónica Central',
      'rubro': 'Electrónica y Tecnología',
      'celular': '555-1234',
      'coordenadas': LatLng(-18.013937, -70.250862),
    },
    {
      'nombre': 'Moda Moderna',
      'rubro': 'Moda y Accesorios',
      'celular': '555-5678',
      'coordenadas': LatLng(-18.023937, -70.255862),
    },
    {
      'nombre': 'Sabores del Valle',
      'rubro': 'Alimentos y Bebidas',
      'celular': '555-8765',
      'coordenadas': LatLng(-18.033937, -70.245862),
    },
    {
      'nombre': 'Cuidado y Belleza',
      'rubro': 'Salud y Belleza',
      'celular': '555-4321',
      'coordenadas': LatLng(-18.043937, -70.251862),
    },
    {
      'nombre': 'Deportes Aventura',
      'rubro': 'Deportes y Entretenimiento',
      'celular': 'Número no disponible',
      'coordenadas': LatLng(-18.053937, -70.240862),
    },
    {
      'nombre': 'Juguetería Girasol',
      'rubro': 'Juguetes y Juegos',
      'celular': '555-9988',
      'coordenadas': LatLng(-18.063937, -70.265862),
    },
    {
      'nombre': 'Librería Educate',
      'rubro': 'Libros y Educación',
      'celular': 'Número no disponible',
      'coordenadas': LatLng(-18.073937, -70.250862),
    },
    {
      'nombre': 'Hogar Feliz',
      'rubro': 'Hogar y Jardinería',
      'celular': '555-7788',
      'coordenadas': LatLng(-18.058937, -70.255862),
    },
    {
      'nombre': 'Auto Todo',
      'rubro': 'Automotriz y Herramientas',
      'celular': 'Número no disponible',
      'coordenadas': LatLng(-18.050937, -70.248862),
    },
    {
      'nombre': 'Arte Pincel',
      'rubro': 'Arte y Artesanía',
      'celular': '555-1122',
      'coordenadas': LatLng(-18.065937, -70.242862),
    },
    // Puedes añadir más negocios aquí
  ];

  void _showPopup(BuildContext context, Map<String, dynamic> negocio) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(negocio['nombre']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Rubro: ${negocio['rubro']}'),
            Text('Celular: ${negocio['celular']}'),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Cerrar'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Explorar Negocios"),
      ),
      body: FlutterMap(
        options: MapOptions(
          center: LatLng(-18.013937, -70.250862), // Centrado inicial en el mapa
          zoom: 13.0,
        ),
        layers: [
          TileLayerOptions(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayerOptions(
            markers: negocios.map((negocio) {
              return Marker(
                width: 80.0,
                height: 80.0,
                point: negocio['coordenadas'],
                builder: (ctx) => IconButton(
                  icon: Icon(Icons.location_on),
                  color: Colors.red,
                  iconSize: 40.0,
                  onPressed: () => _showPopup(context, negocio),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Explorar Negocios',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ExplorarScreen(),
    );
  }
}
