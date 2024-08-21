import 'package:flutter/material.dart';
import 'package:googlemap/searchplace.dart';
import 'GoogleMapVeiw.dart';
import 'fetchapi.dart';
import 'grouping.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: GroupedTodoListView(),
    );
  }
}


