import 'package:flutter_sql_lite/db/table/base.dart';
import 'package:flutter_sql_lite/db/table/student.dart';

// Список всех таблиц в приложении
final List<BaseTable> tables = [
  StudentTable(),
  // Добавляйте новые таблицы здесь
];
