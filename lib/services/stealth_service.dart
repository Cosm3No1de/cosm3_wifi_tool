import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'history_service.dart';

class StealthService {
  static Future<void> activate(BuildContext context) async {
    // 1. Show "Purging" overlay
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const _PurgeDialog(),
    );

    // 2. Clear Data
    final historyService = HistoryService();
    await historyService.clearHistory();
    // Add other clearing logic here if needed (e.g., clear logs, cache)

    // 3. Fake delay for dramatic effect
    await Future.delayed(const Duration(seconds: 2));

    // 4. Exit App
    if (context.mounted) {
      Navigator.of(context).pop(); // Close dialog
      SystemNavigator.pop(); // Close app
    }
  }
}

class _PurgeDialog extends StatelessWidget {
  const _PurgeDialog();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 80),
            SizedBox(height: 20),
            Text(
              "SYSTEM PURGE INITIATED",
              style: TextStyle(
                color: Colors.red,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: "Courier",
                letterSpacing: 2,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "DELETING ALL LOGS...",
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 14,
                fontFamily: "Courier",
              ),
            ),
            SizedBox(height: 30),
            CircularProgressIndicator(color: Colors.red),
          ],
        ),
      ),
    );
  }
}
