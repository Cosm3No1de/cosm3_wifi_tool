import 'dart:io';

Future<String?> checkHost(String ip) async {
    Socket? socket;
    try {
      socket = await Socket.connect(
        ip,
        80,
        timeout: const Duration(milliseconds: 300), // strict timeout
      );
      // If we get here, connection succeeded -> Host Alive
      return ip;
    } on SocketException catch (e) {
      // If connection refused (os error 111 on linux/android), host is alive but port closed.
      // If timeout (os error 110), host likely down.
      // On Windows/Android, error codes vary.

      // "Connection refused" means packet got back -> Host Alive.
      if (e.osError != null &&
          (e.osError!.errorCode == 111 || // Connection Refused (Linux/Android)
              e.osError!.errorCode == 10061 || // Connection Refused (Windows)
              e.message.toLowerCase().contains("refused"))) {
        return ip;
      }
      return null;
    } catch (e) {
      return null;
    } finally {
      // Guaranteed cleanup
      try {
        socket?.destroy();
      } catch (_) {}
    }
}
