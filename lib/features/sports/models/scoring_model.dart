enum ScoringModel {
  runBased('RUN_BASED', 'Run Based', 'Cricket'),
  timeBased('TIME_BASED', 'Time & Goal Based', 'Football, Basketball, Kabaddi, Hockey'),
  setBased('SET_BASED', 'Set & Point Based', 'Volleyball, Badminton, Table Tennis, Tennis'),
  boardBased('BOARD_BASED', 'Board & Clock Based', 'Chess, Carrom'),
  matchBased('MATCH_BASED', 'Match / Track Based', 'Athletics, Tug of War');

  final String dbValue;
  final String label;
  final String sportExamples;

  const ScoringModel(this.dbValue, this.label, this.sportExamples);

  static ScoringModel fromString(String value) {
    switch (value.toUpperCase()) {
      case 'RUN_BASED':
        return ScoringModel.runBased;
      case 'TIME_BASED':
        return ScoringModel.timeBased;
      case 'SET_BASED':
        return ScoringModel.setBased;
      case 'BOARD_BASED':
        return ScoringModel.boardBased;
      case 'MATCH_BASED':
        return ScoringModel.matchBased;
      default:
        return ScoringModel.timeBased;
    }
  }
}
