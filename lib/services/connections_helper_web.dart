import '../models/connection_info.dart';

Future<List<ConnectionInfo>> getConnections() async {
  // Web Simulation Logic
  List<ConnectionInfo> dynamicConns = [];

  // Always connected to Host
  dynamicConns.add(
    ConnectionInfo(
      protocol: "HTTPS",
      localAddress: "Browser:Random",
      foreignAddress: "firebase-hosting:443",
      state: "ESTABLISHED",
      pid: "Self",
      processName: "ShieldChat Web",
    ),
  );

  // Simulate API traffic
  if (DateTime.now().second % 5 == 0) {
    dynamicConns.add(
      ConnectionInfo(
        protocol: "HTTPS",
        localAddress: "Browser:Random",
        foreignAddress: "api.ipify.org:443",
        state: "TIME_WAIT",
        pid: "Async",
        processName: "IP Check Service",
      ),
    );
  }

  // If we assume the user might be scanning (statistically)
  if (DateTime.now().second % 10 < 3) {
    dynamicConns.add(
      ConnectionInfo(
        protocol: "HTTP",
        localAddress: "192.168.1.x:Random",
        foreignAddress: "192.168.1.x:80",
        state: "SYN_SENT",
        pid: "Scanner",
        processName: "LAN Discovery",
      ),
    );
  }

  return dynamicConns;
}

Future<bool> killConnection(ConnectionInfo info) async {
  return false;
}
