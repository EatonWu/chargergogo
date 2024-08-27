import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/rendering.dart';
import 'package:chargergogo/locations.dart' as locations;

void main() {
  debugPaintSizeEnabled = false;
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late GoogleMapController mapController;

  final LatLng _center = const LatLng(36.1716, -115.1391);
  // final LatLng _center = const LatLng(56.172249, 10.187372)
  final Map<String, Marker> _markers = {};

  Future<void> _onMapCreated(GoogleMapController controller) async {
    final cggOffices = await locations.getGoogleOffices();
    // var icon = await BitmapDescriptor.asset(
    //     const ImageConfiguration(size: Size(48, 48)), 'assets/cgg_logo.png');
    setState(() {
      _markers.clear();
      for (final office in cggOffices.offices) {
        final marker = Marker(
          markerId: MarkerId(office.name),
          icon: BitmapDescriptor.defaultMarker,
          // icon: icon,
          position: LatLng(office.lat, office.lng),
          infoWindow: InfoWindow(
            title: office.name,
            snippet: office.address,
          ),
          onTap: () async {
            var oldZoom = await mapController.getZoomLevel();
            mapController.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                  target: LatLng(office.lat, office.lng),
                  zoom: oldZoom,
                ),
              ),
            );
          },
        );
        _markers[office.name] = marker;
      }
    });
        
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green[700],
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Chargergogo Demo App'),
          elevation: 2,
        ),
        body: cggMapPage(),
      ),
    );
  }

  Widget cggMapPage() {
    // print("marker quantity: ${_markers.length}");
    return Stack(
      children: [
        GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: _center,
            zoom: 11.0,
          ),
          markers: _markers.values.toSet(),

        ),
        // center the text at the bottom of the screen
        const Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Text("testing", textAlign: TextAlign.center),
        ),
      ]
    );
  }
}
