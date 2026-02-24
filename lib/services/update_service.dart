import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:convert';

class UpdateInfo {
  final bool hasUpdate;
  final String currentVersion;
  final String latestVersion;
  final String releaseUrl;
  final String? downloadUrl; // direct asset download URL if available

  const UpdateInfo({
    required this.hasUpdate,
    required this.currentVersion,
    required this.latestVersion,
    required this.releaseUrl,
    this.downloadUrl,
  });
}

class UpdateService {
  // Replace with your actual GitHub owner/repo
  static const _owner = 'your-github-username';
  static const _repo = 'printflow';

  static Future<UpdateInfo?> check() async {
    try {
      final info = await PackageInfo.fromPlatform();
      final current = info.version; // e.g. "1.0.0"

      final response = await http.get(
        Uri.parse(
            'https://api.github.com/repos/$_owner/$_repo/releases/latest'),
        headers: {'Accept': 'application/vnd.github+json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final tag = (data['tag_name'] as String?)?.replaceAll('v', '') ?? '';
      final releaseUrl = (data['html_url'] as String?) ?? '';

      // Find Windows asset (exe or msix)
      String? downloadUrl;
      final assets = data['assets'] as List<dynamic>? ?? [];
      for (final asset in assets) {
        final name = (asset['name'] as String? ?? '').toLowerCase();
        if (name.endsWith('.exe') || name.endsWith('.msix')) {
          downloadUrl = asset['browser_download_url'] as String?;
          break;
        }
      }

      final hasUpdate = _isNewer(tag, current);

      return UpdateInfo(
        hasUpdate: hasUpdate,
        currentVersion: current,
        latestVersion: tag,
        releaseUrl: releaseUrl,
        downloadUrl: downloadUrl,
      );
    } catch (_) {
      return null;
    }
  }

  static bool _isNewer(String latest, String current) {
    try {
      final l = latest.split('.').map(int.parse).toList();
      final c = current.split('.').map(int.parse).toList();
      for (var i = 0; i < 3; i++) {
        final lv = i < l.length ? l[i] : 0;
        final cv = i < c.length ? c[i] : 0;
        if (lv > cv) return true;
        if (lv < cv) return false;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
