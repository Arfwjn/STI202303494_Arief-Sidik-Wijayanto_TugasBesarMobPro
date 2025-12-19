import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Service untuk mencari tempat menggunakan Google Places API
class PlaceSearchService {
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/place';

  // IMPORTANT: Ganti dengan API Key Anda yang sudah enable Places API
  static const String _apiKey = 'AIzaSyDelfYcbxnCJKF5X56clemyFIZbAQKI4Oo';

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  /// Autocomplete - mencari tempat berdasarkan query text
  Future<List<PlaceAutocomplete>> searchPlaces(String query) async {
    if (query.trim().isEmpty) return [];

    print('Searching places for: $query');

    try {
      final response = await _dio.get(
        '$_baseUrl/autocomplete/json',
        queryParameters: {
          'input': query,
          'key': _apiKey,
          'language': 'id', // Bahasa Indonesia
          'components': 'country:id', // Filter hanya Indonesia
        },
      );

      print('Places API Response Status: ${response.statusCode}');
      print('Places API Response: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['status'] == 'OK') {
          final predictions = data['predictions'] as List;
          print('Found ${predictions.length} places');
          return predictions.map((p) => PlaceAutocomplete.fromJson(p)).toList();
        } else if (data['status'] == 'ZERO_RESULTS') {
          print('No results found');
          return [];
        } else {
          print('Places API Error: ${data['status']}');
          if (data['error_message'] != null) {
            print('Error message: ${data['error_message']}');
          }
          return [];
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
        return [];
      }
    } on DioException catch (e) {
      print('Dio Error: ${e.message}');
      print('Dio Error Type: ${e.type}');
      if (e.response != null) {
        print('Response status: ${e.response?.statusCode}');
        print('Response data: ${e.response?.data}');
      }
      return [];
    } catch (e) {
      print('Error searching places: $e');
      return [];
    }
  }

  /// Place Details - mendapatkan detail lengkap termasuk koordinat
  Future<PlaceDetails?> getPlaceDetails(String placeId) async {
    print('Getting place details for: $placeId');

    try {
      final response = await _dio.get(
        '$_baseUrl/details/json',
        queryParameters: {
          'place_id': placeId,
          'key': _apiKey,
          'language': 'id',
          'fields': 'name,formatted_address,geometry,place_id,types',
        },
      );

      print('Place Details Response: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['status'] == 'OK') {
          print('Got place details successfully');
          return PlaceDetails.fromJson(data['result']);
        } else {
          print('Place Details Error: ${data['status']}');
          if (data['error_message'] != null) {
            print('Error message: ${data['error_message']}');
          }
          return null;
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
        return null;
      }
    } on DioException catch (e) {
      print('Dio Error: ${e.message}');
      if (e.response != null) {
        print('Response data: ${e.response?.data}');
      }
      return null;
    } catch (e) {
      print('Error getting place details: $e');
      return null;
    }
  }

  /// Nearby Search - mencari tempat di sekitar lokasi tertentu
  Future<List<PlaceDetails>> searchNearby({
    required LatLng location,
    double radius = 5000, // dalam meter
    String? type, // restaurant, cafe, tourist_attraction, dll
  }) async {
    print(
        '🔍 Searching nearby places at: ${location.latitude}, ${location.longitude}');

    try {
      final response = await _dio.get(
        '$_baseUrl/nearbysearch/json',
        queryParameters: {
          'location': '${location.latitude},${location.longitude}',
          'radius': radius.toString(),
          if (type != null) 'type': type,
          'key': _apiKey,
          'language': 'id',
        },
      );

      print('Nearby Search Response: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['status'] == 'OK') {
          final results = data['results'] as List;
          print('Found ${results.length} nearby places');
          return results.map((r) => PlaceDetails.fromJson(r)).toList();
        } else if (data['status'] == 'ZERO_RESULTS') {
          print('No nearby places found');
          return [];
        } else {
          print('Nearby Search Error: ${data['status']}');
          return [];
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
        return [];
      }
    } on DioException catch (e) {
      print('Dio Error: ${e.message}');
      return [];
    } catch (e) {
      print('Error searching nearby: $e');
      return [];
    }
  }
}

/// Model untuk Autocomplete result
class PlaceAutocomplete {
  final String placeId;
  final String description;
  final String mainText;
  final String secondaryText;

  PlaceAutocomplete({
    required this.placeId,
    required this.description,
    required this.mainText,
    required this.secondaryText,
  });

  factory PlaceAutocomplete.fromJson(Map<String, dynamic> json) {
    final structuredFormatting = json['structured_formatting'] ?? {};
    return PlaceAutocomplete(
      placeId: json['place_id'] ?? '',
      description: json['description'] ?? '',
      mainText: structuredFormatting['main_text'] ?? json['description'] ?? '',
      secondaryText: structuredFormatting['secondary_text'] ?? '',
    );
  }

  @override
  String toString() {
    return 'PlaceAutocomplete(placeId: $placeId, description: $description)';
  }
}

/// Model untuk Place Details
class PlaceDetails {
  final String placeId;
  final String name;
  final String address;
  final LatLng location;
  final List<String> types;

  PlaceDetails({
    required this.placeId,
    required this.name,
    required this.address,
    required this.location,
    required this.types,
  });

  factory PlaceDetails.fromJson(Map<String, dynamic> json) {
    final geometry = json['geometry'] ?? {};
    final locationData = geometry['location'] ?? {};

    return PlaceDetails(
      placeId: json['place_id'] ?? '',
      name: json['name'] ?? '',
      address: json['formatted_address'] ?? json['vicinity'] ?? '',
      location: LatLng(
        (locationData['lat'] ?? 0.0).toDouble(),
        (locationData['lng'] ?? 0.0).toDouble(),
      ),
      types: (json['types'] as List?)?.cast<String>() ?? [],
    );
  }

  @override
  String toString() {
    return 'PlaceDetails(name: $name, location: ${location.latitude}, ${location.longitude})';
  }
}
