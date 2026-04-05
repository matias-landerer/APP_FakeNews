import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _storage = FlutterSecureStorage();
const _key = 'user_id';

Future<void> saveSession(int userId) async {
  await _storage.write(key: _key, value: userId.toString());
}

Future<int?> getSession() async {
  final value = await _storage.read(key: _key);
  return value != null ? int.tryParse(value) : null;
}

Future<void> clearSession() async {
  await _storage.delete(key: _key);
}