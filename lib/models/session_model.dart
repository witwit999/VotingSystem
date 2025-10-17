class SessionModel {
  final String id;
  final String title;
  final String speaker;
  final DateTime startTime;
  final DateTime endTime;
  final String? description;
  final bool isActive;

  SessionModel({
    required this.id,
    required this.title,
    required this.speaker,
    required this.startTime,
    required this.endTime,
    this.description,
    this.isActive = false,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['id'] as String,
      title: json['title'] as String,
      speaker: json['speaker'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      description: json['description'] as String?,
      isActive: json['isActive'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'speaker': speaker,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'description': description,
      'isActive': isActive,
    };
  }

  SessionModel copyWith({
    String? id,
    String? title,
    String? speaker,
    DateTime? startTime,
    DateTime? endTime,
    String? description,
    bool? isActive,
  }) {
    return SessionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      speaker: speaker ?? this.speaker,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
    );
  }
}
