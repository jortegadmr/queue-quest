import 'package:flutter/material.dart';

class QueueQuestApp extends StatelessWidget {
  const QueueQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QueueQuest',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('QueueQuest'),
        ),
        body: const Center(
          child: Text('Hola desde QueueQuest App'),
        ),
      ),
    );
  }
}
