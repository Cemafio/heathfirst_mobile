import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:heathfirst_mobile/page/home/homePage.dart';
import 'package:heathfirst_mobile/page/login/login.dart';
import 'package:http/http.dart' as http;

class GoogleMapPage extends StatefulWidget {
  final List<dynamic> allDoc;
  const GoogleMapPage({super.key, required this.allDoc});
  @override
  State<GoogleMapPage> createState() => _GoogleMapPageState();
}

class _GoogleMapPageState extends State<GoogleMapPage> {
  Future<List<dynamic>> get _allDoctor => widget.allDoc[0];
  String get _docCherched => widget.allDoc[1];

  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  List<LatLng> polylineCoordinates = [];
  TextEditingController _searchController = TextEditingController();
  MapType _currentMapType = MapType.normal;

  final PolylinePoints polylinePoints = PolylinePoints();
  final String googleApiKey = "AIzaSyA-nvourlwGfRs3VMYVSaxpF4NW8vkIuCM";
  // Position initiale (centrage)
  static const LatLng _initialLatLng = LatLng(-18.8792, 47.5079);

  LatLng? _selectedPosition;
  LatLng? originPos;
  Widget? _selectedWidget;
  bool _showCard = false;
  bool _markersLoaded = false;


  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  void initState(){
    super.initState();

  }

  void _generateMarker(final docInfo) {
      // List<dynamic> docMarcked = [];
    for (var item in docInfo) {
      final loc = item['location'];

      if (loc == null) {
        print("⚠️ location est NULL pour : ${item['lastName']}");
        continue; // on saute cet item
      }

      if (loc is! String || loc.trim().isEmpty || !loc.contains(";")) {
        print("⚠️ location invalide : $loc");
        continue;
      }

      final coords = loc
          .split(';')
          .map((e) => double.tryParse(e.trim()))
          .toList();

      if (coords.length != 2 || coords[0] == null || coords[1] == null) {
        print("⚠️ Coordonnées invalides : $coords");
        continue;
      }

      final pos = LatLng(coords[0]!, coords[1]!);
      _placeMarkerAtCurrentLocation(pos, item);
    }
  }

  void _placeSingleMarker(LatLng pos,final listDoc, final origin){
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId("${listDoc['id']}_${_markers.length}"), // ID unique
          position: pos,
          onTap: (){
            setState((){
              originPos = origin;
              _selectedPosition = pos;
              _selectedWidget = Row(
                children:[
                  Container(
                    width: 90,
                    height: 100,
                    margin: const EdgeInsets.only(bottom: 5),

                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        width: sqrt1_2,
                        color: const Color(0xFF81C784),
                      ),
                        image: DecorationImage(
                          image: NetworkImage('http://172.27.136.28:8000/images/photos/${listDoc['photo_profil']}'),
                          fit: BoxFit.cover,
                        ),
                    ),
                  ),
                  const SizedBox(width: 10,),
                  SizedBox(
                    height: 80,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${listDoc['lastName']} ${listDoc['firstName']}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                        Row(
                          children: [
                            Icon(Icons.location_city_rounded,
                                color: Color(0xFF548856),
                                size: 15),
                                const SizedBox(width: 3),
                            Text('${listDoc['AddressCabinet']}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.add_chart_rounded,
                                color: Color(0xFF548856),
                                size: 15),
                                const SizedBox(width: 3),
                            Text('${listDoc['Specialty']}', style: TextStyle(color: Colors.green),),
                          ],
                        ),
                      ],
                    ),
                  ),

              ]);
              _showCard = true;
            });
          },
          // infoWindow: InfoWindow(title: title),
        ),
      );
    });
  }

  void _placeMarkerAtCurrentLocation(LatLng doc_locate, final doc_info) async {
    LocationPermission p = await Geolocator.checkPermission();
    if (p == LocationPermission.denied) {
      p = await Geolocator.requestPermission();
      if (p == LocationPermission.denied) return;
    }
    if (p == LocationPermission.deniedForever) return;

    Position pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    _goToPlace(pos.latitude, pos.longitude);
    final origin = LatLng(pos.latitude, pos.longitude);

    _placeSingleMarker(doc_locate,doc_info, origin);

    if(_docCherched == doc_info['lastName']){
      _drawRoute(origin,doc_locate);
    }
  }
  
  Future<void> _drawRoute(LatLng? _origin, LatLng? _destination) async {
    if(_origin != null && _destination!= null){
      List<LatLng> routePoints = await _getDetailedRoute(_origin, _destination);

      setState(() {
        _polylines.add(
          Polyline(
            polylineId: const PolylineId("route"),
            color: const Color.fromARGB(255, 33, 243, 177),
            width: 5,
            points: routePoints,
          ),
        );
      });
    }

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

  void _goToPlace(double lat, double lng) {
    _mapController.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(lat, lng), 15.5),
    );
  }

  void _toggleMapType() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal ? MapType.hybrid : MapType.normal;
    });
  }
   
  void _goToCurrentPosition() async{
    LocationPermission p = await Geolocator.checkPermission();
    if (p == LocationPermission.denied) {
      p = await Geolocator.requestPermission();
      if (p == LocationPermission.denied) return;
    }
    if (p == LocationPermission.deniedForever) return;

    Position pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    _goToPlace(pos.latitude, pos.longitude);
  }

  Widget _buildSlidingCard(Widget? _selectedWidget) {
    if (_selectedWidget == null) return SizedBox();
    
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: Offset(0, -3),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Barre de fermeture
          Container(
            width: 50,
            height: 5,
            margin: EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          _selectedWidget,

          SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () {
                  print("Itinéraire");
                  _drawRoute(originPos,_selectedPosition);

                },
                child: Text("Tracer itineraire"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget build(BuildContext context) {

    return Scaffold(
      body: Stack(
        children: [
          FutureBuilder(
            future: _allDoctor, 
            builder: (context, snapshot){
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  margin: EdgeInsets.only(top: 100),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError) {
                if (snapshot.error.toString().contains("unauthorized")) {
                  Future.microtask(() {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => LoginMobile()),
                    );
                  });
                }
                return Center(child: Text("Erreur : ${snapshot.error}"));
              }

              if(snapshot.hasData && !_markersLoaded){
                _markersLoaded = true;
                final docInfo = snapshot.data;
                _generateMarker(docInfo!);
              }

              return GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: _initialLatLng,
                  zoom: 10,
                ),
                onMapCreated: _onMapCreated,
                markers: _markers,
                polylines: _polylines,
                onTap: (pos) {
                  setState(() {
                    _showCard = false;
                  });
                  // _placeSingleMarker(pos, 'Nouvel position');
                },
                
                
                myLocationButtonEnabled: false,
                myLocationEnabled: true,
                mapType: _currentMapType,
              );
          }),
          

          Positioned(
            top: 40,
            left: 0,
            child: GestureDetector(
              onTap: (){
                Navigator.pop(context);
                // Navigator.of(context).push(MaterialPageRoute(builder: (context)=>HomePage(user: infoUser)));

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
          
          Positioned(
            bottom: 90,
            left: 10,
            child: FloatingActionButton(
              onPressed: _goToCurrentPosition,
              child: Icon(Icons.location_on_outlined),
            ),
          ),
          
          Positioned(
            bottom: 20,
            left: 10,
            child: FloatingActionButton(
              onPressed: _toggleMapType,
              child: Icon(Icons.map_rounded),
            ),
          ),

          // 🔥 Panneau avec animation slide
          AnimatedPositioned(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
            left: 0,
            right: 0,
            bottom: _showCard ? 0 : -200, // ← Slide up/down !
            child: _buildSlidingCard(_selectedWidget),
          ),
        ],
      )
    );
  }
}
