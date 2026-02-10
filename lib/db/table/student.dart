import 'package:flutter_sql_lite/db/table/base.dart';
import 'package:flutter_sql_lite/model/student.dart';

class StudentTable implements BaseTable<Student> {
  @override
  String get tableName => 'Students';

  @override
  String get createTableQuery =>
      'CREATE TABLE $tableName(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT)';

  @override
  Student fromMap(Map<String, dynamic> map) {
    return Student(id: map['id'], name: map['name']);
  }

  @override
  Map<String, dynamic> toMap(Student student) {
    return {'id': student.id, 'name': student.name};
  }
}
