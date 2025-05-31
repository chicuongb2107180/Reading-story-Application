import 'package:pocketbase/pocketbase.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

PocketBase? _pocketBase;

Future<PocketBase> getPocketBaseInstance() async {
  if (_pocketBase != null) {
    return _pocketBase!;
  }

  final prefs = await SharedPreferences.getInstance();

  final store = AsyncAuthStore(
    save: (String data) async => prefs.setString('pb_auth', data),
    initial: prefs.getString('pb_auth'),
  );

  final baseUrl = dotenv.env['POCKETBASE_URL']!;
  _pocketBase = PocketBase(baseUrl, authStore: store);
  return _pocketBase!;
}
