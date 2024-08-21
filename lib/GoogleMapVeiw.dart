import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MyGoogleVeiw extends StatefulWidget {
  const MyGoogleVeiw({super.key});

  @override
  State<MyGoogleVeiw> createState() => _MyGoogleVeiwState();
}

class _MyGoogleVeiwState extends State<MyGoogleVeiw> {
  GoogleMapController? _controller;
  LatLng _initialPosition = LatLng(28.5355, 77.3910); // Default to San Francisco
  Marker? _marker;
  String _address = '';
  TextEditingController _cityController = TextEditingController();

  Future<void> _searchCity(String cityName) async {
    print('Searching for city: $cityName');
    try {
      List<Location> locations = await locationFromAddress(cityName);
      print('Locations found: ${locations.length}');
      if (locations.isNotEmpty) {
        Location location = locations.first;
        LatLng position = LatLng(location.latitude, location.longitude);
        setState(() {
          _initialPosition = position;
          _marker = Marker(
            markerId: MarkerId('searchedLocation'),
            position: position,
          );
          _controller?.animateCamera(CameraUpdate.newLatLngZoom(position, 10.0));
        });
      } else {
        print('No results found for the provided address.');
        // Optionally show a message to the user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No results found for "$cityName". Please try a different query.')),
        );
      }
    } catch (e) {
      print('Error during geocoding: $e');
      // Optionally show an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error finding location: $e')),
      );
    }
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;
        setState(() {
          _address = "${placemark.street}, ${placemark.locality}, ${placemark.country}";
        });
      } else {
        print('No address found for the coordinates.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No address found for the selected location.')),
        );
      }
    } catch (e) {
      print('Error during reverse geocoding: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error finding address: $e')),
      );
    }
  }

  void _onMapTapped(LatLng position) {
    setState(() {
      _marker = Marker(
        markerId: MarkerId('selectedLocation'),
        position: position,
      );
    });
    _getAddressFromLatLng(position);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search and Select Location'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _cityController,
              decoration: InputDecoration(
                hintText: 'Enter city name',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    _searchCity(_cityController.text);
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _initialPosition,
                zoom: 10.0,
              ),
              markers: _marker != null ? {_marker!} : {},
              onMapCreated: (controller) {
                _controller = controller;
              },
              onTap: _onMapTapped,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Address: $_address',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}