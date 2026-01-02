class ConnectionInfo {
  final String protocol;
  final String localAddress;
  final String foreignAddress;
  final String state;
  final String pid;
  final String processName;

  ConnectionInfo({
    required this.protocol,
    required this.localAddress,
    required this.foreignAddress,
    required this.state,
    required this.pid,
    required this.processName,
  });
}

