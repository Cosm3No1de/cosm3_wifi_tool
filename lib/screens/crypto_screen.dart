import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import '../theme.dart';
import '../services/localization_service.dart';

class PantallaCrypto extends StatefulWidget {
  const PantallaCrypto({super.key});
  @override
  State<PantallaCrypto> createState() => _PantallaCryptoState();
}

class _PantallaCryptoState extends State<PantallaCrypto> {
  final _inputCtrl = TextEditingController();
  String _output = "";

  void _procesar(String tipo) {
    String input = _inputCtrl.text;
    if (input.isEmpty) return;
    String res = "";
    try {
      if (tipo == "Base64 Enc") res = base64Encode(utf8.encode(input));
      if (tipo == "Base64 Dec") res = utf8.decode(base64Decode(input));
      if (tipo == "MD5") res = md5.convert(utf8.encode(input)).toString();
      if (tipo == "SHA256") res = sha256.convert(utf8.encode(input)).toString();
      if (tipo == "URL Enc") res = Uri.encodeComponent(input);
    } catch (e) {
      res = LanguageService().translate('invalid_format_error');
    }
    setState(() => _output = res);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          TextField(
            controller: _inputCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: LanguageService().translate('input_text_label'),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ActionChip(
                label: const Text("Base64 Enc"),
                onPressed: () => _procesar("Base64 Enc"),
              ),
              ActionChip(
                label: const Text("Base64 Dec"),
                onPressed: () => _procesar("Base64 Dec"),
              ),
              ActionChip(
                label: const Text("MD5"),
                onPressed: () => _procesar("MD5"),
              ),
              ActionChip(
                label: const Text("SHA256"),
                onPressed: () => _procesar("SHA256"),
              ),
              ActionChip(
                label: const Text("URL Enc"),
                onPressed: () => _procesar("URL Enc"),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white24),
            ),
            child: SelectableText(
              _output.isEmpty
                  ? LanguageService().translate('output_placeholder')
                  : _output,
              style: const TextStyle(
                fontFamily: "Courier",
                color: AppTheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
