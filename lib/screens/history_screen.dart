import 'package:flutter/material.dart';
import '../services/history_service.dart';
import '../theme.dart';
import '../services/localization_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final HistoryService _historyService = HistoryService();
  List<Map<String, dynamic>> _history = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await _historyService.loadHistory();
    if (mounted) {
      setState(() {
        _history = data;
        _loading = false;
      });
    }
  }

  Future<void> _clear() async {
    await _historyService.clearHistory();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LanguageService().translate('history_title')),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: AppTheme.cardColor,
                  title: Text(
                    LanguageService().translate('delete_history_title'),
                    style: const TextStyle(color: Colors.white),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(
                        LanguageService().translate('cancel_button_caps'),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _clear();
                      },
                      child: Text(
                        LanguageService().translate('delete_button_caps'),
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            )
          : _history.isEmpty
          ? Center(
              child: Text(
                LanguageService().translate('no_history_msg'),
                style: const TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: _history.length,
              itemBuilder: (context, index) {
                final scan = _history[index];
                final date = DateTime.parse(scan['date']);
                final devices = (scan['devices'] as List).length;
                return Card(
                  color: AppTheme.cardColor,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: ExpansionTile(
                    title: Text(
                      "${LanguageService().translate('scan_label')} ${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}",
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      "$devices ${LanguageService().translate('devices_found_label')}",
                      style: const TextStyle(color: Colors.grey),
                    ),
                    children: (scan['devices'] as List).map<Widget>((d) {
                      return ListTile(
                        dense: true,
                        title: Text(
                          d['nombre'] ?? 'Desc.',
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          "${d['ip']} - ${d['vendedor']}",
                          style: const TextStyle(color: Colors.white70),
                        ),
                        leading: const Icon(
                          Icons.devices,
                          size: 16,
                          color: AppTheme.accent,
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
    );
  }
}
