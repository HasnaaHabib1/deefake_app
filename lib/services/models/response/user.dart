class UserFile {
  final int id;
  final int userId;
  final String filePath;
  final String fileType;
  final bool? isFake;
  final double? confidenceScore;
  final DateTime? createdAt;

  UserFile({
    required this.id,
    required this.userId,
    required this.filePath,
    required this.fileType,
    this.isFake,
    this.confidenceScore,
    required this.createdAt,
  });

  factory UserFile.fromJson(Map<String, dynamic> json) {
    return UserFile(
      id: json['id'],
      userId: json['user_id'],
      filePath: json['file_path'],
      fileType: json['file_type'],
      isFake: json['is_fake'] == null ? null : json['is_fake'] == 1,
      confidenceScore: json['confidence_score'] != null
          ? (json['confidence_score'] as num).toDouble()
          : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
