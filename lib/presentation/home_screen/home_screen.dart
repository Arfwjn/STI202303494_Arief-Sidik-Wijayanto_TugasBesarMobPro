import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/destination_card_widget.dart';
import './widgets/empty_state_widget.dart';
import './widgets/search_bar_widget.dart';

/// Home Screen - Primary destination discovery hub
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  bool _isRefreshing = false;

  final List<Map<String, dynamic>> _destinations = [
    {
      "id": 1,
      "name": "Golden Gate Bridge",
      "description":
          "Iconic suspension bridge spanning the Golden Gate strait, offering breathtaking views of San Francisco Bay.",
      "openingHours": "24/7",
      "latitude": "37.8199",
      "longitude": "-122.4783",
      "photo": "https://images.unsplash.com/photo-1727402041671-3ca1420e35c4",
      "semanticLabel":
          "Aerial view of the iconic red-orange Golden Gate Bridge spanning across blue waters with San Francisco cityscape in the background under clear sky"
    },
    {
      "id": 2,
      "name": "Central Park",
      "description":
          "Urban park in Manhattan, New York City, featuring lakes, theaters, ice rinks, fountains, tennis courts, playgrounds, and bridle paths.",
      "openingHours": "6:00 AM - 1:00 AM",
      "latitude": "40.7829",
      "longitude": "-73.9654",
      "photo": "https://images.unsplash.com/photo-1629598054447-db09bfc4da45",
      "semanticLabel":
          "Scenic view of Central Park with lush green trees, walking paths, and people enjoying outdoor activities with Manhattan skyscrapers visible in the distance"
    },
    {
      "id": 3,
      "name": "Grand Canyon",
      "description":
          "Steep-sided canyon carved by the Colorado River in Arizona, known for its visually overwhelming size and intricate landscape.",
      "openingHours": "Open 24 hours",
      "latitude": "36.1069",
      "longitude": "-112.1129",
      "photo": "https://images.unsplash.com/photo-1692235321379-0c63a8cd90cb",
      "semanticLabel":
          "Panoramic view of the Grand Canyon showing layered red and orange rock formations with deep valleys and the Colorado River visible below under blue sky"
    },
    {
      "id": 4,
      "name": "Statue of Liberty",
      "description":
          "Colossal neoclassical sculpture on Liberty Island in New York Harbor, a symbol of freedom and democracy.",
      "openingHours": "9:00 AM - 5:00 PM",
      "latitude": "40.6892",
      "longitude": "-74.0445",
      "photo": "https://images.unsplash.com/photo-1511741390939-dcb97d683e8f",
      "semanticLabel":
          "The Statue of Liberty standing tall on Liberty Island with her torch raised high, copper-green patina visible against blue sky and water"
    },
    {
      "id": 5,
      "name": "Yellowstone National Park",
      "description":
          "America's first national park, famous for its geothermal features, wildlife, and stunning natural beauty.",
      "openingHours": "Open year-round",
      "latitude": "44.4280",
      "longitude": "-110.5885",
      "photo": "https://images.unsplash.com/photo-1727467044803-ef7f6ef8c0a3",
      "semanticLabel":
          "Colorful Grand Prismatic Spring in Yellowstone with vibrant blue center surrounded by orange and yellow bacterial mats, steam rising from hot water"
    },
  ];

  List<Map<String, dynamic>> get _filteredDestinations {
    if (_searchQuery.isEmpty) {
      return _destinations;
    }
    return _destinations.where((destination) {
      final name = (destination['name'] as String).toLowerCase();
      final description = (destination['description'] as String).toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || description.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Travvel',
          style: theme.appBarTheme.titleTextStyle,
        ),
        actions: [
          IconButton(
            icon: CustomIconWidget(
              iconName: 'filter_list',
              color: theme.colorScheme.onSurface,
              size: 24,
            ),
            onPressed: _showFilterOptions,
            tooltip: 'Filter',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            SearchBarWidget(
              onSearch: (query) {
                setState(() {
                  _searchQuery = query;
                });
              },
              initialQuery: _searchQuery,
            ),
            Expanded(
              child: _filteredDestinations.isEmpty
                  ? _searchQuery.isEmpty
                      ? EmptyStateWidget(
                          onAddDestination: _navigateToAddDestination,
                        )
                      : _buildNoResultsWidget(theme)
                  : RefreshIndicator(
                      onRefresh: _handleRefresh,
                      color: theme.colorScheme.primary,
                      child: ListView.builder(
                        itemCount: _filteredDestinations.length,
                        padding: const EdgeInsets.only(bottom: 80),
                        itemBuilder: (context, index) {
                          final destination = _filteredDestinations[index];
                          return DestinationCardWidget(
                            destination: destination,
                            onTap: () =>
                                _navigateToDestinationDetail(destination),
                            onEdit: () =>
                                _navigateToEditDestination(destination),
                            onDelete: () =>
                                _showDeleteConfirmation(destination),
                            onViewOnMap: () => _navigateToMapView(destination),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddDestination,
        icon: CustomIconWidget(
          iconName: 'add',
          color: theme.colorScheme.onPrimary,
          size: 24,
        ),
        label: const Text('Add Destination'),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: 0,
        onTap: (index) {
          if (index != 0) {
            CustomBottomBarNavigation.navigateToIndex(context, index);
          }
        },
      ),
    );
  }

  Widget _buildNoResultsWidget(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'search_off',
              color: theme.colorScheme.onSurfaceVariant,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'No Results Found',
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search terms',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleRefresh() async {
    HapticFeedback.mediumImpact();
    setState(() {
      _isRefreshing = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isRefreshing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Destinations refreshed'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {},
          ),
        ),
      );
    }
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final theme = Theme.of(context);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Filter Options',
                  style: theme.textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'sort_by_alpha',
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                title: Text(
                  'Sort by Name',
                  style: theme.textTheme.bodyLarge,
                ),
                onTap: () {
                  Navigator.pop(context);
                  _sortByName();
                },
              ),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'access_time',
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                title: Text(
                  'Sort by Opening Hours',
                  style: theme.textTheme.bodyLarge,
                ),
                onTap: () {
                  Navigator.pop(context);
                  _sortByOpeningHours();
                },
              ),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'location_on',
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                title: Text(
                  'Sort by Location',
                  style: theme.textTheme.bodyLarge,
                ),
                onTap: () {
                  Navigator.pop(context);
                  _sortByLocation();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _sortByName() {
    setState(() {
      _destinations
          .sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sorted by name'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _sortByOpeningHours() {
    setState(() {
      _destinations.sort((a, b) =>
          (a['openingHours'] as String).compareTo(b['openingHours'] as String));
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sorted by opening hours'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _sortByLocation() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Location-based sorting available in Map View'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _navigateToAddDestination() {
    Navigator.pushNamed(context, '/add-destination-screen');
  }

  void _navigateToDestinationDetail(Map<String, dynamic> destination) {
    Navigator.pushNamed(
      context,
      '/destination-detail-screen',
      arguments: destination,
    );
  }

  void _navigateToEditDestination(Map<String, dynamic> destination) {
    Navigator.pushNamed(
      context,
      '/edit-destination-screen',
      arguments: destination,
    );
  }

  void _navigateToMapView(Map<String, dynamic> destination) {
    Navigator.pushNamed(
      context,
      '/map-view-screen',
      arguments: destination,
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> destination) {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            'Delete Destination',
            style: theme.textTheme.titleLarge,
          ),
          content: Text(
            'Are you sure you want to delete "${destination['name']}"? This action cannot be undone.',
            style: theme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteDestination(destination);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _deleteDestination(Map<String, dynamic> destination) {
    HapticFeedback.mediumImpact();
    setState(() {
      _destinations.removeWhere((d) => d['id'] == destination['id']);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${destination['name']} deleted'),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _destinations.add(destination);
            });
          },
        ),
      ),
    );
  }
}
