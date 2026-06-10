extension StringExtension on String {
  String uperFirstChart() {
    if (isEmpty) return this;
    return this[0].toUpperCase();
  }
}