import 'package:flutter/material.dart';

class TerminalScreen extends StatelessWidget {
  final String ip;
  const TerminalScreen({super.key, required this.ip});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Terminal")),
      body: const Center(
        child: Text(
          "SSH Terminal not supported on Web.\nPlease use the mobile application.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}
