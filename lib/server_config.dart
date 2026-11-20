import 'package:get_storage/get_storage.dart';

class ServerConfig {
  static const _kHost = 'server_host';
  static const _kPort = 'server_port';

  static const defaultHost = 'localhost';
  static const defaultPort = '5000';

  // box منفصل حتى ما يمسحه LocalUserStorage.clearAll() عند تسجيل الخروج
  static final GetStorage _box = GetStorage('server');

  static String host = defaultHost;
  static String port = defaultPort;
  static bool isConfigured = false;

  static String get baseUrl => 'http://$host:$port';

  /// لازم تنادى بعد GetStorage.init('server')
  static Future<void> load() async {
    isConfigured = _box.hasData(_kHost);
    host = _box.read<String>(_kHost) ?? defaultHost;
    port = _box.read<String>(_kPort) ?? defaultPort;
  }

  static Future<void> save(String h, String pt) async {
    await _box.write(_kHost, h);
    await _box.write(_kPort, pt);
    host = h;
    port = pt;
    isConfigured = true;
  }

  static Future<void> reset() async {
    await _box.remove(_kHost);
    await _box.remove(_kPort);
    host = defaultHost;
    port = defaultPort;
    isConfigured = false;
  }

  /// يحوّل أي رابط صورة لرابط شغّال على السيرفر الحالي.
  static String? fixUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    final uri = Uri.tryParse(url);
    if (uri == null) return url;
    if (!uri.hasScheme) {
      return '$baseUrl${url.startsWith('/') ? '' : '/'}$url';
    }
    if (uri.path.startsWith('/images/')) {
      return uri.replace(host: host, port: int.tryParse(port)).toString();
    }
    return url;
  }
}