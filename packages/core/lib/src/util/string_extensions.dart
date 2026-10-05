extension StringExtensions on String {
  /// Parses the two spellings a backend may store a boolean as, in any letter
  /// case.
  ///
  /// Throws a [FormatException] carrying the offending value, the way
  /// [int.parse] does. It used to throw a bare [String], which no caller could
  /// catch by type.
  bool parseBool() => switch (toLowerCase()) {
    'true' => true,
    'false' => false,
    _ => throw FormatException('Expected "true" or "false"', this),
  };

  // ignore: avoid_positional_boolean_parameters
  String modifyRequired(bool isRequired) => isRequired ? '$this*' : this;
}
