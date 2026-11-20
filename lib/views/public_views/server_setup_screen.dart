import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../server_config.dart';
import '../../services/notification/websocket_service.dart';

class ServerSetupScreen extends StatefulWidget {
  final Widget Function() next;
  const ServerSetupScreen({super.key, required this.next});

  @override
  State<ServerSetupScreen> createState() => _ServerSetupScreenState();
}

class _ServerSetupScreenState extends State<ServerSetupScreen> {
  final _hostCtrl = TextEditingController(text: ServerConfig.host);
  final _portCtrl = TextEditingController(text: ServerConfig.port);
  bool _manual = false;
  bool _testing = false;
  String? _error;

  @override
  void dispose() {
    _hostCtrl.dispose();
    _portCtrl.dispose();
    super.dispose();
  }

  String _cleanHost(String v) {
    var s = v.trim().replaceAll(RegExp(r'^https?://'), '');
    s = s.split('/').first;
    return s.split(':').first;
  }

  Future<bool> _reachable(String host, String port) async {
    try {
      await http
          .get(Uri.parse('http://$host:$port/'))
          .timeout(const Duration(seconds: 4));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _connect({required bool useDefault}) async {
    final host =
        useDefault ? ServerConfig.defaultHost : _cleanHost(_hostCtrl.text);
    final port = useDefault ? ServerConfig.defaultPort : _portCtrl.text.trim();

    if (host.isEmpty || int.tryParse(port) == null) {
      setState(() => _error = 'أدخل IP ومنفذ صحيحين');
      return;
    }

    setState(() {
      _testing = true;
      _error = null;
    });

    final ok = await _reachable(host, port);
    if (!mounted) return;
    setState(() => _testing = false);

    if (!ok) {
      setState(() => _error =
          'تعذر الوصول إلى $host:$port\nتأكد أن السيرفر شغال وأن الجهازين على نفس الشبكة');
      return;
    }

    await ServerConfig.save(host, port);
    if (Get.isRegistered<WebSocketService>()) {
      await Get.delete<WebSocketService>(force: true);
    }
    Get.put(WebSocketService(), permanent: true);
    Get.offAll(() => widget.next());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.dns_rounded, size: 64),
                  const SizedBox(height: 12),
                  const Text('الاتصال بالسيرفر',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed:
                        _testing ? null : () => _connect(useDefault: true),
                    child: Text(
                        'استخدام الافتراضي (${ServerConfig.defaultHost}:${ServerConfig.defaultPort})'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: _testing
                        ? null
                        : () => setState(() => _manual = !_manual),
                    child: const Text('إدخال IP يدوياً'),
                  ),
                  if (_manual) ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: _hostCtrl,
                      keyboardType: TextInputType.url,
                      textDirection: TextDirection.ltr,
                      decoration: const InputDecoration(
                        labelText: 'عنوان السيرفر (IP)',
                        hintText: '192.168.43.50',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _portCtrl,
                      keyboardType: TextInputType.number,
                      textDirection: TextDirection.ltr,
                      decoration: const InputDecoration(
                        labelText: 'المنفذ',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed:
                          _testing ? null : () => _connect(useDefault: false),
                      child: const Text('اتصال'),
                    ),
                  ],
                  if (_testing) ...[
                    const SizedBox(height: 16),
                    const Center(child: CircularProgressIndicator()),
                  ],
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Text(_error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red)),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}