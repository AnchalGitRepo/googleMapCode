import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TodoListView extends StatefulWidget {
  @override
  _TodoListViewState createState() => _TodoListViewState();
}

class _TodoListViewState extends State<TodoListView> {
  Future<Todo?>? todo;

  @override
  void initState() {
    super.initState();
    todo = fetchTodo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
      ),
      body: FutureBuilder<Todo?>(
        future: todo,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            Todo? todo = snapshot.data;
            return ListView(
              children: [
                ListTile(
                  title: Text('User ID: ${todo?.userId ?? ''}'),
                ),
                ListTile(
                  title: Text('ID: ${todo?.id ?? ''}'),
                ),
                ListTile(
                  title: Text('Title: ${todo?.title ?? ''}'),
                ),
                ListTile(
                  title: Text('Completed: ${todo?.completed ?? ''}'),
                ),
              ],
            );
          } else {
            return const Center(child: Text('No data found.'));
          }
        },
      ),
    );
  }
}

class Todo {
  final int userId;
  final int id;
  final String title;
  final bool completed;

  Todo({
    required this.userId,
    required this.id,
    required this.title,
    required this.completed,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      userId: json['userId'],
      id: json['id'],
      title: json['title'],
      completed: json['completed'],
    );
  }
}

Future<Todo?> fetchTodo() async {
  const url = 'https://jsonplaceholder.typicode.com/todos/1';
  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Todo.fromJson(data);
    } else {
      print('Failed to load data. Status code: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Error: $e');
    return null;
  }
}
