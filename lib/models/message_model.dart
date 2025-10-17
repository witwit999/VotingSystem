class MessageModel {
  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime timestamp;
  final String? senderPhoto;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timestamp,
    this.senderPhoto,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String,
      text: json['text'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      senderPhoto: json['senderPhoto'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'senderPhoto': senderPhoto,
    };
  }

  MessageModel copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? text,
    DateTime? timestamp,
    String? senderPhoto,
  }) {
    return MessageModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      senderPhoto: senderPhoto ?? this.senderPhoto,
    );
  }
}
