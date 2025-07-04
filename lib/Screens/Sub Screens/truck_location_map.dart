import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class TruckLocationMap extends StatefulWidget {
  const TruckLocationMap({super.key});

  @override
  State<TruckLocationMap> createState() => _TruckLocationMapState();
}

class _TruckLocationMapState extends State<TruckLocationMap> {
  MapController mapController = MapController();
  Position? currentPosition;
  bool isLoading = true;
  String? errorMessage;
  bool mapReady = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            errorMessage = 'Location permissions are denied';
            isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          errorMessage = 'Location permissions are permanently denied';
          isLoading = false;
        });
        return;
      }

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          errorMessage =
              'Location services are disabled. Please enable location services.';
          isLoading = false;
        });
        return;
      }

      // Get current position with high accuracy settings
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
        forceAndroidLocationManager: false, // Use Google Play Services
        timeLimit: Duration(seconds: 15), // Increased timeout
      );

      // Debug: Print coordinates to console
      debugPrint(
          'GPS Location obtained: ${position.latitude}, ${position.longitude}');
      debugPrint('Accuracy: ${position.accuracy} meters');
      debugPrint('Speed: ${position.speed} m/s');

      setState(() {
        currentPosition = position;
        isLoading = false;
      });

      // Move map to user location only if map is ready
      _moveToUserLocation();
    } catch (e) {
      debugPrint('Location error: $e'); // Debug print
      setState(() {
        errorMessage = 'Failed to get location: $e';
        isLoading = false;
      });
    }
  }

  void _moveToUserLocation() {
    if (currentPosition != null && mapReady) {
      mapController.move(
        LatLng(currentPosition!.latitude, currentPosition!.longitude),
        15.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Truck Location'),
        backgroundColor: Colors.white,
        foregroundColor: Color.fromARGB(255, 2, 139, 7),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                isLoading = true;
                errorMessage = null;
                currentPosition = null;
              });
              _getCurrentLocation();
            },
            tooltip: 'Refresh Location',
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Color.fromARGB(255, 2, 139, 7),
                  ),
                  SizedBox(height: 16),
                  Text('Getting truck location...'),
                ],
              ),
            )
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_off, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isLoading = true;
                            errorMessage = null;
                          });
                          _getCurrentLocation();
                        },
                        child: Text('Try Again'),
                      ),
                    ],
                  ),
                )
              : Stack(
                  children: [
                    FlutterMap(
                      mapController: mapController,
                      options: MapOptions(
                        initialCenter: LatLng(
                          currentPosition!.latitude,
                          currentPosition!.longitude,
                        ), // Use actual GPS location
                        initialZoom: 15.0,
                        onMapReady: () {
                          setState(() {
                            mapReady = true;
                          });
                          // Map will already be centered on actual location
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                          subdomains: const ['a', 'b', 'c'],
                          userAgentPackageName: 'com.example.regen',
                          maxZoom: 19,
                        ),
                        if (currentPosition != null)
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: LatLng(
                                  currentPosition!.latitude,
                                  currentPosition!.longitude,
                                ),
                                width: 60,
                                height: 60,
                                child: _buildTruckMarker(),
                              ),
                            ],
                          ),
                      ],
                    ),
                    // Debug coordinates display
                    if (currentPosition != null)
                      Positioned(
                        top: 10,
                        left: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Text(
                            'GPS: ${currentPosition!.latitude.toStringAsFixed(6)}, ${currentPosition!.longitude.toStringAsFixed(6)}\n'
                            'Accuracy: ${currentPosition!.accuracy.toStringAsFixed(1)}m',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
      floatingActionButton: currentPosition != null && mapReady
          ? FloatingActionButton(
              onPressed: () {
                _moveToUserLocation();
              },
              backgroundColor: Color.fromARGB(255, 2, 139, 7),
              child: Icon(Icons.my_location, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildTruckMarker() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        Icons.location_on,
        color: Color.fromARGB(255, 2, 139, 7),
        size: 36,
      ),
    );
  }
}
