enum MatchStatus {
  scheduled('SCHEDULED', 'Scheduled'),
  live('LIVE', 'Live'),
  completed('COMPLETED', 'Completed');

  final String dbValue;
  final String label;

  const MatchStatus(this.dbValue, this.label);

  static MatchStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'SCHEDULED':
        return MatchStatus.scheduled;
      case 'LIVE':
        return MatchStatus.live;
      case 'COMPLETED':
        return MatchStatus.completed;
      default:
        return MatchStatus.scheduled;
    }
  }
}
