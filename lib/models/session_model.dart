enum SessionStatus {
  draft('DRAFT'),
  live('LIVE'),
  paused('PAUSED'),
  closed('CLOSED'),
  archived('ARCHIVED');

  final String value;
  const SessionStatus(this.value);

  static SessionStatus fromString(String status) {
    return SessionStatus.values.firstWhere(
      (e) => e.value == status.toUpperCase(),
      orElse: () => SessionStatus.draft,
    );
  }
}

class SessionModel {
  final String id;
  final String name;
  final SessionStatus status;
  final String? agendaText;
  final String adminId;
  final DateTime createdAt;
  final DateTime? openedAt;
  final DateTime? closedAt;
  final DateTime? archivedAt;

  SessionModel({
    required this.id,
    required this.name,
    required this.status,
    this.agendaText,
    required this.adminId,
    required this.createdAt,
    this.openedAt,
    this.closedAt,
    this.archivedAt,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unnamed Session',
      status:
          json['status'] != null
              ? SessionStatus.fromString(json['status'] as String)
              : SessionStatus.draft,
      agendaText: json['agendaText'] as String?,
      adminId: json['adminId'] as String? ?? '',
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'] as String)
              : DateTime.now(),
      openedAt:
          json['openedAt'] != null
              ? DateTime.parse(json['openedAt'] as String)
              : null,
      closedAt:
          json['closedAt'] != null
              ? DateTime.parse(json['closedAt'] as String)
              : null,
      archivedAt:
          json['archivedAt'] != null
              ? DateTime.parse(json['archivedAt'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'status': status.value,
      'agendaText': agendaText,
      'adminId': adminId,
      'createdAt': createdAt.toIso8601String(),
      if (openedAt != null) 'openedAt': openedAt!.toIso8601String(),
      if (closedAt != null) 'closedAt': closedAt!.toIso8601String(),
      if (archivedAt != null) 'archivedAt': archivedAt!.toIso8601String(),
    };
  }

  SessionModel copyWith({
    String? id,
    String? name,
    SessionStatus? status,
    String? agendaText,
    String? adminId,
    DateTime? createdAt,
    DateTime? openedAt,
    DateTime? closedAt,
    DateTime? archivedAt,
  }) {
    return SessionModel(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      agendaText: agendaText ?? this.agendaText,
      adminId: adminId ?? this.adminId,
      createdAt: createdAt ?? this.createdAt,
      openedAt: openedAt ?? this.openedAt,
      closedAt: closedAt ?? this.closedAt,
      archivedAt: archivedAt ?? this.archivedAt,
    );
  }

  // Helper getters for backward compatibility with UI
  String get title => name;
  bool get isActive => status == SessionStatus.live;
  String get speaker => agendaText ?? 'No agenda'; // Placeholder for now
  DateTime get startTime => openedAt ?? createdAt;
  DateTime get endTime => closedAt ?? createdAt.add(const Duration(hours: 2));
  String? get description => agendaText;

  bool get isLive => status == SessionStatus.live;
  bool get isDraft => status == SessionStatus.draft;
  bool get isPaused => status == SessionStatus.paused;
  bool get isClosed => status == SessionStatus.closed;
  bool get isArchived => status == SessionStatus.archived;
}
