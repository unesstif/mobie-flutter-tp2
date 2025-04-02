import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/show.dart';
import 'auth_service.dart';

class ShowService {
  final AuthService _authService = AuthService();

  Future<String?> _getAuthToken() async {
    return await _authService.getToken();
  }

  Future<List<Show>> getShows() async {
    final token = await _getAuthToken();
    print('Fetching shows from: ${ApiConfig.baseUrl}/shows');

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/shows'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('Shows response status: ${response.statusCode}');
    print('Shows response body: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      print('Parsed JSON data: $data');

      final shows = data.map((json) {
        print('Processing show: $json');
        final show = Show.fromJson(json);
        print('Created show object:');
        print('  Title: ${show.title}');
        print('  ImageUrl: ${show.imageUrl}');
        print('  FullImageUrl: ${show.fullImageUrl}');
        return show;
      }).toList();

      // Log image URLs for debugging
      for (var show in shows) {
        if (show.imageUrl.isNotEmpty) {
          print('Show: ${show.title}');
          print('Original imageUrl: ${show.imageUrl}');
          print('Full imageUrl: ${show.fullImageUrl}');

          // Test if the image is accessible
          try {
            final imageResponse = await http.head(Uri.parse(show.fullImageUrl));
            print('Image status code: ${imageResponse.statusCode}');
          } catch (e) {
            print('Error testing image URL: $e');
          }
        }
      }

      return shows;
    } else {
      throw Exception('Failed to load shows: ${response.statusCode}');
    }
  }

  Future<Show> addShow(
    String title,
    String description,
    String type,
    File? image,
  ) async {
    final token = await _getAuthToken();
    print('Adding show to: ${ApiConfig.baseUrl}/shows');

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConfig.baseUrl}/shows'),
    );

    // Add headers
    request.headers['Authorization'] = 'Bearer $token';

    // Add fields
    request.fields['title'] = title;
    request.fields['description'] = description;
    request.fields['category'] = type;

    // Add image if provided
    if (image != null) {
      print('Adding image to request: ${image.path}');
      request.files.add(
        await http.MultipartFile.fromPath('image', image.path),
      );
    }

    print('Sending request with fields: ${request.fields}');
    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    print('Add show response status: ${response.statusCode}');
    print('Add show response body: $responseBody');

    if (response.statusCode == 201) {
      final jsonData = json.decode(responseBody);
      final show = Show.fromJson(jsonData);
      print('New show created:');
      print('  Title: ${show.title}');
      print('  ImageUrl: ${show.imageUrl}');
      print('  FullImageUrl: ${show.fullImageUrl}');
      return show;
    } else {
      throw Exception('Failed to add show: ${response.statusCode}');
    }
  }

  Future<void> deleteShow(String id) async {
    final token = await _getAuthToken();
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/shows/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete show');
    }
  }

  Future<Show> updateShow(
    String id,
    String title,
    String description,
    String type,
    File? image,
  ) async {
    final token = await _getAuthToken();
    print('Updating show to: ${ApiConfig.baseUrl}/shows/$id');

    var request = http.MultipartRequest(
      'PUT',
      Uri.parse('${ApiConfig.baseUrl}/shows/$id'),
    );

    // Add headers
    request.headers['Authorization'] = 'Bearer $token';

    // Add fields
    request.fields['title'] = title;
    request.fields['description'] = description;
    request.fields['category'] = type;

    // Add image if provided
    if (image != null) {
      request.files.add(
        await http.MultipartFile.fromPath('image', image.path),
      );
    }

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final jsonData = json.decode(responseBody);
      return Show.fromJson(jsonData);
    } else {
      throw Exception('Failed to update show: ${response.statusCode}');
    }
  }
}
