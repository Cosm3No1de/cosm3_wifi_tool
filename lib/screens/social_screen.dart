import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme.dart';
import '../services/localization_service.dart';
import '../services/social_service.dart';

class SocialScreen extends StatefulWidget {
  const SocialScreen({super.key});

  @override
  State<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen> {
  final TextEditingController _userController = TextEditingController();
  final SocialService _socialService = SocialService();
  List<SocialProfile> _results = [];
  bool _loading = false;
  bool _searched = false;

  Future<void> _startScan() async {
    final user = _userController.text.trim();
    if (user.isEmpty) return;

    // Hide keyboard
    FocusScope.of(context).unfocus();

    setState(() {
      _loading = true;
      _results = [];
      _searched = true;
    });

    try {
      final results = await _socialService.checkUsername(user);
      if (mounted) {
        setState(() {
          _results = results;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LanguageService().translate('social_tracker_title'),
            style: const TextStyle(
              color: AppTheme.primary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Courier',
            ),
          ),
          const SizedBox(height: 10),
          Text(
            LanguageService().translate('social_tracker_desc'),
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),

          // Input Area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppTheme.primary.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.person_search, color: AppTheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _userController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: LanguageService().translate('enter_username'),
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _startScan(),
                  ),
                ),
                IconButton(
                  icon: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send, color: AppTheme.primary),
                  onPressed: _loading ? null : _startScan,
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Results Area
          if (_loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    CircularProgressIndicator(color: AppTheme.primary),
                    SizedBox(height: 10),
                    Text(
                      "Scanning networks...",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),

          if (!_loading && _searched && _results.isEmpty)
            Center(
              child: Text(
                LanguageService().translate('no_profiles_found'),
                style: const TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

          if (!_loading && _results.isNotEmpty) ...[
            Text(
              "${LanguageService().translate('found_profiles')}: ${_results.length}",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final profile = _results[index];
                return Card(
                  color: AppTheme.cardColor,
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: AppTheme.primary.withValues(alpha: 0.3),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.link, color: Colors.white),
                    title: Text(
                      profile.platform,
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      profile.url,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Icon(
                      Icons.open_in_new,
                      color: Colors.white54,
                    ),
                    onTap: () => _launchUrl(profile.url),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
