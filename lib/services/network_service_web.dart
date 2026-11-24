import 'package:web/web.dart' as web;

Future<bool> checkPlatformInternet() async {
  return web.window.navigator.onLine;
}
