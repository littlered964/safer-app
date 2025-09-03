import 'package:flutter/material.dart';

class DuringOutageSortingPage extends StatelessWidget {
  const DuringOutageSortingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('During: Sort-It')),
      body: const Center(
        child: Text(
          'Game coming soon…',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
