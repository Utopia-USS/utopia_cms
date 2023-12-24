import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:utopia_utils/utopia_utils.dart';

class CmsFirebaseFilterHelper {
  const CmsFirebaseFilterHelper();

  static Filter? buildOrFilter(List<Filter?> firebaseFilters) {
    return Filter.or(
      firebaseFilters[0]!,
      firebaseFilters[1]!,
      firebaseFilters.getOrNull(2),
      firebaseFilters.getOrNull(3),
      firebaseFilters.getOrNull(4),
      firebaseFilters.getOrNull(5),
      firebaseFilters.getOrNull(6),
      firebaseFilters.getOrNull(7),
      firebaseFilters.getOrNull(8),
      firebaseFilters.getOrNull(9),
      firebaseFilters.getOrNull(10),
      firebaseFilters.getOrNull(11),
      firebaseFilters.getOrNull(12),
      firebaseFilters.getOrNull(13),
      firebaseFilters.getOrNull(14),
      firebaseFilters.getOrNull(15),
      firebaseFilters.getOrNull(16),
      firebaseFilters.getOrNull(17),
      firebaseFilters.getOrNull(18),
      firebaseFilters.getOrNull(19),
      firebaseFilters.getOrNull(20),
      firebaseFilters.getOrNull(21),
      firebaseFilters.getOrNull(22),
      firebaseFilters.getOrNull(23),
      firebaseFilters.getOrNull(24),
      firebaseFilters.getOrNull(25),
      firebaseFilters.getOrNull(26),
      firebaseFilters.getOrNull(27),
      firebaseFilters.getOrNull(28),
      firebaseFilters.getOrNull(29),
    );
  }

  static Filter? buildAndFilter(List<Filter> firebaseFilters) {
    return Filter.or(
      firebaseFilters[0],
      firebaseFilters[1],
      firebaseFilters.getOrNull(2),
      firebaseFilters.getOrNull(3),
      firebaseFilters.getOrNull(4),
      firebaseFilters.getOrNull(5),
      firebaseFilters.getOrNull(6),
      firebaseFilters.getOrNull(7),
      firebaseFilters.getOrNull(8),
      firebaseFilters.getOrNull(9),
      firebaseFilters.getOrNull(10),
      firebaseFilters.getOrNull(11),
      firebaseFilters.getOrNull(12),
      firebaseFilters.getOrNull(13),
      firebaseFilters.getOrNull(14),
      firebaseFilters.getOrNull(15),
      firebaseFilters.getOrNull(16),
      firebaseFilters.getOrNull(17),
      firebaseFilters.getOrNull(18),
      firebaseFilters.getOrNull(19),
      firebaseFilters.getOrNull(20),
      firebaseFilters.getOrNull(21),
      firebaseFilters.getOrNull(22),
      firebaseFilters.getOrNull(23),
      firebaseFilters.getOrNull(24),
      firebaseFilters.getOrNull(25),
      firebaseFilters.getOrNull(26),
      firebaseFilters.getOrNull(27),
      firebaseFilters.getOrNull(28),
      firebaseFilters.getOrNull(29),
    );
  }
}
