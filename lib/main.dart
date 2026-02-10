import 'package:flutter/material.dart';
import 'package:flutter_sql_lite/db/database.dart';
import 'package:flutter_sql_lite/db/table/student.dart';
import 'package:flutter_sql_lite/model/student.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter SQL',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<FormState> _formStateKey = GlobalKey<FormState>();
  final _studentNameController = TextEditingController();

  late Future<List<Student>> _studentsList;
  String? _studentName;
  bool _isUpdate = false;
  int? _studentIdForUpdate;

  @override
  void initState() {
    super.initState();
    _getStudents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Flutter SQL'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(15),
            child: Form(
              key: _formStateKey,
              child: TextFormField(
                controller: _studentNameController,
                decoration: InputDecoration(labelText: 'Имя студента'),
                onSaved: (String? val) => _studentName = val!,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _addStudent,
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll<Color>(Colors.green),
                ),
                child: Text(
                  _isUpdate ? 'Update' : 'Add',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              Padding(padding: EdgeInsets.only(left: 10, right: 10)),
              ElevatedButton(
                onPressed: _clearStudent,
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll<Color>(Colors.red),
                ),
                child: Text(
                  _isUpdate ? 'Cancel' : 'Clear',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),

          Expanded(
            child: FutureBuilder(
              future: _studentsList,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return _generateListView(snapshot.data!);
                }
                if (snapshot.data == null || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'No students found',
                      style: TextStyle(fontSize: 20, color: Colors.grey),
                    ),
                  );
                }
                return Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }

  void _getStudents() {
    setState(() {
      _studentsList = DBProvider.db.getFromTable(StudentTable());
    });
  }

  void _addStudent() {
    if (_isUpdate) {
      if (_formStateKey.currentState!.validate()) {
        _formStateKey.currentState!.save();
        DBProvider.db
            .updateTable(
              StudentTable(),
              Student(id: _studentIdForUpdate, name: _studentName!),
            )
            .then((data) {
              setState(() {
                _isUpdate = false;
              });
            });
      }
    } else {
      if (_formStateKey.currentState!.validate()) {
        _formStateKey.currentState!.save();
        DBProvider.db
            .insertInTable(
              StudentTable(),
              Student(id: null, name: _studentName!),
            )
            .then((data) {
              setState(() {
                _studentNameController.clear();
                _getStudents();
              });
            });
      }
    }
    _studentNameController.clear();
    _getStudents();
  }

  void _clearStudent() {
    setState(() {
      _isUpdate = false;
      _studentIdForUpdate = null;
    });

    _studentNameController.clear();
  }

  void _deleteStudent(Student student) {
    DBProvider.db.deleteItem(StudentTable(), student.id!);
    _getStudents();
  }

  SingleChildScrollView _generateListView(List<Student> students) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: DataTable(
          columns: [
            DataColumn(label: Text('ID')),
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Delete')),
          ],
          rows: students
              .map(
                (student) => DataRow(
                  cells: [
                    DataCell(Text(student.id.toString())),
                    DataCell(
                      Text(student.name),
                      onTap: () {
                        setState(() {
                          _isUpdate = true;
                          _studentIdForUpdate = student.id;
                        });
                        _studentNameController.text = student.name;
                      },
                    ),
                    DataCell(
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteStudent(student),
                      ),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
