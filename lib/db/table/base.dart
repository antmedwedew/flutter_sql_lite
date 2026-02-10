abstract class BaseTable<T> {
  String get tableName;
  String get createTableQuery;

  T fromMap(Map<String, dynamic> map);
  Map<String, dynamic> toMap(T item);
}
