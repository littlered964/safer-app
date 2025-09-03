import 'package:flutter/material.dart';

class AfterOutageChoicesPage extends StatelessWidget {
  const AfterOutageChoicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('After: Recovery Choices')),
      body: const Center(
        child: Text(
          'Game coming soon…',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
