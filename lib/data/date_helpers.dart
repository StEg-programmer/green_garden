DateTime dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

String formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';

String formatDateTime(DateTime date) =>
    '${formatDate(date)}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
