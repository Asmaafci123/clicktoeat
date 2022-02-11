// For storing our result

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:geocoder2/geocoder2.dart';
import 'package:http/http.dart';
import 'package:mealup/utils/widgets/constants.dart';

class Place {
  String? streetNumber;
  String? street;
  String? city;
  String? zipCode;

  Place({
    this.streetNumber,
    this.street,
    this.city,
    this.zipCode,
  });

  @override
  String toString() {
    return 'Place(streetNumber: $streetNumber, street: $street, city: $city, zipCode: $zipCode)';
  }
}

class Suggestion {
  final String placeId;
  final String description;

  Suggestion(this.placeId, this.description);

  @override
  String toString() {
    return 'Suggestion(description: $description, placeId: $placeId)';
  }
}

class SuggestionWithLatLong {
  final String placeId;
  final String description;
  final double lat;
  final double long;

  SuggestionWithLatLong(this.placeId, this.description, this.lat, this.long);

  @override
  String toString() {
    return 'Suggestion1(description: $description, placeId: $placeId, lat: $lat, long: $long)';
  }
}

class PlaceApiProvider {
  final client = Client();

  PlaceApiProvider(this.sessionToken);

  final String sessionToken;

  final apiKey = Platform.isAndroid ? Constants.androidKey : Constants.iosKey;

  int i = 0;
  int j = 0;
  int k = 0;

  Future<List<Suggestion>> fetchSuggestions(String input, String lang) async {
    print('Suggestions Count: ${i++}');
    final request = 'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&types=address&language=$lang&key=$apiKey&sessiontoken=$sessionToken';
    // &components=country:ch
    final response = await client.get(Uri.parse(request));

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'OK') {
        // compose suggestions in a list
        return result['predictions'].map<Suggestion>((p) => Suggestion(p['place_id'], p['description'])).toList();
      }
      if (result['status'] == 'ZERO_RESULTS') {
        return [];
      }
      throw Exception(result['error_message']);
    } else {
      throw Exception('Failed to fetch suggestion');
    }
  }

  Future<List<SuggestionWithLatLong>> fetchLatitudeLongitude(String input, String lang) async {
    print('Latitude Longitude Count: ${j++}');
    final request = 'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&types=address&language=$lang&key=$apiKey&sessiontoken=$sessionToken';
    // &components=country:ch
    final response = await client.get(Uri.parse(request));
    // List<Suggestion1> suggestion = [];
    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      print(result);
      if (result['status'] == 'OK') {
        try {
          // compose suggestions in a list
          // List<Location> locations = [];
          // locations = await locationFromAddress(result['predictions'].toString());

          var locations = await Geocoder2.getCoordinatesFromAddress(address: result['predictions'].toString(), googleMapApiKey: apiKey);

          double lat = locations.results.first.geometry.location.lat;
          double long = locations.results.first.geometry.location.lng;

          return result['predictions'].map<SuggestionWithLatLong>((p) => SuggestionWithLatLong(p['place_id'], p['description'], lat, long)).toList();
        } catch (e) {
          rethrow;
        }
      }
      if (result['status'] == 'ZERO_RESULTS') {
        return [];
      }
      print(result['error_message'] ?? '');
      throw Exception(result['error_message']);
    } else {
      throw Exception('Failed to fetch suggestion');
    }
  }

  Future<Place> getPlaceDetailFromId(String placeId) async {
    print('Places Count: ${k++}');
    final String request = 'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=address_component&key=$apiKey&sessiontoken=$sessionToken';
    final response = await client.get(Uri.parse(request));

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      print(result);
      if (result['status'] == 'OK') {
        final components = result['result']['address_components'] as List<dynamic>;
        // build result
        final place = Place();
        components.forEach((c) {
          final List type = c['types'];
          if (type.contains('street_number')) {
            place.streetNumber = c['long_name'];
          }
          if (type.contains('route')) {
            place.street = c['long_name'];
          }
          if (type.contains('locality')) {
            place.city = c['long_name'];
          }
          if (type.contains('postal_code')) {
            place.zipCode = c['long_name'];
          }
        });
        return place;
      }
      throw Exception(result['error_message']);
    } else {
      throw Exception('Failed to fetch suggestion');
    }
  }
}
