import 'dart:convert';
import 'package:http/http.dart' as http;
import '/responses/countries_response.dart';
import '/responses/states_response.dart';
import '/responses/cities_response.dart';

class ApiService {
  static const String liveUrl = "https://countriesnow.space";
  static const String baseUrl = "$liveUrl/api/v0.1";

  static Future<CountriesResponse> getAllCountries() async {
    final url = Uri.parse("$baseUrl/countries/flag/images");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return CountriesResponse.fromJson(jsonData);
    } else {
      throw Exception("Failed to load countries: ${response.body}");
    }
  }

  static Future<StatesResponse> getAllStates(String country) async {
    final url = Uri.parse("$baseUrl/countries/states");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"country": country}),
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return StatesResponse.fromJson(jsonData);
    } else {
      throw Exception("Failed to load states: ${response.body}");
    }
  }

  static Future<CitiesResponse> getAllCities(
    String country,
    String state,
  ) async {
    final url = Uri.parse("$baseUrl/countries/state/cities");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"country": country, "state": state}),
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return CitiesResponse.fromJson(jsonData);
    } else {
      throw Exception("Failed to load cities: ${response.body}");
    }
  }

  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    final url = Uri.parse("$baseUrl/login");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"UserName": username, "Password": password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to login: ${response.body}");
    }
  }
}
