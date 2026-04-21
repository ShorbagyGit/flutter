class DateUtilsHelper {
  static String formatShortDate(String dateString) {
    final date = DateTime.tryParse(dateString);
    if (date == null) return dateString;
    return '${_weekDay(date.weekday)}, ${date.day} ${_month(date.month)}';
  }

  static String formatBookingDate(String dateString) {
    final date = DateTime.tryParse(dateString);
    if (date == null) return dateString;
    return '${_weekDay(date.weekday)}, ${date.day} ${_month(date.month)} ${date.year}';
  }

  static String formatTime(String timeString) {
    if (timeString.contains('T')) {
      final date = DateTime.tryParse(timeString);
      if (date != null) {
        return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      }
    }
    return timeString;
  }

  static String _weekDay(int weekday) {
    const values = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return values[(weekday - 1).clamp(0, 6)];
  }

  static String _month(int month) {
    const values = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return values[(month - 1).clamp(0, 11)];
  }
}
