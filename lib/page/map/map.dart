import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'locations.dart' as locations;


class MyMap extends StatefulWidget {
  const MyMap({Key? key}) : super(key: key);

  @override
  _MyMapState createState() => _MyMapState();
}

class _MyMapState extends State<MyMap> {
  final Map<String, Marker> _markers = {};
  Future<void> _onMapCreated(GoogleMapController controller) async {
    final googleOffices = await locations.getGoogleOffices();
    setState(() {
      _markers.clear();
      for (final office in googleOffices.offices) {
        final marker = Marker(
          markerId: MarkerId(office.name),
          position: LatLng(office.lat, office.lng),
          infoWindow: InfoWindow(
            title: office.name,
            snippet: office.address,
          ),
        );
        _markers[office.name] = marker;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color.fromARGB(255, 229, 229, 229),

        body:  
          Stack(
            clipBehavior: Clip.none,

            children: [
              
              GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: const CameraPosition(
                  target: LatLng(0, 0),
                  zoom: 2,
                ),
                markers: _markers.values.toSet(),
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
      ),
    );
  }
}