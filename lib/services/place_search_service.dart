import 'dart:convert';
import 'package:http/http.dart' as http;

class PlaceSearchService {
  final String apiKey;

  PlaceSearchService(this.apiKey);

  // Mendapatkan saran lokasi saat mengetik (Autocomplete)
  Future<List<PlaceSuggestion>> fetchSuggestions(
      String input, String sessionToken) async {
    final request =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$apiKey&sessiontoken=$sessionToken';

    final response = await http.get(Uri.parse(request));

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'OK') {
        return (result['predictions'] as List)
            .map<PlaceSuggestion>((p) => PlaceSuggestion.fromJson(p))
            .toList();
      }
      if (result['status'] == 'ZERO_RESULTS') {
        return [];
      }
      throw Exception(result['error_message']);
    } else {
      throw Exception('Failed to fetch suggestions');
    }
  }

  // Mendapatkan detail koordinat (Lat/Lng) dari Place ID
  Future<Map<String, dynamic>> getPlaceDetailFromId(String placeId) async {
    final request =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=geometry&key=$apiKey';

    final response = await http.get(Uri.parse(request));

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'OK') {
        final location = result['result']['geometry']['location'];
        return {
          'lat': location['lat'],
          'lng': location['lng'],
        };
      }
      throw Exception(result['error_message']);
    } else {
      throw Exception('Failed to load place details');
    }
  }
}

class PlaceSuggestion {
  final String placeId;
  final String description;

  PlaceSuggestion({required this.placeId, required this.description});

  factory PlaceSuggestion.fromJson(Map<String, dynamic> json) {
    return PlaceSuggestion(
      placeId: json['place_id'],
      description: json['description'],
    );
  }
}
