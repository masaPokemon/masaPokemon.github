import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StudentProvider(),
      child: MaterialApp(
        title: 'Classroom Screen Share',
        home: ClassroomScreen(),
      ),
    );
  }
}

class StudentProvider extends ChangeNotifier {
  List<Student> _students = [
    Student(name: 'Student 1'),
    Student(name: 'Student 2'),
    Student(name: 'Student 3'),
  ];

  List<Student> get students => _students;
}

class Student {
  final String name;

  Student({required this.name});
}

class ClassroomScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final studentProvider = Provider.of<StudentProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Classroom'),
      ),
      body: ListView.builder(
        itemCount: studentProvider.students.length,
        itemBuilder: (context, index) {
          final student = studentProvider.students[index];
          return ListTile(
            title: Text(student.name),
            trailing: IconButton(
              icon: Icon(Icons.screen_share),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ScreenShareScreen(student: student),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class ScreenShareScreen extends StatelessWidget {
  final Student student;

  ScreenShareScreen({required this.student});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${student.name} Screen Share'),
      ),
      body: Center(
        child: Text('${student.name}の画面が共有されています。'),
      ),
    );
  }
}
