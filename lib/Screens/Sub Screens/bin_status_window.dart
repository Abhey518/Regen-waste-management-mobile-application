import 'package:flutter/material.dart';

class BinStatusWindow extends StatelessWidget {
  const BinStatusWindow({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bin Status', textAlign: TextAlign.center),
        centerTitle: true,
      ),
      body: const Center(child: Text('Bin Status Content')),
    );
  }
}
