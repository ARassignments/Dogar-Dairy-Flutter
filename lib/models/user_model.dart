class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String profileImage;
  final String role;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.profileImage,
    this.role = 'user',
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      profileImage: map['profile_image_url'] ?? '',
      role: map['role'] ?? 'user',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'profile_image_url': profileImage,
      'role': role,
    };
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? profileImage,
    String? role,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      profileImage: profileImage ?? this.profileImage,
      role: role ?? this.role,
    );
  }
}