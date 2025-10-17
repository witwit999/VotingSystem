class UserModel {
  final String id;
  final String username;
  final String displayName;
  final String role; // 'ADMIN' or 'USER'
  final String? photo;
  final String? title;
  final String? seatNumber;

  UserModel({
    required this.id,
    required this.username,
    required this.displayName,
    required this.role,
    this.photo,
    this.title,
    this.seatNumber,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      username: json['username'] as String,
      displayName: json['displayName'] as String,
      role: json['role'] as String,
      photo: json['photo'] as String?,
      title: json['title'] as String?,
      seatNumber: json['seatNumber'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'displayName': displayName,
      'role': role,
      if (photo != null) 'photo': photo,
      if (title != null) 'title': title,
      if (seatNumber != null) 'seatNumber': seatNumber,
    };
  }

  UserModel copyWith({
    String? id,
    String? username,
    String? displayName,
    String? role,
    String? photo,
    String? title,
    String? seatNumber,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      photo: photo ?? this.photo,
      title: title ?? this.title,
      seatNumber: seatNumber ?? this.seatNumber,
    );
  }

  // Helper getter for backward compatibility with UI
  String get name => displayName;
  String get email => username;
}
