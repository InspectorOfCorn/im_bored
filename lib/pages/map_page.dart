import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? _controller;
  LatLng? _currentPosition;
  Set<Marker> _markers = {}; // Set to store markers

  @override
  void initState() {
    super.initState();
    _checkLocationPermissionAndServices();
  }

  // Check location services and permission
  Future<void> _checkLocationPermissionAndServices() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, so you should handle it here
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
        // Permissions are denied, handle appropriately
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are denied.')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Location permissions are permanently denied.')),
      );
      return;
    }

    // If permissions are granted, get the current location
    await _getCurrentLocation();
    _listenToLocationChanges(); // Start listening to location changes
  }

  // Get the current location when the app starts
  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _addUserMarker(_currentPosition!); // Add marker at current location
        _moveCameraToPosition(); // Move camera to current position
      });
    } catch (e) {
      // Handle errors when trying to get location
      print('Error getting location: $e');
    }
  }

  // Continuously listen to location changes
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

  // Move camera to user's current position
  void _moveCameraToPosition() {
    if (_controller != null && _currentPosition != null) {
      _controller!.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _currentPosition!,
          zoom: 17, // Closer zoom for better tracking
        ),
      ));
    }
  }

  // Add or update the marker at the user's current location
  void _addUserMarker(LatLng position) {
    setState(() {
      _markers = {
        Marker(
          markerId: MarkerId('user_location'), // A unique marker ID
          position: position, // Set the marker at the user's position
          infoWindow: const InfoWindow(title: "You're here!"),
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueAzure), // Highlighted color
        )
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Map'),
        backgroundColor: Colors.purple.withOpacity(0.9), // Increased opacity
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
        elevation: 16, // Add shadow to Drawer
        child: Column(
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.9), // Add opacity to header
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
                color: Colors.white
                    .withOpacity(0.9), // Add opacity to list background
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
              onMapCreated: (GoogleMapController controller) {
                _controller = controller;
                _moveCameraToPosition();
              },
            ),
    );
  }
}
