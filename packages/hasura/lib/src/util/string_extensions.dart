extension CmsHasuraStringExtensions on String {
  /// Upper-cases the first character and leaves the rest alone, so joining
  /// camel-case components keeps their interior capitals.
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
