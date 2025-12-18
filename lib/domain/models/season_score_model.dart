class SeasonScoreModel {
  SeasonScoreModel({
    required this.userId,
    required this.score,
    required this.matchesPlayed,
    required this.matchesWon,
  });

  factory SeasonScoreModel.fromMap(Map<String, dynamic> map) {
    return SeasonScoreModel(
      userId: map['userId'] as String? ?? '',
      score: (map['score'] as num? ?? 0).toDouble(),
      matchesPlayed: map['matchesPlayed'] as int? ?? 0,
      matchesWon: map['matchesWon'] as int? ?? 0,
    );
  }
  final String userId;
  final double score;
  final int matchesPlayed;
  final int matchesWon;

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'score': score,
      'matchesPlayed': matchesPlayed,
      'matchesWon': matchesWon,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SeasonScoreModel &&
        other.userId == userId &&
        other.score == score &&
        other.matchesPlayed == matchesPlayed &&
        other.matchesWon == matchesWon;
  }

  @override
  int get hashCode {
    return userId.hashCode ^
        score.hashCode ^
        matchesPlayed.hashCode ^
        matchesWon.hashCode;
  }

  @override
  String toString() {
    return 'SeasonScoreModel(userId: $userId, score: $score, matchesPlayed: $matchesPlayed, matchesWon: $matchesWon)';
  }
}
