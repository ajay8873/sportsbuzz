enum SportCategory {
  indoor('INDOOR', 'Indoor'),
  outdoor('OUTDOOR', 'Outdoor');

  final String dbValue;
  final String label;

  const SportCategory(this.dbValue, this.label);

  static SportCategory fromString(String value) {
    switch (value.toUpperCase()) {
      case 'INDOOR':
        return SportCategory.indoor;
      case 'OUTDOOR':
        return SportCategory.outdoor;
      default:
        return SportCategory.outdoor;
    }
  }
}
