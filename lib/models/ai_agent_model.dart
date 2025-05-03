class AiAgentModel {
  final String id;
  final String name;
  final String description;
  final String systemPrompt;
  final String? vectorstoreId;
  final String createdBy;
  final DateTime createdAt;
  final String creatorName;

  AiAgentModel({
    required this.id,
    required this.name,
    required this.description,
    required this.systemPrompt,
    required this.vectorstoreId,
    required this.createdBy,
    required this.createdAt,
    required this.creatorName
  });

  factory AiAgentModel.fromJson(Map<String, dynamic> json) {
    return AiAgentModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      systemPrompt: json['system_prompt'],
      vectorstoreId: json['vectorstore_id'],
      createdBy: json['created_by'],
      createdAt: DateTime.parse(json['created_at']),
      creatorName: json['creator_name']?? 'unknown'
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'system_prompt': systemPrompt,
      'vectorstore_id': vectorstoreId,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'creator_name': creatorName
    };
  }
}
