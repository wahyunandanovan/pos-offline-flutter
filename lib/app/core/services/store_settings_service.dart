import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StoreSettingsService extends GetxService {
  static const String _storeNameKey = 'store_name';
  static const String _storeAddressKey = 'store_address';
  static const String _storePhoneKey = 'store_phone';
  static const String _storeEmailKey = 'store_email';
  static const String _storeLogoKey = 'store_logo_path';

  late SharedPreferences _prefs;

  final storeName = 'Toko Saya'.obs;
  final storeAddress = ''.obs;
  final storePhone = ''.obs;
  final storeEmail = ''.obs;
  final storeLogoPath = Rxn<String>();

  Future<StoreSettingsService> init() async {
    _prefs = Get.find<SharedPreferences>();
    await _loadSettings();
    return this;
  }

  Future<void> _loadSettings() async {
    storeName.value = _prefs.getString(_storeNameKey) ?? 'Toko Saya';
    storeAddress.value = _prefs.getString(_storeAddressKey) ?? '';
    storePhone.value = _prefs.getString(_storePhoneKey) ?? '';
    storeEmail.value = _prefs.getString(_storeEmailKey) ?? '';
    storeLogoPath.value = _prefs.getString(_storeLogoKey);
  }

  Future<void> saveStoreName(String name) async {
    storeName.value = name;
    await _prefs.setString(_storeNameKey, name);
  }

  Future<void> saveStoreAddress(String address) async {
    storeAddress.value = address;
    await _prefs.setString(_storeAddressKey, address);
  }

  Future<void> saveStorePhone(String phone) async {
    storePhone.value = phone;
    await _prefs.setString(_storePhoneKey, phone);
  }

  Future<void> saveStoreEmail(String email) async {
    storeEmail.value = email;
    await _prefs.setString(_storeEmailKey, email);
  }

  Future<void> saveStoreLogoPath(String? path) async {
    storeLogoPath.value = path;
    if (path != null) {
      await _prefs.setString(_storeLogoKey, path);
    } else {
      await _prefs.remove(_storeLogoKey);
    }
  }

  Future<void> saveAllSettings({
    required String name,
    String? address,
    String? phone,
    String? email,
    String? logoPath,
  }) async {
    await saveStoreName(name);
    if (address != null) await saveStoreAddress(address);
    if (phone != null) await saveStorePhone(phone);
    if (email != null) await saveStoreEmail(email);
    if (logoPath != null) await saveStoreLogoPath(logoPath);
  }
}
