import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:heathfirst_mobile/service/data.dart';
// import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;

class AjouterCabinetPage extends StatefulWidget {
  final Map<String, dynamic> user;

  AjouterCabinetPage({super.key, required this.user});
  @override 
  _AjouterCabinetPageState createState() => _AjouterCabinetPageState();
}

class _AjouterCabinetPageState extends State<AjouterCabinetPage> {
  GoogleMapController? _mapController;
  LatLng? _selectedPosition;
  String? _cabinetName;
  String _address = "Pas encore sélectionné";
  Map<String, dynamic> get  user => widget.user;
  final TextEditingController _nameController = TextEditingController();

  // 1) Récupérer la position actuelle
  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Permission localisation refusée")),
        );
        return;
      }
    }

    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _selectedPosition = LatLng(pos.latitude, pos.longitude);
    });

    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(_selectedPosition!, 16),
    );

    // _getAddressFromLatLng(_selectedPosition!);
  }

  // 2) Convertir coordonnées -> adresse (reverse geocoding)
  // Future<void> _getAddressFromLatLng(LatLng pos) async {
  //   try {
  //     List<Placemark> placemarks =
  //         await placemarkFromCoordinates(pos.latitude, pos.longitude);
  //     if (placemarks.isNotEmpty) {
  //       setState(() {
  //         _address =
  //             "${placemarks.first.street}, ${placemarks.first.locality}, ${placemarks.first.country}";
  //       });
  //     }
  //   } catch (e) {
  //     setState(() {
  //       _address = "Adresse inconnue";
  //     });
  //   }
  // }

  // 3) Envoyer au backend
  Future<void> _saveCabinet() async {
    if (_selectedPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Veuillez sélectionner un emplacement")),
      );
      return;
    }

    await editLocation(user['id'], _selectedPosition!.latitude.toString(), _selectedPosition!.longitude.toString(), user['roles'][0]);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Localisation ajouter avec succée")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Ajouter un cabinet")),
      body: Column(
        children: [
          // Carte Google Maps
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(-18.8792, 47.5079), // Tana par défaut
                zoom: 12,
              ),
              onMapCreated: (controller) => _mapController = controller,
              onTap: (pos) {
                setState(() {
                  _selectedPosition = pos;
                });
                // _getAddressFromLatLng(pos);
              },
              markers: _selectedPosition == null
                  ? {}
                  : {
                      Marker(
                        markerId: MarkerId("cabinet"),
                        position: _selectedPosition!,
                        infoWindow: InfoWindow(title: "Cabinet"),
                      ),
                    },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Nom du cabinet",
                border: OutlineInputBorder(),
              ),
              // onSaved: (newVal){
              //   setState(() => _cabinetName = newVal);
                
              // },
              onChanged: (value) {
                setState(() {
                  _cabinetName = value;
                });
              },
              validator: (value){
                if(value == null || value.trim().isEmpty){
                  return 'Veuillez entrer la raison';
                }
              }
            ),
          ),
          // Adresse affichée
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: Text("Adresse: $_address"),
          // ),

          // Boutons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: _getCurrentLocation,
                icon: Icon(Icons.my_location),
                label: Text("Ma position"),
              ),
              ElevatedButton.icon(
                onPressed: (_selectedPosition != null && _cabinetName != null )
                ? (){
                    _saveCabinet();
                  } 
                : null,
                icon: Icon(Icons.save),
                label: Text("Enregistrer"),
              ),
            ],
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
