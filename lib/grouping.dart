import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GroupedTodoListView extends StatefulWidget {
  @override
  _GroupedTodoListViewState createState() => _GroupedTodoListViewState();
}

class _GroupedTodoListViewState extends State<GroupedTodoListView> {
  Future<Map<int, List<Todo>>>? groupedTodos;

  @override
  void initState() {
    super.initState();
    groupedTodos = fetchGroupedTodos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Grouped Todo List'),
      ),
      body: FutureBuilder<Map<int, List<Todo>>>(
        future: groupedTodos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            Map<int, List<Todo>>? groupedTodos = snapshot.data;
            return ListView.builder(
              itemCount: groupedTodos?.length ?? 0,
              itemBuilder: (context, index) {
                int userId = groupedTodos!.keys.elementAt(index);
                List<Todo> todos = groupedTodos[userId]!;

                return ExpansionTile(
                  title: Text('User ID: $userId'),
                  children: todos.map((todo) {
                    return ListTile(
                      title: Text(todo.title),
                      subtitle: Text('Completed: ${todo.completed}'),
                    );
                  }).toList(),
                );
              },
            );
          } else {
            return Center(child: Text('No data found.'));
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

Future<List<Todo>> fetchTodos() async {
  final url = 'https://jsonplaceholder.typicode.com/todos';
  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((item) => Todo.fromJson(item)).toList();
    } else {
      print('Failed to load data. Status code: ${response.statusCode}');
      return [];
    }
  } catch (e) {
    print('Error: $e');
    return [];
  }
}

Future<Map<int, List<Todo>>> fetchGroupedTodos() async {
  List<Todo> todos = await fetchTodos();
  Map<int, List<Todo>> groupedTodos = {};

  for (var todo in todos) {
    if (groupedTodos.containsKey(todo.userId)) {
      groupedTodos[todo.userId]!.add(todo);
    } else {
      groupedTodos[todo.userId] = [todo];
    }
  }

  return groupedTodos;
}