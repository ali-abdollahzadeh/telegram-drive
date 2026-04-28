import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/constants/app_constants.dart';

class SecureStorageService {
  SecureStorageService._internal();
  static final SecureStorageService instance = SecureStorageService._internal();

  late final FlutterSecureStorage _storage;

  Future<void> init() async {
    _storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    );
  }

  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  Future<bool> isLoggedIn() async {
    final val = await _storage.read(key: StorageKeys.isLoggedIn);
    return val == 'true';
  }

  Future<void> saveSession({
    required String apiId,
    required String apiHash,
    required String phone,
    required String sessionString,
  }) async {
    await _storage.write(key: StorageKeys.apiId, value: apiId);
    await _storage.write(key: StorageKeys.apiHash, value: apiHash);
    await _storage.write(key: StorageKeys.phoneNumber, value: phone);
    await _storage.write(key: StorageKeys.sessionString, value: sessionString);
    await _storage.write(key: StorageKeys.isLoggedIn, value: 'true');
  }

  Future<Map<String, String?>> readSession() async {
    return {
      'apiId': await _storage.read(key: StorageKeys.apiId),
      'apiHash': await _storage.read(key: StorageKeys.apiHash),
      'phone': await _storage.read(key: StorageKeys.phoneNumber),
      'sessionString': await _storage.read(key: StorageKeys.sessionString),
    };
  }

  Future<void> clearSession() async {
    await _storage.delete(key: StorageKeys.apiId);
    await _storage.delete(key: StorageKeys.apiHash);
    await _storage.delete(key: StorageKeys.phoneNumber);
    await _storage.delete(key: StorageKeys.sessionString);
    await _storage.delete(key: StorageKeys.isLoggedIn);
  }
}
