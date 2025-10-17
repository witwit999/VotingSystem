enum DecisionStatus {
  open('OPEN'),
  closed('CLOSED');

  final String value;
  const DecisionStatus(this.value);

  static DecisionStatus fromString(String status) {
    return DecisionStatus.values.firstWhere(
      (e) => e.value == status.toUpperCase(),
      orElse: () => DecisionStatus.closed,
    );
  }
}

enum VoteChoice {
  accept('ACCEPT'),
  deny('DENY'),
  abstain('ABSTAIN');

  final String value;
  const VoteChoice(this.value);

  static VoteChoice fromString(String choice) {
    return VoteChoice.values.firstWhere(
      (e) => e.value == choice.toUpperCase(),
      orElse: () => VoteChoice.abstain,
    );
  }
}

class DecisionModel {
  final String id;
  final String sessionId;
  final String title;
  final String? description;
  final DecisionStatus status;
  final DateTime? openAt;
  final DateTime? closeAt;
  final bool allowRecast;
  final DecisionTally? tally;

  DecisionModel({
    required this.id,
    required this.sessionId,
    required this.title,
    this.description,
    required this.status,
    this.openAt,
    this.closeAt,
    this.allowRecast = false,
    this.tally,
  });

  factory DecisionModel.fromJson(Map<String, dynamic> json) {
    // Handle both formats: {decision: {...}, tally: {...}} or direct decision object
    final decisionData =
        json.containsKey('decision')
            ? json['decision'] as Map<String, dynamic>
            : json;

    final tallyData =
        json.containsKey('tally')
            ? json['tally'] as Map<String, dynamic>?
            : null;

    return DecisionModel(
      id: decisionData['id'] as String? ?? '',
      sessionId: decisionData['sessionId'] as String? ?? '',
      title: decisionData['title'] as String? ?? 'Untitled Decision',
      description: decisionData['description'] as String?,
      status:
          decisionData['status'] != null
              ? DecisionStatus.fromString(decisionData['status'] as String)
              : DecisionStatus.closed,
      openAt:
          decisionData['openAt'] != null
              ? DateTime.parse(decisionData['openAt'] as String)
              : null,
      closeAt:
          decisionData['closeAt'] != null
              ? DateTime.parse(decisionData['closeAt'] as String)
              : null,
      allowRecast: decisionData['allowRecast'] as bool? ?? false,
      tally: tallyData != null ? DecisionTally.fromJson(tallyData) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionId': sessionId,
      'title': title,
      if (description != null) 'description': description,
      'status': status.value,
      if (openAt != null) 'openAt': openAt!.toIso8601String(),
      if (closeAt != null) 'closeAt': closeAt!.toIso8601String(),
      'allowRecast': allowRecast,
      if (tally != null) 'tally': tally!.toJson(),
    };
  }

  DecisionModel copyWith({
    String? id,
    String? sessionId,
    String? title,
    String? description,
    DecisionStatus? status,
    DateTime? openAt,
    DateTime? closeAt,
    bool? allowRecast,
    DecisionTally? tally,
  }) {
    return DecisionModel(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      openAt: openAt ?? this.openAt,
      closeAt: closeAt ?? this.closeAt,
      allowRecast: allowRecast ?? this.allowRecast,
      tally: tally ?? this.tally,
    );
  }

  bool get isOpen => status == DecisionStatus.open;
  bool get isClosed => status == DecisionStatus.closed;
}

class DecisionTally {
  final int accepted;
  final int denied;
  final int abstained;
  final int valid;
  final int activeBase;

  DecisionTally({
    required this.accepted,
    required this.denied,
    required this.abstained,
    required this.valid,
    required this.activeBase,
  });

  factory DecisionTally.fromJson(Map<String, dynamic> json) {
    return DecisionTally(
      accepted: json['accepted'] as int? ?? 0,
      denied: json['denied'] as int? ?? 0,
      abstained: json['abstained'] as int? ?? 0,
      valid: json['valid'] as int? ?? 0,
      activeBase: json['activeBase'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accepted': accepted,
      'denied': denied,
      'abstained': abstained,
      'valid': valid,
      'activeBase': activeBase,
    };
  }

  int get total => accepted + denied + abstained;

  double get acceptPercentage =>
      activeBase > 0 ? (accepted / activeBase) * 100 : 0;
  double get denyPercentage => activeBase > 0 ? (denied / activeBase) * 100 : 0;
  double get abstainPercentage =>
      activeBase > 0 ? (abstained / activeBase) * 100 : 0;
  double get turnoutPercentage =>
      activeBase > 0 ? (total / activeBase) * 100 : 0;

  bool get passed => accepted > denied;
}

class VoteModel {
  final String id;
  final String decisionId;
  final String userId;
  final VoteChoice choice;
  final DateTime castAt;
  final int seq;

  VoteModel({
    required this.id,
    required this.decisionId,
    required this.userId,
    required this.choice,
    required this.castAt,
    required this.seq,
  });

  factory VoteModel.fromJson(Map<String, dynamic> json) {
    return VoteModel(
      id: json['id'] as String? ?? '',
      decisionId: json['decisionId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      choice: VoteChoice.fromString(json['choice'] as String? ?? 'ABSTAIN'),
      castAt:
          json['castAt'] != null
              ? DateTime.parse(json['castAt'] as String)
              : DateTime.now(),
      seq: json['seq'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'decisionId': decisionId,
      'userId': userId,
      'choice': choice.value,
      'castAt': castAt.toIso8601String(),
      'seq': seq,
    };
  }
}
