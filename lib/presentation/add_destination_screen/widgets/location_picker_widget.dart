import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

// Import service yang sudah dibuat
import '../../../services/place_search_service.dart';

/// Widget untuk memilih lokasi dari map dengan fitur search Google Places
class LocationPickerWidget extends StatefulWidget {
  final LatLng? initialLocation;

  const LocationPickerWidget({
    super.key,
    this.initialLocation,
  });

  @override
  State<LocationPickerWidget> createState() => _LocationPickerWidgetState();
}

class _LocationPickerWidgetState extends State<LocationPickerWidget> {
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  LatLng _currentCenter = const LatLng(-7.4297, 109.2401);
  bool _isLoading = true;
  final Set<Marker> _markers = {};

  // Search functionality
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final PlaceSearchService _placeSearchService = PlaceSearchService();
  List<PlaceAutocomplete> _searchResults = [];
  bool _isSearching = false;
  Timer? _debounceTimer;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    // Debounce search - tunggu 800ms setelah user berhenti mengetik
    _debounceTimer?.cancel();

    if (_searchController.text.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _errorMessage = '';
      });
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 800), () {
      _performSearch(_searchController.text.trim());
    });
  }

  Future<void> _performSearch(String query) async {
    print('🔍 Starting search for: $query');

    setState(() {
      _isSearching = true;
      _errorMessage = '';
    });

    try {
      final results = await _placeSearchService.searchPlaces(query);

      print('📍 Search returned ${results.length} results');

      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
          if (results.isEmpty && query.isNotEmpty) {
            _errorMessage = 'No places found for "$query"';
          }
        });
      }
    } catch (e) {
      print('❌ Search error: $e');
      if (mounted) {
        setState(() {
          _isSearching = false;
          _errorMessage =
              'Search failed. Please check your internet connection.';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Search error: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _selectSearchResult(PlaceAutocomplete place) async {
    print('📍 Selected place: ${place.description}');

    setState(() {
      _isSearching = true;
      _errorMessage = '';
    });

    try {
      final details = await _placeSearchService.getPlaceDetails(place.placeId);

      if (details != null && mounted) {
        print('✅ Got details: ${details.name} at ${details.location}');

        setState(() {
          _selectedLocation = details.location;
          _searchResults = [];
          _searchController.text = place.mainText;
          _isSearching = false;
        });

        _updateMarker(details.location);

        // Animate camera ke lokasi
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(details.location, 16),
        );

        // Hilangkan keyboard
        FocusScope.of(context).unfocus();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location selected: ${details.name}'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        throw Exception('Failed to get place details');
      }
    } catch (e) {
      print('❌ Error selecting place: $e');
      if (mounted) {
        setState(() {
          _isSearching = false;
          _errorMessage = 'Failed to get location details';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                const Text('Failed to get place details. Please try again.'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _initializeLocation() async {
    if (widget.initialLocation != null) {
      setState(() {
        _currentCenter = widget.initialLocation!;
        _selectedLocation = widget.initialLocation;
        _isLoading = false;
      });
      _updateMarker(_selectedLocation!);
    } else {
      try {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 10),
          ),
        ).timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw TimeoutException('Location timeout'),
        );

        if (mounted) {
          setState(() {
            _currentCenter = LatLng(position.latitude, position.longitude);
            _isLoading = false;
          });
        }
      } catch (e) {
        print('❌ Error getting location: $e');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_selectedLocation != null) {
      _updateMarker(_selectedLocation!);
    }
  }

  void _onMapTap(LatLng location) {
    setState(() {
      _selectedLocation = location;
    });
    _updateMarker(location);
  }

  void _updateMarker(LatLng location) {
    setState(() {
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('selected_location'),
          position: location,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: 'Selected Location',
            snippet:
                '${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}',
          ),
        ),
      );
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      setState(() => _isLoading = true);

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      final location = LatLng(position.latitude, position.longitude);

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(location, 15),
      );

      _onMapTap(location);

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to get current location'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _confirmLocation() {
    if (_selectedLocation != null) {
      Navigator.pop(context, _selectedLocation);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a location on the map'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Pick Location'),
        actions: [
          TextButton(
            onPressed: _confirmLocation,
            child: Text(
              'CONFIRM',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Map
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            )
          else
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _currentCenter,
                zoom: 15,
              ),
              markers: _markers,
              onTap: _onMapTap,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapType: MapType.normal,
            ),

          // Search bar
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Column(
              children: [
                // Search input
                Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(8),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    decoration: InputDecoration(
                      hintText: 'Search for a place...',
                      prefixIcon: Icon(
                        Icons.search,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchResults = [];
                                  _errorMessage = '';
                                });
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),

                // Error message
                if (_errorMessage.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.orange.shade900,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.orange.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Search results
                if (_searchResults.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    constraints: const BoxConstraints(maxHeight: 300),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: _searchResults.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        color: theme.dividerColor,
                      ),
                      itemBuilder: (context, index) {
                        final place = _searchResults[index];
                        return ListTile(
                          leading: Icon(
                            Icons.place,
                            color: theme.colorScheme.primary,
                          ),
                          title: Text(
                            place.mainText,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: place.secondaryText.isNotEmpty
                              ? Text(
                                  place.secondaryText,
                                  style: theme.textTheme.bodySmall,
                                )
                              : null,
                          onTap: () => _selectSearchResult(place),
                        );
                      },
                    ),
                  ),

                // Loading indicator for search
                if (_isSearching)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Searching...',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Selected location info card
          if (_selectedLocation != null &&
              _searchResults.isEmpty &&
              !_isSearching)
            Positioned(
              bottom: 100,
              left: 16,
              right: 16,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Selected Location',
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Lat: ${_selectedLocation!.latitude.toStringAsFixed(6)}',
                        style: theme.textTheme.bodyMedium,
                      ),
                      Text(
                        'Lng: ${_selectedLocation!.longitude.toStringAsFixed(6)}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // My location button
          Positioned(
            bottom: 24,
            right: 16,
            child: FloatingActionButton(
              onPressed: _getCurrentLocation,
              tooltip: 'My Location',
              child: Icon(
                Icons.my_location,
                color: theme.colorScheme.onPrimary,
              ),
            ),
          ),

          // Instructions
          if (_selectedLocation == null &&
              _searchResults.isEmpty &&
              !_isSearching)
            Positioned(
              bottom: 24,
              left: 16,
              right: 80,
              child: Card(
                color: theme.colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Search or tap on the map to select a location',
                          style: theme.textTheme.bodySmall,
                        ),
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
