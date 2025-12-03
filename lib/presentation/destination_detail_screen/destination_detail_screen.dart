import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/destination_actions_widget.dart';
import './widgets/destination_header_widget.dart';
import './widgets/destination_info_widget.dart';

/// Destination Detail Screen displaying comprehensive destination information
class DestinationDetailScreen extends StatefulWidget {
  const DestinationDetailScreen({super.key});

  @override
  State<DestinationDetailScreen> createState() =>
      _DestinationDetailScreenState();
}

class _DestinationDetailScreenState extends State<DestinationDetailScreen> {
  // Mock destination data
  final Map<String, dynamic> _destinationData = {
    "id": 1,
    "name": "Golden Gate Bridge",
    "description":
        "The Golden Gate Bridge is a suspension bridge spanning the Golden Gate, the one-mile-wide strait connecting San Francisco Bay and the Pacific Ocean. The structure links the U.S. city of San Francisco, California—the northern tip of the San Francisco Peninsula—to Marin County, carrying both U.S. Route 101 and California State Route 1 across the strait. It has been declared one of the Wonders of the Modern World by the American Society of Civil Engineers.",
    "openingHours": "Open 24 hours",
    "latitude": 37.8199,
    "longitude": -122.4783,
    "imageUrl": "https://images.unsplash.com/photo-1727402041671-3ca1420e35c4",
    "semanticLabel":
        "Iconic orange-red Golden Gate Bridge spanning across blue waters with San Francisco skyline in background under clear sky",
  };

  void _showDeleteConfirmation() {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.primaryContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'warning',
              color: theme.colorScheme.error,
              size: 24,
            ),
            SizedBox(width: 2.w),
            Text(
              'Delete Destination',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${_destinationData["name"]}"? This action cannot be undone.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: Text(
              'Cancel',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              Navigator.pop(context);
              _deleteDestination();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            child: Text(
              'Delete',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onError,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteDestination() {
    final theme = Theme.of(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'check_circle',
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: Text(
                'Destination deleted successfully',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: theme.colorScheme.tertiary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );

    // Navigate back to home screen after deletion
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home-screen');
      }
    });
  }

  void _navigateToEdit() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(
      context,
      '/edit-destination-screen',
      arguments: _destinationData,
    );
  }

  void _navigateToMap() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(
      context,
      '/map-view-screen',
      arguments: {
        'latitude': _destinationData['latitude'],
        'longitude': _destinationData['longitude'],
        'name': _destinationData['name'],
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // Hero header with image and actions
          SliverToBoxAdapter(
            child: DestinationHeaderWidget(
              imageUrl: _destinationData['imageUrl'] as String,
              semanticLabel: _destinationData['semanticLabel'] as String,
              onBack: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
              },
              onEdit: _navigateToEdit,
              onDelete: _showDeleteConfirmation,
            ),
          ),

          // Destination information
          SliverToBoxAdapter(
            child: DestinationInfoWidget(
              name: _destinationData['name'] as String,
              description: _destinationData['description'] as String,
              openingHours: _destinationData['openingHours'] as String,
              latitude: _destinationData['latitude'] as double,
              longitude: _destinationData['longitude'] as double,
            ),
          ),

          // Action buttons
          SliverToBoxAdapter(
            child: DestinationActionsWidget(
              latitude: _destinationData['latitude'] as double,
              longitude: _destinationData['longitude'] as double,
              onViewOnMap: _navigateToMap,
            ),
          ),

          // Bottom spacing
          SliverToBoxAdapter(
            child: SizedBox(height: 4.h),
          ),
        ],
      ),
    );
  }
}
