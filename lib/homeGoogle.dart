// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
//
// class HomeGoogle extends StatefulWidget {
//   const HomeGoogle({super.key});
//
//   @override
//   State<HomeGoogle> createState() => _HomeGoogleState();
// }
//
// class _HomeGoogleState extends State<HomeGoogle> {
//   GoogleMapController? _controller;
//   LatLng _initialPosition = LatLng(37.7749, -122.4194); // Default to San Francisco
//   Marker? _currentLocationMarker;
//
//   @override
//   void initState() {
//     super.initState();
//     _getCurrentLocation();
//   }
//
//   Future<void> _getCurrentLocation() async {
//     bool serviceEnabled;
//     LocationPermission permission;
//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       return Future.error('Location services are disabled.');
//     }
//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         return Future.error('Location permissions are denied');
//       }
//     }
//
//     if (permission == LocationPermission.deniedForever) {
//       return Future.error('Location permissions are permanently denied.');
//     }
//     Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
//     LatLng currentPosition = LatLng(position.latitude, position.longitude);
//
//     setState(() {
//       _initialPosition = currentPosition;
//       _currentLocationMarker = Marker(
//         markerId: MarkerId('currentLocation'),
//         position: currentPosition,
//         icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
//       );
//       _controller?.animateCamera(CameraUpdate.newLatLngZoom(currentPosition, 14.0));
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Current Location'),
//       ),
//       body: GoogleMap(
//         initialCameraPosition: CameraPosition(
//           target: _initialPosition,
//           zoom: 10.0,
//         ),
//         markers: _currentLocationMarker != null ? {_currentLocationMarker!} : {},
//         onMapCreated: (controller) {
//           _controller = controller;
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _getCurrentLocation,
//         child: Icon(Icons.my_location),
//       ),
//     );
//   }
// }