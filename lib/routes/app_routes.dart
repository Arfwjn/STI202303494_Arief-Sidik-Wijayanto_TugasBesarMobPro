import 'package:flutter/material.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/add_destination_screen/add_destination_screen.dart';
import '../presentation/home_screen/home_screen.dart';
import '../presentation/map_view_screen/map_view_screen.dart';
import '../presentation/destination_detail_screen/destination_detail_screen.dart';
import '../presentation/edit_destination_screen/edit_destination_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String splash = '/splash-screen';
  static const String addDestination = '/add-destination-screen';
  static const String home = '/home-screen';
  static const String mapView = '/map-view-screen';
  static const String destinationDetail = '/destination-detail-screen';
  static const String editDestination = '/edit-destination-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    splash: (context) => const SplashScreen(),
    addDestination: (context) => const AddDestinationScreen(),
    home: (context) => const HomeScreen(),
    mapView: (context) => const MapViewScreen(),
    destinationDetail: (context) => const DestinationDetailScreen(),
    editDestination: (context) => EditDestinationScreen(
          destination: ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>,
        ),
    // TODO: Add your other routes here
  };
}
