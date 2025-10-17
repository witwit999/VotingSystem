class VotingModel {
  final String id;
  final String title;
  final String question;
  final DateTime startTime;
  final DateTime? endTime;
  final bool isActive;
  final VotingResults results;
  final String? userVote; // 'yes', 'no', 'abstain', or null

  VotingModel({
    required this.id,
    required this.title,
    required this.question,
    required this.startTime,
    this.endTime,
    required this.isActive,
    required this.results,
    this.userVote,
  });

  factory VotingModel.fromJson(Map<String, dynamic> json) {
    return VotingModel(
      id: json['id'] as String,
      title: json['title'] as String,
      question: json['question'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime:
          json['endTime'] != null
              ? DateTime.parse(json['endTime'] as String)
              : null,
      isActive: json['isActive'] as bool,
      results: VotingResults.fromJson(json['results'] as Map<String, dynamic>),
      userVote: json['userVote'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'question': question,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'isActive': isActive,
      'results': results.toJson(),
      'userVote': userVote,
    };
  }

  VotingModel copyWith({
    String? id,
    String? title,
    String? question,
    DateTime? startTime,
    DateTime? endTime,
    bool? isActive,
    VotingResults? results,
    String? userVote,
  }) {
    return VotingModel(
      id: id ?? this.id,
      title: title ?? this.title,
      question: question ?? this.question,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isActive: isActive ?? this.isActive,
      results: results ?? this.results,
      userVote: userVote ?? this.userVote,
    );
  }
}

class VotingResults {
  final int yes;
  final int no;
  final int abstain;
  final int total;

  VotingResults({
    required this.yes,
    required this.no,
    required this.abstain,
    required this.total,
  });

  factory VotingResults.fromJson(Map<String, dynamic> json) {
    return VotingResults(
      yes: json['yes'] as int,
      no: json['no'] as int,
      abstain: json['abstain'] as int,
      total: json['total'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {'yes': yes, 'no': no, 'abstain': abstain, 'total': total};
  }

  double get yesPercentage => total > 0 ? (yes / total) * 100 : 0;
  double get noPercentage => total > 0 ? (no / total) * 100 : 0;
  double get abstainPercentage => total > 0 ? (abstain / total) * 100 : 0;
}
