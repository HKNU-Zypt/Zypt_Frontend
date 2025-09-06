import 'package:flutter/material.dart';

class RecordListScreen extends StatefulWidget {
  const RecordListScreen({super.key});

  @override
  State<RecordListScreen> createState() => _RecordListScreenState();
}

class _RecordListScreenState extends State<RecordListScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Column(children: [Text("기록 리스트 화면 ")]));
  }
}
