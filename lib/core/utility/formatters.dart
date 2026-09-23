// lib/core/utility/formatters.dart
import 'package:intl/intl.dart';

String formatPrice(num value) =>
    NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
        .format(value);

String formatDate(DateTime date) =>
    DateFormat('dd MMM yyyy', 'id_ID').format(date);

String trimText(String text, [int max = 60]) =>
    text.length <= max ? text : '${text.substring(0, max)}…';
