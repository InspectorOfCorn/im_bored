import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

/// A page that displays a map and handles location-related functionality.
///
/// This page is responsible for checking location permissions, enabling location
/// services, and displaying the user's current location on a map.

/// The main map page widget.
class MapPage extends StatefulWidget {
  /// Creates a new instance of [MapPage].
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

/// The state for the [MapPage] widget.
class _MapPageState extends State<MapPage> {
  GoogleMapController? _controller;
  LatLng? _currentPosition;
  Set<Marker> _markers = {};
  final Set<Circle> _circles = {};
  final Set<Polygon> _polygons = {};

  @override
  void initState() {
    super.initState();
    _checkLocationPermissionAndServices();
  }

  /// Checks location permissions and services.
  ///
  /// This method verifies if location services are enabled and if the app
  /// has the necessary permissions to access the device's location.
  ///
  /// If permissions are denied or services are disabled, it shows appropriate
  /// error messages to the user.
  Future<void> _checkLocationPermissionAndServices() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location services are disabled.')),
      );
      return;
    }

    // Request location permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are denied.')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Location permissions are permanently denied.')),
      );
      return;
    }

    // If permissions are granted, get the current location and start tracking
    await _getCurrentLocation();
    _listenToLocationChanges();
  }

  /// Gets the user's current location when the app starts.
  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _addUserMarker(_currentPosition!);
        _moveCameraToPosition();
      });
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  /// Continuously listens to location changes and updates the map.
  void _listenToLocationChanges() {
    Geolocator.getPositionStream(
      desiredAccuracy: LocationAccuracy.high,
      distanceFilter: 5,
    ).listen((Position position) {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _addUserMarker(_currentPosition!);
        _moveCameraToPosition();
      });
    });
  }

  /// Moves the camera to the user's current position.
  void _moveCameraToPosition() {
    if (_controller != null && _currentPosition != null) {
      _controller!.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _currentPosition!,
          zoom: 17,
        ),
      ));
    }
  }

  /// Adds or updates the marker at the user's current location.
  void _addUserMarker(LatLng position) {
    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('user_location'),
          position: position,
          infoWindow: const InfoWindow(title: "You're here!"),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        )
      };
    });
  }

  /// Adds a circle to the map.
  void _addCircle(LatLng center, double radius) {
    final String circleId = 'circle_${_circles.length + 1}';
    setState(() {
      _circles.add(
        Circle(
          circleId: CircleId(circleId),
          center: center,
          radius: radius,
          fillColor: Colors.blue.withOpacity(0.3),
          strokeColor: Colors.blue,
          strokeWidth: 2,
        ),
      );
    });
  }

  /// Adds a polygon to the map.
  void _addPolygon(List<LatLng> points) {
    final String polygonId = 'polygon_${_polygons.length + 1}';
    setState(() {
      _polygons.add(
        Polygon(
          polygonId: PolygonId(polygonId),
          points: points,
          fillColor: Colors.red.withOpacity(0.3),
          strokeColor: Colors.red,
          strokeWidth: 2,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Map'),
        backgroundColor: Colors.purple.withOpacity(0.9),
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.purple.withOpacity(0.7),
                Colors.purple.withOpacity(0.5),
              ],
            ),
          ),
        ),
      ),
      drawer: Drawer(
        elevation: 16,
        child: Column(
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.9),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.white.withOpacity(0.9),
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: <Widget>[
                    ListTile(
                      leading: const Icon(Icons.settings, color: Colors.purple),
                      title: const Text('Settings',
                          style: TextStyle(fontSize: 16)),
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: Navigate to settings page
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.info, color: Colors.purple),
                      title:
                          const Text('About', style: TextStyle(fontSize: 16)),
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: Show about dialog or navigate to about page
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: _currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentPosition!,
                zoom: 17,
              ),
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              markers: _markers,
              circles: _circles, // Add circles to the map
              polygons: _polygons, // Add polygons to the map
              onMapCreated: (GoogleMapController controller) {
                _controller = controller;
                _moveCameraToPosition();
              },
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              if (_currentPosition != null) {
                _addCircle(_currentPosition!, 100);
              }
            },
            child: const Icon(Icons.add_circle_outline),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () {
              if (_currentPosition != null) {
                final LatLng p1 = _currentPosition!;
                final LatLng p2 =
                    LatLng(p1.latitude + 0.001, p1.longitude - 0.001);
                final LatLng p3 =
                    LatLng(p1.latitude - 0.001, p1.longitude + 0.001);
                _addPolygon([p1, p2, p3]);
              }
            },
            child: const Icon(Icons.add_box_outlined),
          ),
        ],
      ),
    );
  }
}
