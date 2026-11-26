import 'package:flutter/foundation.dart';
import 'network_service_io.dart'
    if (dart.library.js_interop) 'network_service_web.dart';

class NoInternetException implements Exception {
  const NoInternetException([
    this.message =
        'Tidak ada koneksi internet. Aktifkan WiFi atau data seluler terlebih dahulu.',
  ]);

  final String message;

  @override
  String toString() => message;
}

class NetworkService {
  NetworkService._();

  static final NetworkService instance = NetworkService._();

  final ValueNotifier<bool> isOnline = ValueNotifier<bool>(true);
  DateTime? _lastCheckedAt;
  Future<bool>? _inFlight;

  @visibleForTesting
  bool? debugOverrideOnline;

  bool get isForcedOffline => debugOverrideOnline == false;

  Future<bool> hasInternet({bool forceRefresh = false}) async {
    if (debugOverrideOnline != null) {
      final val = debugOverrideOnline!;
      isOnline.value = val;
      return val;
    }

    final now = DateTime.now();
    if (!forceRefresh &&
        _lastCheckedAt != null &&
        now.difference(_lastCheckedAt!) < const Duration(seconds: 2)) {
      return isOnline.value;
    }

    if (!forceRefresh && _inFlight != null) {
      return _inFlight!;
    }

    final future = _runCheck();
    _inFlight = future;
    try {
      return await future;
    } finally {
      if (identical(_inFlight, future)) {
        _inFlight = null;
      }
    }
  }

  Future<bool> _runCheck() async {
    final online = await checkPlatformInternet();
    _lastCheckedAt = DateTime.now();
    isOnline.value = online;
    return online;
  }
}
