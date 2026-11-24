import 'dart:io';

Future<bool> checkPlatformInternet() async {
  try {
    final interfaces = await NetworkInterface.list(
      includeLoopback: false,
      includeLinkLocal: false,
    ).timeout(const Duration(seconds: 1));
    if (interfaces.isEmpty) return false;
  } catch (_) {}

  try {
    final result = await InternetAddress.lookup(
      'clients3.google.com',
    ).timeout(const Duration(seconds: 2));
    return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
  } catch (_) {
    return false;
  }
}
