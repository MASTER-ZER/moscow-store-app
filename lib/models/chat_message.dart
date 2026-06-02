class ChatMessage {
  final int id;
  final int orderId;
  final String senderType;
  final String? senderName;
  final String message;
  final bool isRead;
  final DateTime? createdAt;

  const ChatMessage({
    required this.id,
    required this.orderId,
    required this.senderType,
    this.senderName,
    required this.message,
    this.isRead = false,
    this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as int,
      orderId: json['order_id'] as int,
      senderType: json['sender_type'] as String,
      senderName: json['sender_name'] as String?,
      message: json['message'] as String,
      isRead: (json['is_read'] as bool?) ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'sender_type': senderType,
      'sender_name': senderName,
      'message': message,
    };
  }
}
