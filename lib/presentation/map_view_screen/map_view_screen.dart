import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/app_export.dart';
import '../../services/database_helper.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/destination_list_sheet_widget.dart';
import './widgets/map_controls_widget.dart';
import './widgets/search_overlay_widget.dart';

/// Map View Screen - Interactive Google Maps with destination markers
/// Implements dark theme styling with custom markers and clustering
class MapViewScreen extends StatefulWidget {
  const MapViewScreen({super.key});

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  MapType _currentMapType = MapType.normal;
  Position? _currentPosition;
  bool _isLoading = true;
  bool _showSearchOverlay = false;
  String _searchQuery = '';
  LatLng? _selectedLocation;
  bool _mapLoaded = false;

  // Mock destinations data with coordinates
  final List<Map<String, dynamic>> _destinations = [
    {
      "id": 1,
      "name": "Golden Gate Bridge",
      "description": "Iconic suspension bridge spanning the Golden Gate strait",
      "latitude": 37.8199,
      "longitude": -122.4783,
      "image": "https://images.unsplash.com/photo-1622874755957-c86bf0a9178a",
      "semanticLabel":
          "Aerial view of the Golden Gate Bridge spanning across blue water with San Francisco cityscape in background",
      "openingHours": "Open 24 hours",
      "rating": 4.8,
    },
    {
      "id": 2,
      "name": "Alcatraz Island",
      "description":
          "Historic federal prison on an island in San Francisco Bay",
      "latitude": 37.8267,
      "longitude": -122.4233,
      "image": "https://images.unsplash.com/photo-1662141766733-dfc794d59250",
      "semanticLabel":
          "Historic Alcatraz prison building on rocky island surrounded by dark blue ocean waters",
      "openingHours": "9:00 AM - 6:00 PM",
      "rating": 4.6,
    },
    {
      "id": 3,
      "name": "Fisherman's Wharf",
      "description":
          "Waterfront neighborhood with seafood restaurants and shops",
      "latitude": 37.8080,
      "longitude": -122.4177,
      "image": "https://images.unsplash.com/photo-1674771742598-c06f40af1880",
      "semanticLabel":
          "Bustling waterfront pier with colorful shops, restaurants, and boats docked along wooden boardwalk",
      "openingHours": "10:00 AM - 9:00 PM",
      "rating": 4.5,
    },
    {
      "id": 4,
      "name": "Lombard Street",
      "description": "Famous winding street with eight hairpin turns",
      "latitude": 37.8021,
      "longitude": -122.4187,
      "image": "https://images.unsplash.com/photo-1567858616284-77a8cf6134a1",
      "semanticLabel":
          "Steep winding street with red brick road surface lined with colorful flowers and Victorian houses",
      "openingHours": "Open 24 hours",
      "rating": 4.7,
    },
    {
      "id": 5,
      "name": "Palace of Fine Arts",
      "description":
          "Monumental structure with classical architecture and lagoon",
      "latitude": 37.8029,
      "longitude": -122.4486,
      "image": "https://images.unsplash.com/photo-1580941382035-a2b066fd2484",
      "semanticLabel":
          "Classical Roman-style rotunda with columns reflected in calm lagoon water at sunset",
      "openingHours": "6:00 AM - 9:00 PM",
      "rating": 4.9,
    },
  ];

  static const String _darkMapStyle = '''
[
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#242f3e"
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#746855"
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#242f3e"
      }
    ]
  },
  {
    "featureType": "administrative.locality",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#d59563"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#d59563"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#263c3f"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#6b9a76"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#38414e"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#212a37"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9ca5b3"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#746855"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#1f2835"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#f3d19c"
      }
    ]
  },
  {
    "featureType": "transit",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#2f3948"
      }
    ]
  },
  {
    "featureType": "transit.station",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#d59563"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#17263c"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#515c6d"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#17263c"
      }
    ]
  }
]
''';

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _initializeMap() async {
    try {
      await _getCurrentLocation();
      await _createMarkers();
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Unable to load map. Please check location permissions.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      _currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 5),
        ),
      );
    } catch (e) {
      // Silently fail and use default location
    }
  }

  Future<void> _createMarkers() async {
    _markers.clear();
    final destinations = await DatabaseHelper.instance.getAllDestinations();
    for (var destination in destinations) {
      final marker = Marker(
        markerId: MarkerId(destination["id"].toString()),
        position: LatLng(
          destination["latitude"] as double,
          destination["longitude"] as double,
        ),
        infoWindow: InfoWindow(
          title: destination["name"] as String,
          snippet: destination["description"] as String,
          onTap: () => _navigateToDetail(destination["id"] as int),
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
        onTap: () => _onMarkerTapped(destination),
      );
      _markers.add(marker);
    }
  }

  void _onMarkerTapped(Map<String, dynamic> destination) {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedLocation = LatLng(
        destination["latitude"] as double,
        destination["longitude"] as double,
      );
    });

    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(_selectedLocation!, 15),
    );
  }

  void _navigateToDetail(int destinationId) {
    Navigator.pushNamed(
      context,
      '/destination-detail-screen',
      arguments: destinationId,
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    setState(() {
      _mapLoaded = true;
      _isLoading = false;
    });
    _fitAllMarkers();
  }

  void _fitAllMarkers() {
    if (_markers.isEmpty) return;

    LatLngBounds bounds;
    List<LatLng> positions = _markers.map((m) => m.position).toList();

    double minLat = positions.first.latitude;
    double maxLat = positions.first.latitude;
    double minLng = positions.first.longitude;
    double maxLng = positions.first.longitude;

    for (var pos in positions) {
      if (pos.latitude < minLat) minLat = pos.latitude;
      if (pos.latitude > maxLat) maxLat = pos.latitude;
      if (pos.longitude < minLng) minLng = pos.longitude;
      if (pos.longitude > maxLng) maxLng = pos.longitude;
    }

    bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 50),
    );
  }

  void _toggleMapType() {
    HapticFeedback.lightImpact();
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }

  void _centerOnUserLocation() async {
    HapticFeedback.lightImpact();

    if (_currentPosition != null) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          15,
        ),
      );
    } else {
      await _getCurrentLocation();
      if (_currentPosition != null && mounted) {
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
            15,
          ),
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Unable to get current location'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  void _showDestinationList() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DestinationListSheetWidget(
        destinations: _destinations,
        onDestinationSelected: (destination) {
          Navigator.pop(context);
          _onMarkerTapped(destination);
        },
      ),
    );
  }

  void _toggleSearchOverlay() {
    HapticFeedback.lightImpact();
    setState(() => _showSearchOverlay = !_showSearchOverlay);
  }

  void _onSearchQueryChanged(String query) {
    setState(() => _searchQuery = query);
  }

  void _onLocationSelected(LatLng location, String placeName) {
    setState(() {
      _selectedLocation = location;
      _showSearchOverlay = false;
    });

    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(location, 15),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Long press on map to add "$placeName" as destination'),
        action: SnackBarAction(
          label: 'Add',
          onPressed: () {
            Navigator.pushNamed(
              context,
              '/add-destination-screen',
              arguments: {
                'latitude': location.latitude,
                'longitude': location.longitude,
                'name': placeName,
              },
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor:
          Colors.white, // Temporary change to diagnose black screen
      appBar: CustomAppBar(
        title: 'Map View',
        variant: CustomAppBarVariant.standard,
        actions: [
          CustomAppBarAction(
            icon: Icons.search,
            onPressed: _toggleSearchOverlay,
            tooltip: 'Search locations',
          ),
          CustomAppBarAction(
            icon: Icons.list,
            onPressed: _showDestinationList,
            tooltip: 'View destination list',
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: theme.colorScheme.primary,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading map...',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            )
          : !_mapLoaded
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: theme.colorScheme.error,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Unable to load map. Please check your internet connection and API key.',
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isLoading = true;
                            _mapLoaded = false;
                          });
                          _initializeMap();
                        },
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Stack(
                  children: [
                    GoogleMap(
                      key: ValueKey(_isLoading),
                      onMapCreated: _onMapCreated,
                      initialCameraPosition: CameraPosition(
                        target: _currentPosition != null
                            ? LatLng(_currentPosition!.latitude,
                                _currentPosition!.longitude)
                            : LatLng(37.8199, -122.4783),
                        zoom: 12,
                      ),
                      markers: _markers,
                      mapType: _currentMapType,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      compassEnabled: true,
                      mapToolbarEnabled: false,
                      onLongPress: (LatLng location) async {
                        HapticFeedback.mediumImpact();
                        final result = await Navigator.pushNamed(
                          context,
                          '/add-destination-screen',
                          arguments: {
                            'latitude': location.latitude,
                            'longitude': location.longitude,
                          },
                        );
                        if (mounted) {
                          setState(() => _isLoading = true);
                          if (result == true) {
                            await _createMarkers();
                          }
                        }
                      },
                    ),
                    if (_showSearchOverlay)
                      SearchOverlayWidget(
                        searchQuery: _searchQuery,
                        onSearchQueryChanged: _onSearchQueryChanged,
                        onLocationSelected: _onLocationSelected,
                        onClose: _toggleSearchOverlay,
                      ),
                    Positioned(
                      top: 16,
                      right: 16,
                      child: MapControlsWidget(
                        currentMapType: _currentMapType,
                        onToggleMapType: _toggleMapType,
                      ),
                    ),
                    Positioned(
                      bottom: 24,
                      right: 16,
                      child: FloatingActionButton(
                        onPressed: _centerOnUserLocation,
                        tooltip: 'My Location',
                        child: CustomIconWidget(
                          iconName: 'my_location',
                          color: theme.colorScheme.onPrimary,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: 2,
        onTap: (index) {
          if (index != 2) {
            CustomBottomBarNavigation.navigateToIndex(context, index);
          }
        },
      ),
    );
  }
}
