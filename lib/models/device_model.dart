class DispositivoRed {
  final String ip;
  String nombre;
  String mac;
  String vendedor;
  final List<String> openPorts = [];
  bool isScanningPorts = false;

  DispositivoRed({
    required this.ip,
    this.nombre = "Desconocido",
    this.mac = "...",
    this.vendedor = "Analizando...",
  });
}
