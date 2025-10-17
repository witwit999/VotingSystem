class AgendaModel {
  final String id;
  final String title;
  final String description;
  final String speaker;
  final DateTime startTime;
  final DateTime endTime;
  final String status; // 'upcoming', 'ongoing', 'completed'
  final bool hasAttended;

  AgendaModel({
    required this.id,
    required this.title,
    required this.description,
    required this.speaker,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.hasAttended = false,
  });

  factory AgendaModel.fromJson(Map<String, dynamic> json) {
    return AgendaModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      speaker: json['speaker'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      status: json['status'] as String,
      hasAttended: json['hasAttended'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'speaker': speaker,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'status': status,
      'hasAttended': hasAttended,
    };
  }

  AgendaModel copyWith({
    String? id,
    String? title,
    String? description,
    String? speaker,
    DateTime? startTime,
    DateTime? endTime,
    String? status,
    bool? hasAttended,
  }) {
    return AgendaModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      speaker: speaker ?? this.speaker,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      hasAttended: hasAttended ?? this.hasAttended,
    );
  }
}
