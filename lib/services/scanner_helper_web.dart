import 'dart:async';
import 'package:http/http.dart' as http;

Future<String?> checkHost(String ip) async {
  try {
    // 1. HTTP Get to likely Gateway
    // Timeout is crucial: 500ms.
    // If it hangs -> Likely no device (or firewall dropping packets silently).
    // If it errors immediately (CORS, Refused) -> Likely device exists.
    // If it succeeds (200 OK) -> Device exists.
    final url = Uri.parse('http://$ip');

    // We don't care about the response body, just that it responds appropriately.
    await http.get(url).timeout(const Duration(milliseconds: 500));

    // If we get here (200-299), it exists.
    return ip;
  } on TimeoutException {
    // Timed out -> Assume dead
    return null;
  } catch (e) {
    // Error caught.
    // On Web, "Connection Refused" (RST) or "CORS Error" both throw ClientException.
    // But they usually happen FAST (< 100-200ms).
    // If it was a timeout, it would be caught above.
    // So this is likely a "Network Error" due to CORS or Refused, implying the device is there.
    return ip;
  }
}
