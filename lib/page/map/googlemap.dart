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
  // late GoogleMapController mapController;
  // LatLng? _currentPosition;
  // Set<Marker> _markers = {};
  // Set<Polyline> _polylines = {};
  // PolylinePoints polylinePoints = PolylinePoints();

  // final LatLng _destination = const LatLng(-15.7167, 46.3167);
  // final String googleApiKey = "AIzaSyA-nvourlwGfRs3VMYVSaxpF4NW8vkIuCM";

  // @override
  // void initState() {
  //   super.initState();
  //   _getCurrentLocation();
  // }
  // void _onMapCreated(GoogleMapController controller) {
  //   mapController = controller;
  // }

  // Future<void> _getCurrentLocation() async {
  //   // Vérifier et demander les permissions
  //   LocationPermission permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //     if (permission == LocationPermission.denied) {
  //       print("erreur");
  //       return;
  //     }
  //   }

    // if (permission == LocationPermission.deniedForever) {
    //   print("erreur");
    //   return;
    // }

    // Obtenir la position actuelle
    // Position position = await Geolocator.getCurrentPosition(
    //   desiredAccuracy: LocationAccuracy.high,
    // );

    // setState(() {
    //   _currentPosition = LatLng(position.latitude, position.longitude);
    //    _markers.add(Marker(
    //     markerId: const MarkerId("start"),
    //     position: _currentPosition!,
    //     infoWindow: const InfoWindow(title: "Départ"),
    //   ));

    //   _markers.add(Marker(
    //     markerId: const MarkerId("destination"),
    //     position: _destination,
    //     infoWindow: const InfoWindow(title: "Destination"),
    //   ));
    // });

    // Déplacer la caméra
    // mapController.animateCamera(
    //   CameraUpdate.newLatLngZoom(_currentPosition!, 12),
    // );

    // _getRoute();
  // }

// Future<void> _getRoute() async {
//     if (_currentPosition == null) return;

//     PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
//       googleApiKey: googleApiKey,
//       request: PolylineRequest(
//         origin: PointLatLng(_currentPosition!.latitude, _currentPosition!.longitude), 
//         destination: PointLatLng(_destination.latitude, _destination.longitude), 
//         mode: TravelMode.driving // optionnel (driving, walking, bicycling, transit)
//       ),
//     );
//     print("Status: ${result.status}");
//     print("Error: ${result.errorMessage}");
//     print("Points trouvés: ${result.points.length}");

//     if (result.points.isNotEmpty) {
//       List<LatLng> polylineCoordinates = [];
//       for (var point in result.points) {
//         polylineCoordinates.add(LatLng(point.latitude, point.longitude));
//       }

//       setState(() {
//         _polylines.add(
//           Polyline(
//             polylineId: const PolylineId("route"),
//             color: Colors.blue,
//             width: 5,
//             points: polylineCoordinates,
//           ),
//         );
//       });

      // mapController.animateCamera(
      //   CameraUpdate.newLatLngBounds(
      //     LatLngBounds(
      //       southwest: LatLng(
      //         _currentPosition!.latitude <= _destination.latitude
      //           ? _currentPosition!.latitude
      //           : _destination.latitude,
      //         _currentPosition!.longitude <= _destination.longitude
      //           ? _currentPosition!.longitude
      //           : _destination.longitude,
      //       ),
      //       northeast: LatLng(
      //         _currentPosition!.latitude > _destination.latitude
      //           ? _currentPosition!.latitude
      //           : _destination.latitude,
      //         _currentPosition!.longitude > _destination.longitude
      //           ? _currentPosition!.longitude
      //           : _destination.longitude,
      //       ),
      //     ),
      //     100,
      //   ),
      // );

      

//     }
//   }

  // Widget build(BuildContext context) {

  //   return _currentPosition == null
  //     ? const Center(child: CircularProgressIndicator())
  //     : Scaffold(
  //       backgroundColor: Colors.white,
  //       body: Stack(
  //         clipBehavior: Clip.none,

  //       children: [
  //         // SafeArea(
  //           // child: 
  //           GoogleMap(
  //             onMapCreated: _onMapCreated,
  //             initialCameraPosition: CameraPosition(
  //               target: _currentPosition!,
  //               zoom: 12,
  //             ),
  //             markers: _markers,
  //             polylines: _polylines,
  //             myLocationEnabled: true, // Activer le bouton localisation
  //             myLocationButtonEnabled: true,
              
  //           ),
          // ),
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  List<LatLng> polylineCoordinates = [];

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
              // Quand l'utilisateur clique sur la carte, on place le marqueur
            },
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
          ),

          // Positioned(
          //   top: 40,
          //   left: 15,
          //   right: 15,
          //   child: Container(
          //     decoration: BoxDecoration(
          //       color: Colors.white,
          //       borderRadius: BorderRadius.circular(8),
          //     ),
          //     child: GooglePlaceAutoCompleteTextField(
          //       textEditingController: TextEditingController(),
          //       googleAPIKey: googleApiKey,
          //       inputDecoration: const InputDecoration(
          //         hintText: "Rechercher un lieu...",
          //         border: InputBorder.none,
          //         contentPadding: EdgeInsets.all(10),
          //       ),
          //       debounceTime: 800,
          //       countries: ["mg"], // Limiter aux pays (MG = Madagascar)
          //       isLatLngRequired: true,
          //       getPlaceDetailWithLatLng: (prediction) {
          //         double lat = prediction.lat!;
          //         double lng = prediction.lng!;
          //         _goToPlace(lat, lng, prediction.description!);
          //       },
          //     ),
          //   ),
          Positioned(
            top: 40,
            left: 0,
            child: GestureDetector(
              onTap: (){
                Navigator.pop(context);
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 100,
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

                    GooglePlaceAutoCompleteTextField(
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
                        double lat = prediction.lat!;
                        double lng = prediction.lng!;
                        _goToPlace(lat, lng, prediction.description!);
                      },
                    ),
                    // Container(
                    //   width: 250,
                    //   height: 45,
                    //   padding: EdgeInsets.only(bottom: 12, left: 10),
                    //   decoration: BoxDecoration(
                    //     color: Colors.white,
                    //     border: Border.all(color: Colors.black45),
                    //     borderRadius: BorderRadius.all(Radius.circular(10))
                    //   ),
                    //   child: TextFormField(
                    //     decoration: InputDecoration(
                    //       border: InputBorder.none,
                    //       enabledBorder: InputBorder.none,
                    //       focusedBorder: InputBorder.none,
                    //       hint: Text('Chercher', style: TextStyle(fontSize: 15),)
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ), 
            )
          )
        ],
      )
    );
  }
}
