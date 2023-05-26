import 'package:edubot/components/drawer_component.dart';
import 'package:flutter/material.dart';

class DashBoardScreen extends StatefulWidget {
  const DashBoardScreen({super.key});

  @override
  State<DashBoardScreen> createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cố vấn học tập',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title:  const Text(
            "Trang Quản trị",
            style: TextStyle(fontSize: 25, color: Colors.white),
          ),
          backgroundColor: Colors.blue,
        ),
        drawer: const AdminDrawer(),
        body: Center(child: const Text("Trang Dashboard nè")),
      ),
    );
  }
}