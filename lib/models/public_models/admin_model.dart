// models/public_models/admin_model.dart
class AdminModel {
  final String id;
  final String firstName;
  final String fatherName;
  final String lastName;
  final String fullName;
  final String? profilePhoto;
  final String? bio;

  AdminModel({
    required this.id,
    required this.firstName,
    required this.fatherName,
    required this.lastName,
    required this.fullName,
    this.profilePhoto,
    this.bio,
  });

  factory AdminModel.fromJson(Map<String, dynamic> json) {
    final profile = json['profile'] ?? {};

    // ✅ profile_photo ممكن توصل كـ String مباشر، أو كـ Map فيها المسار
    String? extractPhotoUrl(dynamic value) {
      if (value == null) return null;
      if (value is String) return value.isEmpty ? null : value;
      if (value is Map) {
        // جرب المفاتيح الشائعة يلي ممكن الباك يرجعها
        final url = value['url'] ?? value['path'] ?? value['filename'] ?? value['image'];
        if (url is String && url.isNotEmpty) return url;
      }
      return null;
    }

    return AdminModel(
      id: json['_id']?.toString() ?? '',
      firstName: profile['first_name']?.toString() ?? '',
      fatherName: profile['father_name']?.toString() ?? '',
      lastName: profile['last_name']?.toString() ?? '',
      fullName: profile['full_name']?.toString() ?? '',
      profilePhoto: extractPhotoUrl(profile['profile_photo']),
      bio: profile['bio']?.toString(),
    );
  }
}