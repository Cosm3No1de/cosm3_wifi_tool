import 'package:http/http.dart' as http;
import '../utils/logger.dart';

class SocialProfile {
  final String platform;
  final String url;
  final bool exists;
  final String? error;

  SocialProfile({
    required this.platform,
    required this.url,
    required this.exists,
    this.error,
  });
}

class SocialService {
  static const String _tag = "SocialService";

  // List of platforms to check.
  // Note: Many modern platforms have strict anti-scraping or require auth.
  // We use simple status code checks which work for some, but might yield false negatives on others.
  final Map<String, String> _platforms = {
    'Instagram': 'https://www.instagram.com/{user}/',
    'Facebook': 'https://www.facebook.com/{user}',
    'Twitter (X)': 'https://twitter.com/{user}', // Harder to scrape
    'TikTok': 'https://www.tiktok.com/@{user}',
    'GitHub': 'https://github.com/{user}',
    'Pinterest': 'https://www.pinterest.com/{user}/',
    'Reddit': 'https://www.reddit.com/user/{user}/',
    'Twitch': 'https://www.twitch.tv/{user}',
    'YouTube': 'https://www.youtube.com/@{user}',
    'Steam': 'https://steamcommunity.com/id/{user}',
    'Telegram': 'https://t.me/{user}',
  };

  // Error signatures to detect false positives (200 OK but actually not found or login page)
  final Map<String, List<String>> _errorSignatures = {
    'Instagram': [
      'page not found',
      'sorry, this page isn\'t available',
      'the link you followed may be broken',
    ],
    'Facebook': [
      'page not found',
      'content not found',
      'this content isn\'t available right now',
    ],
    'TikTok': ['couldn\'t find this account', 'page not available'],
    'Reddit': ['sorry, nobody on reddit goes by that name', 'not found'],
    'GitHub': ['not found', '404'],
    'Twitch': ['content not found', 'sorry'],
    'Steam': ['the specified profile could not be found'],
    'Pinterest': ['user not found'],
    'YouTube': ['404', 'not found', 'this page isn\'t available'],
  };

  Future<List<SocialProfile>> checkUsername(String username) async {
    List<SocialProfile> results = [];
    Logger.log(_tag, "Checking username: $username");

    // Create a list of futures to run in parallel
    List<Future<void>> checks = _platforms.entries.map((entry) async {
      final platform = entry.key;
      final urlTemplate = entry.value;
      final url = urlTemplate.replaceAll('{user}', username);

      try {
        final exists = await _checkUrl(platform, url);
        if (exists) {
          results.add(
            SocialProfile(platform: platform, url: url, exists: true),
          );
        }
      } catch (e) {
        Logger.error(_tag, "Error checking $platform", e);
      }
    }).toList();

    await Future.wait(checks);
    return results;
  }

  Future<bool> _checkUrl(String platform, String url) async {
    try {
      final uri = Uri.parse(url);
      final response = await http
          .get(
            uri,
            headers: {
              'User-Agent':
                  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
              'Accept':
                  'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8',
              'Accept-Language': 'en-US,en;q=0.9',
              'Connection': 'keep-alive',
              'Upgrade-Insecure-Requests': '1',
              'Sec-Fetch-Dest': 'document',
              'Sec-Fetch-Mode': 'navigate',
              'Sec-Fetch-Site': 'none',
              'Sec-Fetch-User': '?1',
            },
          )
          .timeout(const Duration(seconds: 10)); // Increased timeout

      // 1. Basic Status Code Check
      if (response.statusCode == 404) return false;
      // Some platforms return 403/429 if they detect a bot, but we might want to treat that as "maybe exists" or "error".
      // For now, let's assume strict 200 for success, but some might be 200 even if not found.
      if (response.statusCode != 200) return false;

      // 2. Content Analysis (Body Check)
      final body = response.body.toLowerCase();

      // Check specific platform signatures
      final signatures = _errorSignatures[platform];
      if (signatures != null) {
        for (final sig in signatures) {
          if (body.contains(sig.toLowerCase())) {
            return false;
          }
        }
      }

      // 4. Generic "Not Found" check for others
      if (body.contains("404") ||
          body.contains("not found") ||
          body.contains("doesn't exist")) {
        // Be careful with false negatives here, but for a scanner it's better to be strict
        // However, some valid profiles might have "not found" in a post.
        // So we rely mostly on specific signatures above.

        // If it's a platform we don't have specific signatures for, use generic
        if (signatures == null) {
          return false;
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }
}
