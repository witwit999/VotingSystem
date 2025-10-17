class MemberModel {
  final String id;
  final String name;
  final String seatNumber;
  final String status; // 'present', 'absent'
  final String? photo;
  final String? title;
  final bool hasMic;

  MemberModel({
    required this.id,
    required this.name,
    required this.seatNumber,
    required this.status,
    this.photo,
    this.title,
    this.hasMic = false,
  });

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      id: json['id'] as String,
      name: json['name'] as String,
      seatNumber: json['seatNumber'] as String,
      status: json['status'] as String,
      photo: json['photo'] as String?,
      title: json['title'] as String?,
      hasMic: json['hasMic'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'seatNumber': seatNumber,
      'status': status,
      'photo': photo,
      'title': title,
      'hasMic': hasMic,
    };
  }

  MemberModel copyWith({
    String? id,
    String? name,
    String? seatNumber,
    String? status,
    String? photo,
    String? title,
    bool? hasMic,
  }) {
    return MemberModel(
      id: id ?? this.id,
      name: name ?? this.name,
      seatNumber: seatNumber ?? this.seatNumber,
      status: status ?? this.status,
      photo: photo ?? this.photo,
      title: title ?? this.title,
      hasMic: hasMic ?? this.hasMic,
    );
  }
}
