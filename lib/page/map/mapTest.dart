import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';

class SearchMapPage extends StatefulWidget {
  const SearchMapPage({super.key});

  @override
  State<SearchMapPage> createState() => _SearchMapPageState();
}

class _SearchMapPageState extends State<SearchMapPage> {
  late GoogleMapController mapController;
  LatLng _initialPosition = const LatLng(-18.8792, 47.5079); // Tana
  Set<Marker> _markers = {};

  final String googleApiKey = "TA_CLE_API_GOOGLE";

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _goToPlace(double lat, double lng, String description) {
    setState(() {
      _markers.clear();
      _markers.add(
        Marker(
          markerId: MarkerId(description),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(title: description),
        ),
      );
    });

    mapController.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(lat, lng), 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: 12,
            ),
            markers: _markers,
          ),

          Positioned(
            top: 40,
            left: 15,
            right: 15,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: GooglePlaceAutoCompleteTextField(
                textEditingController: TextEditingController(),
                googleAPIKey: googleApiKey,
                inputDecoration: const InputDecoration(
                  hintText: "Rechercher un lieu...",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(10),
                ),
                debounceTime: 800,
                countries: ["mg"], // Limiter aux pays (MG = Madagascar)
                isLatLngRequired: true,
                getPlaceDetailWithLatLng: (prediction) {
                   final lat = double.tryParse(prediction.lat.toString());
                    final lng = double.tryParse(prediction.lng.toString());

                    if (lat != null && lng != null) {
                      _goToPlace(lat, lng, prediction.description ?? "Lieu");
                    } else {
                      print("⚠️ Impossible de récupérer la latitude/longitude depuis prediction: ${prediction.lat}, ${prediction.lng}");
                    }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
