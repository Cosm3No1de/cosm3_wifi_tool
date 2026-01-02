import 'package:flutter/material.dart';
import 'package:dartssh2/dartssh2.dart';
import '../theme.dart';
import '../services/localization_service.dart';

class TerminalScreen extends StatefulWidget {
  final String ip;
  const TerminalScreen({super.key, required this.ip});
  @override
  State<TerminalScreen> createState() => _TerminalScreenState();
}

class _TerminalScreenState extends State<TerminalScreen> {
  final _u = TextEditingController();
  final _p = TextEditingController();
  final _cmdCtrl = TextEditingController();
  final ScrollController _scroll = ScrollController();
  String _log = "";
  bool _c = false;

  @override
  void initState() {
    super.initState();
    _log = "${LanguageService().translate('console_ready_log')}\n";
  }

  void _addLog(String t) {
    if (!mounted) return;
    setState(() => _log += "\n$t");
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scroll.hasClients) _scroll.jumpTo(_scroll.position.maxScrollExtent);
    });
  }

  Future<void> _conectarYEjecutar(String cmd) async {
    if (_u.text.isEmpty || _p.text.isEmpty) {
      _addLog(LanguageService().translate('missing_creds_log'));
      return;
    }
    _cmdCtrl.clear();
    if (mounted) setState(() => _c = true);
    _addLog("root@${widget.ip}:~# $cmd");

    SSHClient? client;
    try {
      final s = await SSHSocket.connect(
        widget.ip,
        22,
        timeout: const Duration(seconds: 5),
      );
      client = SSHClient(
        s,
        username: _u.text,
        onPasswordRequest: () => _p.text,
      );
      final sess = await client.execute(cmd);
      try {
        final out = await sess.stdout
            .map((b) => String.fromCharCodes(b))
            .join()
            .timeout(const Duration(seconds: 5));
        if (out.isNotEmpty) _addLog(out);
      } catch (e) {
        if (cmd.contains("stop")) {
          _addLog(LanguageService().translate('closed_log'));
        }
      }
      client.close();
    } catch (e) {
      if (cmd.contains("stop")) {
        _addLog(LanguageService().translate('service_stopped_log'));
      } else {
        _addLog("${LanguageService().translate('error_label')} $e");
      }
    } finally {
      if (mounted) setState(() => _c = false);
    }
  }

  void _mostrarAyuda() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: Text(
          LanguageService().translate('ssh_guide_title'),
          style: const TextStyle(color: AppTheme.primary),
        ),
        content: SingleChildScrollView(
          child: Text(
            LanguageService().translate('ssh_guide_content'),
            style: const TextStyle(color: Colors.white70),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              LanguageService().translate('understood_button'),
              style: const TextStyle(color: AppTheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LanguageService().translate('terminal_title')),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: AppTheme.primary),
            onPressed: _mostrarAyuda,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_c) const LinearProgressIndicator(color: AppTheme.primary),
          ExpansionTile(
            title: Text(
              LanguageService().translate('ssh_creds_title'),
              style: const TextStyle(color: AppTheme.primary),
            ),
            iconColor: AppTheme.primary,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _u,
                        decoration: InputDecoration(
                          labelText: LanguageService().translate('user_label'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _p,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: LanguageService().translate(
                            'password_label',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              color: Colors.black,
              padding: const EdgeInsets.all(10),
              child: SingleChildScrollView(
                controller: _scroll,
                child: Text(
                  _log,
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontFamily: "Courier",
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            color: AppTheme.cardColor,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _cmdCtrl,
                    onSubmitted: _conectarYEjecutar,
                    style: const TextStyle(fontFamily: 'Courier'),
                    decoration: InputDecoration(
                      hintText: LanguageService().translate('command_hint'),
                      prefixIcon: const Icon(Icons.terminal),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: _c
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.primary,
                          ),
                        )
                      : const Icon(Icons.send, color: AppTheme.primary),
                  onPressed: _c
                      ? null
                      : () => _conectarYEjecutar(_cmdCtrl.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
