import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _storage = FlutterSecureStorage(
  webOptions: WebOptions(dbName: 'fakenews', publicKey: 'fakenews_key'),
);
const _key = 'user_id';

Future<void> saveSession(String userId) async {
  await _storage.write(key: _key, value: userId);
}

Future<String?> getSession() async {
  return await _storage.read(key: _key);
}

Future<void> clearSession() async {
  await _storage.delete(key: _key);
}