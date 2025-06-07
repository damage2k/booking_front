class DateUtils {
  static String getCurrentMonthYearRu() {
    final now = DateTime.now();
    final monthNames = [
      'Январь',
      'Февраль',
      'Март',
      'Апрель',
      'Май',
      'Июнь',
      'Июль',
      'Август',
      'Сентябрь',
      'Октябрь',
      'Ноябрь',
      'Декабрь'
    ];

    final month = monthNames[now.month - 1];
    return '$month ${now.year}';
  }
}
