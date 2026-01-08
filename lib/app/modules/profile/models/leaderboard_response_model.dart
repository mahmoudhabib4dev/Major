class LeaderboardResponseModel {
  final String weekKey;
  final int divisionId;
  final int participants;
  final StudentLeaderboardInfo? student;
  final List<LeaderboardEntry> top;

  LeaderboardResponseModel({
    required this.weekKey,
    required this.divisionId,
    required this.participants,
    this.student,
    required this.top,
  });

  factory LeaderboardResponseModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardResponseModel(
      weekKey: json['week_key'] ?? '',
      divisionId: json['division_id'] ?? 0,
      participants: json['participants'] ?? 0,
      student: json['student'] != null
          ? StudentLeaderboardInfo.fromJson(json['student'])
          : null,
      top: (json['top'] as List<dynamic>?)
              ?.map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'week_key': weekKey,
      'division_id': divisionId,
      'participants': participants,
      'student': student?.toJson(),
      'top': top.map((e) => e.toJson()).toList(),
    };
  }
}

class StudentLeaderboardInfo {
  final bool hidden;
  final int rank;
  final int score;

  StudentLeaderboardInfo({
    required this.hidden,
    required this.rank,
    required this.score,
  });

  factory StudentLeaderboardInfo.fromJson(Map<String, dynamic> json) {
    return StudentLeaderboardInfo(
      hidden: json['hidden'] ?? false,
      rank: json['rank'] ?? 0,
      score: json['score'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hidden': hidden,
      'rank': rank,
      'score': score,
    };
  }
}

class LeaderboardEntry {
  final int rank;
  final int studentId;
  final String name;
  final int score;
  final String? pictureUrl;

  LeaderboardEntry({
    required this.rank,
    required this.studentId,
    required this.name,
    required this.score,
    this.pictureUrl,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: json['rank'] ?? 0,
      studentId: json['student_id'] ?? 0,
      name: json['name'] ?? '',
      score: json['score'] ?? 0,
      pictureUrl: json['picture_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rank': rank,
      'student_id': studentId,
      'name': name,
      'score': score,
      'picture_url': pictureUrl,
    };
  }
}
