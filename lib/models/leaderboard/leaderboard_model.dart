class LeaderboardEntry {
  final int rank;
  final String username;
  final int totalPoints;
  final double algo1Progress;
  final double algo2Progress;
  final String avatarInitial;

  const LeaderboardEntry({
    required this.rank,
    required this.username,
    required this.totalPoints,
    required this.algo1Progress,
    required this.algo2Progress,
    required this.avatarInitial,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    final username = json['username']?.toString() ?? '?';
    return LeaderboardEntry(
      rank:          (json['rank']          as num?)?.toInt()    ?? 0,
      username:      username,
      totalPoints:   (json['totalPoints']   as num?)?.toInt()    ?? 0,
      algo1Progress: (json['algo1Progress'] as num?)?.toDouble() ?? 0.0,
      algo2Progress: (json['algo2Progress'] as num?)?.toDouble() ?? 0.0,
      avatarInitial: username.isNotEmpty ? username[0].toUpperCase() : '?',
    );
  }
}

class LeaderboardModel {
  final List<LeaderboardEntry> entries;
  final LeaderboardEntry? currentUser;

  const LeaderboardModel({
    required this.entries,
    this.currentUser,
  });

  static LeaderboardModel mock() {
    final entries = [
      const LeaderboardEntry(rank: 1,  username: 'zaki',       totalPoints: 9999915452, algo1Progress: 1.0,  algo2Progress: 0.85, avatarInitial: 'Z'),
      const LeaderboardEntry(rank: 2,  username: 'salime12',   totalPoints: 9999815360, algo1Progress: 0.95, algo2Progress: 0.80, avatarInitial: 'S'),
      const LeaderboardEntry(rank: 3,  username: 'hamid__9',   totalPoints: 9999801000, algo1Progress: 0.90, algo2Progress: 0.75, avatarInitial: 'H'),
      const LeaderboardEntry(rank: 4,  username: 'lounis88',   totalPoints: 9979801560, algo1Progress: 0.88, algo2Progress: 0.70, avatarInitial: 'L'),
      const LeaderboardEntry(rank: 5,  username: 'axel__684',  totalPoints: 9973801007, algo1Progress: 0.85, algo2Progress: 0.65, avatarInitial: 'A'),
      const LeaderboardEntry(rank: 6,  username: 'nina__34',   totalPoints: 9968808100, algo1Progress: 0.80, algo2Progress: 0.60, avatarInitial: 'N'),
      const LeaderboardEntry(rank: 7,  username: 'salma__33',  totalPoints: 9939891070, algo1Progress: 0.75, algo2Progress: 0.55, avatarInitial: 'S'),
      const LeaderboardEntry(rank: 8,  username: 'moad__965',  totalPoints: 9596801808, algo1Progress: 0.70, algo2Progress: 0.50, avatarInitial: 'M'),
      const LeaderboardEntry(rank: 9,  username: 'sousou__42', totalPoints: 9497861090, algo1Progress: 0.65, algo2Progress: 0.45, avatarInitial: 'S'),
      const LeaderboardEntry(rank: 10, username: 'karim__39',  totalPoints: 9294201020, algo1Progress: 0.60, algo2Progress: 0.40, avatarInitial: 'K'),
    ];

    return LeaderboardModel(
      entries: entries,
      currentUser: const LeaderboardEntry(
        rank: 1,
        username: 'Zakaria Laadj',
        totalPoints: 9999915452,
        algo1Progress: 0.64,
        algo2Progress: 0.32,
        avatarInitial: 'Z',
      ),
    );
  }
}