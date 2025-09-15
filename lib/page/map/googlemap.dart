import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:http/http.dart' as http;

class GoogleMapPage extends StatefulWidget {
  const GoogleMapPage({super.key});
  @override
  State<GoogleMapPage> createState() => _GoogleMapPageState();
}

class _GoogleMapPageState extends State<GoogleMapPage> {
late GoogleMapController _mapController;
final Set<Marker> _markers = {};
final Set<Polyline> _polylines = {};
List<LatLng> polylineCoordinates = [];
TextEditingController _searchController = TextEditingController();

final PolylinePoints polylinePoints = PolylinePoints();
  final String googleApiKey = "AIzaSyA-nvourlwGfRs3VMYVSaxpF4NW8vkIuCM";
  // Position initiale (centrage)
  static const LatLng _initialLatLng = LatLng(-18.8792, 47.5079);

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  void initState(){
    super.initState();
    _placeMarkerAtCurrentLocation();
  }

  void _placeSingleMarker(LatLng pos, LatLng dest, {String title = 'Marqueur'}) {
    setState(() {
      _markers.add(Marker(
        markerId: const MarkerId('Destination'),
        position: dest,
        infoWindow: InfoWindow(title: title),
      ));
    });

    // recentrer la caméra dessus
    _mapController.animateCamera(CameraUpdate.newLatLngZoom(pos, 14));
  }

  Future<void> _placeMarkerAtCurrentLocation() async {
    LocationPermission p = await Geolocator.checkPermission();
    if (p == LocationPermission.denied) {
      p = await Geolocator.requestPermission();
      if (p == LocationPermission.denied) return;
    }
    if (p == LocationPermission.deniedForever) return;

    Position pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    final origin = LatLng(pos.latitude, pos.longitude);
    final destination = LatLng(-15.7167, 46.3167);
    // -15.7167, 46.3167
    _placeSingleMarker(origin, destination, title: 'Ma position');
    _drawRoute(origin,destination);
  }

  Future<void> _drawRoute(LatLng _origin, LatLng _destination) async {
    List<LatLng> routePoints = await _getDetailedRoute(_origin, _destination);

    setState(() {
      _polylines.add(
        Polyline(
          polylineId: const PolylineId("route"),
          color: Colors.blue,
          width: 5,
          points: routePoints,
        ),
      );
    });
  }

  Future<List<LatLng>> _getDetailedRoute(LatLng origin, LatLng destination) async {
    final url =
        "https://maps.googleapis.com/maps/api/directions/json?"
        "origin=${origin.latitude},${origin.longitude}"
        "&destination=${destination.latitude},${destination.longitude}"
        "&mode=driving&key=$googleApiKey";

    final response = await http.get(Uri.parse(url));
    final data = json.decode(response.body);

    List<LatLng> polylineCoords = [];

    if (data["status"] == "OK") {
      var steps = data["routes"][0]["legs"][0]["steps"];
      for (var step in steps) {
        String polyline = step["polyline"]["points"];
        polylineCoords.addAll(_decodePolyline(polyline));
      }
    }

    return polylineCoords;
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      poly.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return poly;
  }
  void _getPolyline(LatLng dest, LatLng local) async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: googleApiKey,
      request: PolylineRequest(
        origin: PointLatLng(local.latitude, local.longitude),
        destination: PointLatLng(dest.latitude, dest.longitude),
        mode: TravelMode.driving,
      )
    );

    if (result.points.isNotEmpty) {
      polylineCoordinates.clear();
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }

      setState(() {
        _polylines.add(Polyline(
          polylineId: const PolylineId('route'),
          width: 5,
          color: Colors.green,
          points: polylineCoordinates,
        ));
      });

      // Ajuster la caméra pour voir tout le trajet
      _mapController.animateCamera(CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(
            local.latitude < dest.latitude
                ? local.latitude
                : dest.latitude,
            local.longitude < dest.longitude
                ? local.longitude
                : dest.longitude,
          ),
          northeast: LatLng(
            local.latitude > dest.latitude
                ? local.latitude
                : dest.latitude,
            local.longitude > dest.longitude
                ? local.longitude
                : dest.longitude,
          ),
        ),
        50,
      ));
    } else {
      debugPrint("Erreur Directions API: ${result.errorMessage}");
    }
  }
  Future<Map<String, dynamic>?> getPlaceDetails(String placeId) async {
    final url = Uri.parse(
      "https://maps.googleapis.com/maps/api/place/details/json"
      "?place_id=$placeId&key=$googleApiKey",
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data["status"] == "OK") {
        final location = data["result"]["geometry"]["location"];
        return {
          "lat": location["lat"],
          "lng": location["lng"],
          "description": data["result"]["name"],
        };
      }
    }
    return null;
  }
  void _goToPlace(double lat, double lng, String description) {
    print("📍 Aller vers $description ($lat, $lng)");
    _mapController.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(lat, lng), 14),
    );
  }
   

  Widget build(BuildContext context) {

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _initialLatLng,
              zoom: 10,
            ),
            onMapCreated: _onMapCreated,
            markers: _markers,
            polylines: _polylines,
            onTap: (pos) {
            },
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
          ),

          Positioned(
            top: 40,
            left: 0,
            child: GestureDetector(
              onTap: (){
                Navigator.pop(context);
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                // height: 100,
                padding: EdgeInsets.all(15),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      // margin: const EdgeInsets.only(bottom: 5),

                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        // border: Border.all(),
                        color: Color.fromARGB(97, 107, 107, 107)
                      ),

                      child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white,),
                    ),

                    Container(
                      width: 300,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: GooglePlaceAutoCompleteTextField(
                        textEditingController: _searchController,
                        googleAPIKey: googleApiKey,
                        inputDecoration: const InputDecoration(
                          hintText: "Rechercher un lieu...",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(10),
                        ),
                        debounceTime: 800,
                        countries: ["mg"], // Limiter aux pays (MG = Madagascar)
                        isLatLngRequired: true,
                        getPlaceDetailWithLatLng: (prediction) async {

                          if (prediction.placeId != null) {
                          final details = await getPlaceDetails(prediction.placeId!);
                            if (details != null) {
                              _goToPlace(
                                details["lat"],
                                details["lng"],
                                details["description"],
                              );
                            }
                          }
                        },

                        itemClick: (prediction) async {
                        // Quand l’utilisateur clique sur un résultat
                        _searchController.text = prediction.description ?? "";

                        if (prediction.placeId != null) {
                          final details = await getPlaceDetails(prediction.placeId!);
                          if (details != null) {
                            _goToPlace(
                              details["lat"],
                              details["lng"],
                              details["description"],
                            );
                          }
                        }
                      },
                      ),
                    ),                    
                  ],
                ),
              ), 
            )
          ),
        ],
      )
    );
  }
}
