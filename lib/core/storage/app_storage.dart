import "package:shared_preferences/shared_preferences.dart";

enum StorageKey {
  fullName,
  email,
  city,
  district,
  uid,
  userLogin,
  userPassword,
  image,
  isUserHave,
}

sealed class AppStorage {
  static Future<void> store(
      {required StorageKey key, required String value}) async {
    final SharedPreferences storage = await SharedPreferences.getInstance();
    await storage.setString(key.name, value);
  }

  static Future<String?> load({required StorageKey key}) async {
    final SharedPreferences storage = await SharedPreferences.getInstance();
    final String? result = storage.getString(key.name);
    if (result == null) {
      return null;
    } else {
      return result;
    }
  }
  static Future<void> delete({required StorageKey key}) async {
    final SharedPreferences storage = await SharedPreferences.getInstance();
    await storage.remove(key.name);
  }


  /// methods for bool variable

  static Future<void> storeBool(
      {required StorageKey key, required bool value}) async {
    final SharedPreferences storage = await SharedPreferences.getInstance();
    await storage.setBool(key.name, value);
  }

  static Future<bool?> loadBool({required StorageKey key}) async {
    final SharedPreferences storage = await SharedPreferences.getInstance();
    final bool? result = storage.getBool(key.name);
    if (result == null) {
      return null;
    } else {
      return result;
    }
  }

}
