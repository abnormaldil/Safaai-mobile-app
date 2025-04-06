import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_gauges/gauges.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  BitmapDescriptor customIcon = BitmapDescriptor.defaultMarker;

  final user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late GoogleMapController mapController;
  LatLng _initialPosition = LatLng(9.57906989243186, 76.62288789505747);
  bool _isPermissionGranted = false;
  final TextEditingController _searchController = TextEditingController();
  List<String> _placeSuggestions = [];
  bool _isDropdownVisible = false;
  Timer? _debounce;

  Map<String, Map<String, dynamic>> _markerDetails = {};

  String? _selectedMarkerId;
  Set<Polyline> _polylines = {}; // To track the selected marker

  @override
  void initState() {
    customMarker();
    super.initState();
    _getUserLocation();
    _fetchBinDetails();
  }

  void customMarker() {
    BitmapDescriptor.asset(
            const ImageConfiguration(size: Size(50, 50)), "assets/marker.png")
        .then((icon) {
      setState(() {
        customIcon = icon;
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMapStyle() async {
    String style = await rootBundle.loadString('assets/light.json');
    mapController.setMapStyle(style);
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showLocationServiceError();
      return;
    }

    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.deniedForever) {
      _showPermissionError();
      return;
    }

    if (permission == LocationPermission.denied) {
      _showPermissionError();
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      _initialPosition = LatLng(position.latitude, position.longitude);
      _isPermissionGranted = true;
    });

    if (mapController != null) {
      mapController.animateCamera(
        CameraUpdate.newLatLngZoom(_initialPosition, 14),
      );
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _loadMapStyle();
    if (_isPermissionGranted) {
      mapController.animateCamera(
        CameraUpdate.newLatLngZoom(_initialPosition, 14),
      );
    }
  }

  Future<void> _fetchBinDetails() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('bin').get();

      Map<String, Map<String, dynamic>> fetchedBinDetails = {};

      for (var doc in querySnapshot.docs) {
        var binData = doc.data() as Map<String, dynamic>;
        var markerId = doc.id; // bin1, bin2, etc.
        GeoPoint geoPoint = binData["coordinates"];
        fetchedBinDetails[markerId] = {
          "title": binData["title"] ?? "Unknown Bin",
          "location": binData["location"] ?? "Unknown Location",
          "description": binData["description"] ?? 0,
          "coordinates": LatLng(
            geoPoint.latitude,
            geoPoint.longitude,
          ),
        };
      }
      print(fetchedBinDetails);
      setState(() {
        _markerDetails = fetchedBinDetails; // Update the markers dynamically
      });
    } catch (e) {
      print("Error fetching bin details: $e");
    }
  }

  Future<void> _reloadBinData() async {
    if (_selectedMarkerId != null) {
      try {
        // Fetch the latest bin details from Firestore for the selected bin
        DocumentSnapshot docSnapshot =
            await _firestore.collection('bin').doc(_selectedMarkerId).get();

        if (docSnapshot.exists) {
          var binData = docSnapshot.data() as Map<String, dynamic>;
          GeoPoint geoPoint = binData["coordinates"];
          setState(() {
            _markerDetails[_selectedMarkerId!] = {
              "title": binData["title"] ?? "Unknown Bin",
              "location": binData["location"] ?? "Unknown Location",
              "description": binData["description"] ?? 0,
              "coordinates": LatLng(
                geoPoint.latitude,
                geoPoint.longitude,
              ),
            };
          });
        }
      } catch (e) {
        print("Error reloading bin data: $e");
      }
    }
  }

  Future<void> _fetchRoute(LatLng start, LatLng end) async {
    final apiUrl =
        "https://routing.openstreetmap.de/routed-car/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson";
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> coordinates =
            data["routes"][0]["geometry"]["coordinates"];
        List<LatLng> polylineCoordinates =
            coordinates.map((coord) => LatLng(coord[1], coord[0])).toList();

        setState(() {
          _polylines.clear();
          _polylines.add(Polyline(
            polylineId: PolylineId("route"),
            points: polylineCoordinates,
            color: Colors.blue,
            width: 5,
          ));
        });
      } else {
        print("Failed to fetch route: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching route: $e");
    }
  }

  Future<bool> _searchLocation(String query) async {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    Completer<bool> completer = Completer();

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.isEmpty) {
        setState(() {
          _placeSuggestions = [];
          _isDropdownVisible = false;
        });
        completer.complete(false);
        return;
      }

      try {
        List<Location> locations = await locationFromAddress(query);
        if (locations.isNotEmpty) {
          List<String> suggestions = [];
          for (Location loc in locations) {
            List<Placemark> placemarks =
                await placemarkFromCoordinates(loc.latitude, loc.longitude);
            if (placemarks.isNotEmpty) {
              final placemark = placemarks.first;
              String placeName =
                  "${placemark.name}, ${placemark.locality}, ${placemark.country}";
              suggestions.add(placeName);
            }
          }

          setState(() {
            _placeSuggestions = suggestions;
            _isDropdownVisible = true;
          });
          completer.complete(true);
        } else {
          setState(() {
            _placeSuggestions = [];
            _isDropdownVisible = false;
          });
          completer.complete(false);
        }
      } catch (e) {
        setState(() {
          _placeSuggestions = [];
          _isDropdownVisible = false;
        });
        completer.complete(false);
      }
    });

    return completer.future;
  }

  void _onMarkerTapped(String markerId) {
    setState(() {
      _selectedMarkerId = markerId;
    });
  }

  void _showLocationServiceError() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Location Services Disabled"),
        content: Text("Please enable location services to use this feature."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showPermissionError() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Permission Denied"),
        content: Text(
            "Location permission is required to access your current location."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 41, 41, 41),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 43, 43, 43),
        automaticallyImplyLeading: false,
        title: Text(
          'SaFaai',
          style: TextStyle(
            fontSize: 35,
            color: Colors.white,
            fontFamily: 'AvantGardeLT',
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _initialPosition,
                zoom: 14.0,
              ),
              markers: _markerDetails.entries.map((entry) {
                final markerId = entry.key;
                final markerDetails = entry.value;
                final markerCoordinates =
                    markerDetails["coordinates"] as LatLng;
                return Marker(
                  markerId: MarkerId(markerId),
                  position: markerCoordinates, // Replace with actual positions
                  onTap: () => _onMarkerTapped(markerId),
                  infoWindow: InfoWindow(
                    title: markerDetails["title"],
                    snippet: markerDetails["location"],
                  ),
                  icon: customIcon,
                );
              }).toSet(),
              polylines: _polylines,
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              myLocationEnabled: _isPermissionGranted,
              mapType: MapType.normal,
            ),
          ),
          Positioned(
            top: 5,
            left: 10,
            right: 10,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                    color: const Color.fromARGB(255, 185, 182, 182), width: 1),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: "Search location",
                        border: InputBorder.none,
                        icon: Icon(Icons.search, color: Color(0xFF18cc84)),
                      ),
                      onChanged: (query) {
                        _searchLocation(query);
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.my_location, color: Color(0xFF18cc84)),
                    onPressed: _getUserLocation,
                  ),
                ],
              ),
            ),
          ),
          if (_isDropdownVisible)
            Positioned(
              top: 65,
              left: 15,
              right: 15,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _placeSuggestions.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_placeSuggestions[index]),
                      onTap: () async {
                        try {
                          List<Location> locations = await locationFromAddress(
                              _placeSuggestions[index]);
                          if (locations.isNotEmpty) {
                            Location location = locations.first;
                            mapController.animateCamera(
                              CameraUpdate.newLatLngZoom(
                                LatLng(location.latitude, location.longitude),
                                14,
                              ),
                            );
                            setState(() {
                              _isDropdownVisible = false;
                              _searchController.clear();
                            });
                          }
                        } catch (e) {
                          print("Error navigating to location: $e");
                        }
                      },
                    );
                  },
                ),
              ),
            ),
          if (_selectedMarkerId != null)
            Positioned(
              bottom: 90,
              left: 70,
              right: 70,
              top: 450,
              child: Card(
                color: Color.fromARGB(255, 38, 38, 38),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(60),
                ),
                elevation: 10,
                child: Padding(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Top: Radial Gauge
                      Center(
                        child: SizedBox(
                          height: 120, // Adjust the gauge height
                          child: SfRadialGauge(
                            axes: <RadialAxis>[
                              RadialAxis(
                                minimum: 0,
                                maximum: 100,
                                showLabels: false,
                                showTicks: false,
                                axisLineStyle: AxisLineStyle(
                                  thickness: 0.3,
                                  cornerStyle: CornerStyle.bothCurve,
                                  color:
                                      const Color.fromARGB(255, 255, 255, 255),
                                  thicknessUnit: GaugeSizeUnit.factor,
                                ),
                                pointers: <GaugePointer>[
                                  RangePointer(
                                    value: _markerDetails[_selectedMarkerId]![
                                            'description']
                                        .toDouble(),
                                    cornerStyle: CornerStyle.bothCurve,
                                    width: 0.3,
                                    sizeUnit: GaugeSizeUnit.factor,
                                    gradient: SweepGradient(
                                      colors: [
                                        Color.fromARGB(255, 23, 137, 91),
                                        Color.fromARGB(255, 32, 195, 130),
                                        Color.fromARGB(255, 24, 249, 159),
                                      ],
                                    ),
                                  ),
                                ],
                                annotations: <GaugeAnnotation>[
                                  GaugeAnnotation(
                                    positionFactor: 0.1,
                                    angle: 90,
                                    widget: Text(
                                      "${_markerDetails[_selectedMarkerId]!['description']}%",
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Gilroy',
                                        color:
                                            Color.fromARGB(255, 42, 254, 169),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 1),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Reload Icon Button with Gradient
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color.fromARGB(255, 244, 244, 244),
                                  Color.fromARGB(255, 174, 174, 174),
                                  Color.fromARGB(255, 117, 117, 117),
                                ],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                // Reload the description value by fetching it again
                                _reloadBinData();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors
                                    .transparent, // Transparent to show gradient
                                shadowColor: Colors.transparent, // No shadow
                                shape: CircleBorder(),
                                padding: EdgeInsets.all(
                                    10), // Adjust padding for icon size
                              ),
                              child: Icon(
                                Icons.refresh,
                                size: 30,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          // Directions Icon Button with Gradient
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color.fromARGB(255, 37, 232, 154),
                                  Color.fromARGB(255, 42, 254, 169),
                                  Color.fromARGB(255, 32, 196, 130),
                                ],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                final selectedMarkerCoords = _markerDetails[
                                        _selectedMarkerId]!['coordinates']
                                    as LatLng;
                                _fetchRoute(
                                    _initialPosition, selectedMarkerCoords);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors
                                    .transparent, // Transparent to show gradient
                                shadowColor: Colors.transparent, // No shadow
                                shape: CircleBorder(),
                                padding: EdgeInsets.all(
                                    10), // Adjust padding for icon size
                              ),
                              child: Icon(
                                Icons.directions_run_rounded,
                                size: 30,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          // Close Icon Button with Gradient
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color.fromARGB(255, 255, 68, 71),
                                  Color.fromARGB(255, 255, 102, 104),
                                  Color.fromARGB(255, 253, 46, 50),
                                ],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _selectedMarkerId = null; // Close the card
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors
                                    .transparent, // Transparent to show gradient
                                shadowColor: Colors.transparent, // No shadow
                                shape: CircleBorder(),
                                padding: EdgeInsets.all(
                                    10), // Adjust padding for icon size
                              ),
                              child: Icon(
                                Icons.close_rounded,
                                size: 30,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
