
class Message {
  final String? id;
  final String conversationId;
  final String role; // 'agent' or 'user'
  final String content;
  final Map<String, dynamic>? metadata;
  final DateTime timestamp;

  Message({
    this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    this.metadata,
    required this.timestamp,
  });

  // Factory constructor for creating from JSON
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      conversationId: json['conversation_id'],
      role: json['role'],
      content: json['content'],
      metadata: json['metadata'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'role': role,
      'content': content,
      'metadata': metadata,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
