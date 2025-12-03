enum TimePeriod {
  today,
  thisWeek,
  thisMonth,
  custom,
}

class DateRange {
  final DateTime startDate;
  final DateTime endDate;
  final TimePeriod period;

  DateRange({
    required this.startDate,
    required this.endDate,
    required this.period,
  });

  static DateRange today() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return DateRange(startDate: start, endDate: end, period: TimePeriod.today);
  }

  static DateRange thisWeek() {
    final now = DateTime.now();
    final weekday = now.weekday;
    final start = DateTime(now.year, now.month, now.day - (weekday - 1));
    final end = DateTime(now.year, now.month, now.day + (7 - weekday), 23, 59, 59);
    return DateRange(startDate: start, endDate: end, period: TimePeriod.thisWeek);
  }

  static DateRange thisMonth() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    return DateRange(startDate: start, endDate: end, period: TimePeriod.thisMonth);
  }

  static DateRange custom(DateTime start, DateTime end) {
    return DateRange(startDate: start, endDate: end, period: TimePeriod.custom);
  }
}
