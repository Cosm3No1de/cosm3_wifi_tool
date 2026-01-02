import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';
import '../services/localization_service.dart';

class PantallaGenerador extends StatefulWidget {
  const PantallaGenerador({super.key});
  @override
  State<PantallaGenerador> createState() => _PantallaGeneradorState();
}

class _PantallaGeneradorState extends State<PantallaGenerador> {
  String _password = "";
  double _longitud = 16;
  bool _numeros = true;
  bool _simbolos = true;
  final bool _mayus = true;

  void _generar() {
    const lower = "abcdefghijklmnopqrstuvwxyz";
    const upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    const numbers = "0123456789";
    const symbols = "!@#\$%^&*()_+-=[]{}|;:,.<>?";
    String chars = lower;
    if (_mayus) chars += upper;
    if (_numeros) chars += numbers;
    if (_simbolos) chars += symbols;
    String resultado = "";
    final rnd = Random.secure();
    for (int i = 0; i < _longitud; i++) {
      resultado += chars[rnd.nextInt(chars.length)];
    }
    setState(() => _password = resultado);
  }

  @override
  void initState() {
    super.initState();
    _generar();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.purpleAccent),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _password,
                    style: const TextStyle(
                      fontFamily: "Courier",
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, color: Colors.purpleAccent),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _password));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          LanguageService().translate('copied_snack'),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Slider(
            value: _longitud,
            min: 8,
            max: 32,
            divisions: 24,
            label: _longitud.round().toString(),
            activeColor: Colors.purpleAccent,
            onChanged: (v) => setState(() => _longitud = v),
          ),
          SwitchListTile(
            title: Text(LanguageService().translate('numbers_label')),
            value: _numeros,
            activeThumbColor: Colors.purpleAccent,
            onChanged: (v) => setState(() => _numeros = v),
          ),
          SwitchListTile(
            title: Text(LanguageService().translate('symbols_label')),
            value: _simbolos,
            activeThumbColor: Colors.purpleAccent,
            onChanged: (v) => setState(() => _simbolos = v),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purpleAccent,
                padding: const EdgeInsets.all(15),
              ),
              icon: const Icon(Icons.refresh),
              label: Text(LanguageService().translate('generate_button')),
              onPressed: _generar,
            ),
          ),
        ],
      ),
    );
  }
}
