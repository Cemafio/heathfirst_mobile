import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class GoogleMapPage extends StatefulWidget {
  const GoogleMapPage({super.key});
  @override
  State<GoogleMapPage> createState() => _GoogleMapPageState();
}

class _GoogleMapPageState extends State<GoogleMapPage> {
  late GoogleMapController mapController;
  LatLng? _currentPosition; // Antananarivo

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> _getCurrentLocation() async {
    // Vérifier et demander les permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    // Obtenir la position actuelle
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });

    // Déplacer la caméra
    mapController.animateCamera(
      CameraUpdate.newLatLngZoom(_currentPosition!, 12),
    );
  }

  Widget build(BuildContext context) {

    return _currentPosition == null
      ? const Center(child: CircularProgressIndicator())
      : Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          clipBehavior: Clip.none,

        children: [
          Safearea(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _currentPosition!,
                zoom: 12.0,
              ),
              myLocationEnabled: true, // Activer le bouton localisation
              myLocationButtonEnabled: true,
              
            ),
          ),
          
          Positioned(
            top: 40,
            left: 10,
            child: GestureDetector(
              onTap: (){
                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(bottom: 5),

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  // border: Border.all(),
                  color: Color.fromARGB(97, 107, 107, 107)
                ),

                child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white,),
              ),
            )
          ),
        ]
      ),
  
    );
  }
}
