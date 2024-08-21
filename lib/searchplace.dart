import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
class SearchMapScreen extends StatefulWidget {
  @override
  _SearchMapScreenState createState() => _SearchMapScreenState();
}

class _SearchMapScreenState extends State<SearchMapScreen> {
  GoogleMapController? _mapController;
  Marker? _selectedPlaceMarker;
  List<Map<String, dynamic>> _suggestions = [];
  final TextEditingController _searchController = TextEditingController();
  final String _googleApiKey = 'AIzaSyDdM65mUgYTlpfZrK5sizFWtYvN-_TjIM0';
  bool _isLoading = false;
  Future<void> _getSuggestions(String query) async {
    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
        _isLoading = false;
      });
      return;
    }
    setState(() {
      _isLoading = true; // Start loading
    });

    final response = await http.get(
      Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json'
            '?input=$query'
            '&types=(cities)'
            '&key=$_googleApiKey',

      ),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> predictions = data['predictions'];
      setState(() {
        _suggestions = predictions
            .map((place) => {
          'description': place['description'],
          'place_id': place['place_id'],
        })
            .toList();
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false; // Stop loading on error
      });
      throw Exception('Failed to load suggestions');
    }
  }

  Future<void> _getPlaceDetails(String placeId) async {
    final response = await http.get(
      Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json'
            '?place_id=$placeId'
            '&key=$_googleApiKey',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final location = data['result']['geometry']['location'];
      final latLng = LatLng(location['lat'], location['lng']);

      setState(() {
        _selectedPlaceMarker = Marker(
          markerId: MarkerId(placeId),
          position: latLng,
          infoWindow: InfoWindow(title: data['result']['name']),
        );

        _mapController?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 12.0));
      });
    } else {
      throw Exception('Failed to load place details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search and Display City on Map'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(28.5355, 77.3910), // Default to San Francisco
              zoom: 10.0,
            ),
            markers: _selectedPlaceMarker != null ? {_selectedPlaceMarker!} : {},
            onMapCreated: (controller) {
              _mapController = controller;
            },
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        _getSuggestions(value);
                      },
                      decoration: InputDecoration(
                        hintText: 'Enter city name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  _searchController.text.isNotEmpty && !_isLoading
                      ?  Container(
                    height: MediaQuery.of(context).size.height * 0.4, // Adjust as needed
                    child: ListView.builder(
                      padding: EdgeInsets.all(0),
                      itemCount: _suggestions.length,
                      itemBuilder: (context, index) {
                        final suggestion = _suggestions[index];
                        return ListTile(
                          title: Text(suggestion['description']),
                          onTap: () {
                            _searchController.text = suggestion['description'];
                            _getPlaceDetails(suggestion['place_id']);
                          },
                        );
                      },
                    ),
                  ):_isLoading
                      ? Center(
                    child: CircularProgressIndicator(),
                  )
                      : Container(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}