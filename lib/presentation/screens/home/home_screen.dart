import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Where is it!')),
      body: Center(
        child: Text(
          'Welcome to Where is it!',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
