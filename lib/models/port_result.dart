class PortResult {
  final int port;
  final bool isOpen;
  final String banner;

  PortResult(this.port, this.isOpen, [this.banner = ""]);
}

