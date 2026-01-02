import 'package:http/http.dart' as http;

class LinkAnalysisResult {
  final String originalUrl;
  final String finalUrl;
  final int riskScore; // 0-100
  final List<String> riskFactors;
  final bool isReachable;

  LinkAnalysisResult({
    required this.originalUrl,
    required this.finalUrl,
    required this.riskScore,
    required this.riskFactors,
    required this.isReachable,
  });
}

class LinkAnalyzerService {
  Future<LinkAnalysisResult> analyzeLink(String url) async {
    String currentUrl = url;
    if (!currentUrl.startsWith('http')) {
      currentUrl = 'https://$currentUrl';
    }

    String finalUrl = currentUrl;
    bool isReachable = false;
    List<String> risks = [];
    int score = 0;

    // 1. Check Reachability & Redirects
    try {
      final request = http.Request('HEAD', Uri.parse(currentUrl));
      request.followRedirects = true;
      request.maxRedirects = 5;

      final response = await http.Client().send(request);
      finalUrl = response.request?.url.toString() ?? currentUrl;
      isReachable = response.statusCode < 400;
    } catch (e) {
      isReachable = false;
      risks.add("Site Unreachable or Invalid SSL");
      score += 20;
    }

    // 2. Heuristic Analysis on FINAL URL
    final uri = Uri.tryParse(finalUrl);
    if (uri != null) {
      // Check for IP address usage
      final host = uri.host;
      final isIp = RegExp(
        r'^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$',
      ).hasMatch(host);
      if (isIp) {
        risks.add("Host is an IP Address (Suspicious)");
        score += 40;
      }

      // Check for Phishing patterns
      if (finalUrl.contains('@')) {
        risks.add("Contains '@' (Potential Phishing)");
        score += 50;
      }

      // Check for suspicious TLDs
      if (host.endsWith('.xyz') ||
          host.endsWith('.top') ||
          host.endsWith('.club')) {
        risks.add("Suspicious TLD (.xyz/.top/.club)");
        score += 20;
      }

      // Check for excessive length
      if (finalUrl.length > 100) {
        risks.add("URL is extremely long (>100 chars)");
        score += 10;
      }

      // Check for multiple subdomains
      if (host.split('.').length > 4) {
        risks.add("Excessive Subdomains");
        score += 15;
      }

      // Check for non-standard ports
      if (uri.hasPort && uri.port != 80 && uri.port != 443) {
        risks.add("Non-standard Port (${uri.port})");
        score += 20;
      }
    }

    return LinkAnalysisResult(
      originalUrl: url,
      finalUrl: finalUrl,
      riskScore: score.clamp(0, 100),
      riskFactors: risks,
      isReachable: isReachable,
    );
  }
}
