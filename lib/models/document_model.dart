class DocumentModel {
  final String id;
  final String title;
  final String type; // 'pdf', 'image', 'word', etc.
  final String url;
  final DateTime uploadedAt;
  final String uploadedBy;
  final int size; // in bytes
  final String visibility; // 'all' or 'admin_only'

  DocumentModel({
    required this.id,
    required this.title,
    required this.type,
    required this.url,
    required this.uploadedAt,
    required this.uploadedBy,
    required this.size,
    this.visibility = 'all', // default to all members
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'] as String,
      title: json['title'] as String,
      type: json['type'] as String,
      url: json['url'] as String,
      uploadedAt: DateTime.parse(json['uploadedAt'] as String),
      uploadedBy: json['uploadedBy'] as String,
      size: json['size'] as int,
      visibility: json['visibility'] as String? ?? 'all',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'url': url,
      'uploadedAt': uploadedAt.toIso8601String(),
      'uploadedBy': uploadedBy,
      'size': size,
      'visibility': visibility,
    };
  }

  String get sizeInMB {
    return (size / (1024 * 1024)).toStringAsFixed(2);
  }

  DocumentModel copyWith({
    String? id,
    String? title,
    String? type,
    String? url,
    DateTime? uploadedAt,
    String? uploadedBy,
    int? size,
    String? visibility,
  }) {
    return DocumentModel(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      url: url ?? this.url,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      size: size ?? this.size,
      visibility: visibility ?? this.visibility,
    );
  }
}
