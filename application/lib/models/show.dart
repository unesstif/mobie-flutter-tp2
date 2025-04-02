import '../config/api_config.dart';

class Show {
  final String id;
  final String title;
  final String type;
  final String description;
  final String imageUrl;
  final double? rating;

  Show({
    required this.id,
    required this.title,
    required this.type,
    required this.description,
    required this.imageUrl,
    this.rating,
  });

  factory Show.fromJson(Map<String, dynamic> json) {
    // Convert ID to string regardless of its type (int or string)
    final id = json['_id']?.toString() ?? json['id']?.toString() ?? '';

    // Get the image URL from the response
    String imageUrl = json['image'] ?? '';
    print('Original image URL from JSON: $imageUrl');

    // If the image URL is a base64 string, use it directly
    if (imageUrl.startsWith('data:image')) {
      print('Using base64 image directly');
      return Show(
        id: id,
        title: json['title'] ?? '',
        type: json['category'] ?? json['type'] ?? '',
        description: json['description'] ?? '',
        imageUrl: imageUrl,
        rating:
            json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      );
    }

    // No need to clean up the URL anymore - we'll handle it in fullImageUrl
    print('Using image URL as provided: $imageUrl');

    return Show(
      id: id,
      title: json['title'] ?? '',
      type: json['category'] ?? json['type'] ?? '',
      description: json['description'] ?? '',
      imageUrl: imageUrl,
      rating:
          json['rating'] != null ? (json['rating'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': type,
      'description': description,
      'image': imageUrl,
      if (rating != null) 'rating': rating,
    };
  }

  // Helper method to get the complete image URL
  String get fullImageUrl {
    if (imageUrl.isEmpty) return '';
    if (imageUrl.startsWith('http')) return imageUrl;
    if (imageUrl.startsWith('data:image')) return imageUrl;
    if (imageUrl.startsWith('/')) {
      // If the URL starts with a slash, just append it to the base URL
      final url = ApiConfig.baseUrl + imageUrl;
      print('Constructed full image URL: $url');
      return url;
    }

    // For all other cases, ensure we don't duplicate the uploads directory
    final url = imageUrl.startsWith('uploads/')
        ? '${ApiConfig.baseUrl}/${imageUrl}'
        : '${ApiConfig.baseUrl}/uploads/$imageUrl';
    print('Constructed full image URL: $url');
    return url;
  }
}
