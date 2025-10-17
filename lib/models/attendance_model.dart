class AttendanceModel {
  final String id;
  final String memberId;
  final String memberName;
  final String sessionId;
  final String status; // 'present', 'absent', 'late'
  final DateTime? checkInTime;
  final String? seatNumber;

  AttendanceModel({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.sessionId,
    required this.status,
    this.checkInTime,
    this.seatNumber,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'] as String,
      memberId: json['memberId'] as String,
      memberName: json['memberName'] as String,
      sessionId: json['sessionId'] as String,
      status: json['status'] as String,
      checkInTime:
          json['checkInTime'] != null
              ? DateTime.parse(json['checkInTime'] as String)
              : null,
      seatNumber: json['seatNumber'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'memberId': memberId,
      'memberName': memberName,
      'sessionId': sessionId,
      'status': status,
      'checkInTime': checkInTime?.toIso8601String(),
      'seatNumber': seatNumber,
    };
  }

  AttendanceModel copyWith({
    String? id,
    String? memberId,
    String? memberName,
    String? sessionId,
    String? status,
    DateTime? checkInTime,
    String? seatNumber,
  }) {
    return AttendanceModel(
      id: id ?? this.id,
      memberId: memberId ?? this.memberId,
      memberName: memberName ?? this.memberName,
      sessionId: sessionId ?? this.sessionId,
      status: status ?? this.status,
      checkInTime: checkInTime ?? this.checkInTime,
      seatNumber: seatNumber ?? this.seatNumber,
    );
  }
}
