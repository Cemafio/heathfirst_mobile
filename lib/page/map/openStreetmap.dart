import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class OSMMapPage extends StatelessWidget {
  const OSMMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Carte OSM')),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(-18.8792, 47.5079), // ex : Tana Madagascar
          initialZoom: 13,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(-18.8792, 47.5079),
                width: 80,
                height: 80,
                child: const Icon(Icons.location_on, color: Colors.red, size: 40),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
