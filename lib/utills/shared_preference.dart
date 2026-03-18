import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceHelper {
  static late SharedPreferences _prefs;

  static Future<SharedPreferences> init() async {
    _prefs = await SharedPreferences.getInstance();
    return _prefs;
  }

  // Sets
  static Future<bool> setBool(String key, bool value) async =>
      await _prefs.setBool(key, value);

  static Future<bool> setDouble(String key, double value) async =>
      await _prefs.setDouble(key, value);

  static Future<bool> setInt(String key, int value) async =>
      await _prefs.setInt(key, value);

  static Future<bool> setString(String key, String value) async =>
      await _prefs.setString(key, value);

  static Future<bool> setStringList(String key, List<String> value) async =>
      await _prefs.setStringList(key, value);

  // Gets
  static bool? getBool(String key) => _prefs.getBool(key);

  static double? getDouble(String key) => _prefs.getDouble(key);

  static int? getInt(String key) => _prefs.getInt(key);

  static String? getString(String key) => _prefs.getString(key);

  static List<String>? getStringList(String key) => _prefs.getStringList(key);

  // Deletes
  static Future<bool>? remove(String key) async => await _prefs.remove(key);

  static Future<bool> clear() async => await _prefs.clear();

  // ── Token ──────────────────────────────────────────────────────────────────
  static void setToken(String access_token) =>
      setString("access_token", access_token);

  static String? getToken() => getString('access_token') ?? "";

  static void setClubId(String access_token) =>
      setString("club_id", access_token);

  static String? getClubId() => getString('club_id') ?? "";

  // ── User ID (from JWT / getTasks) ──────────────────────────────────────────
  static void setId(int userId) => setInt('user_id', userId);

  static int? getId() => getInt("user_id");

  // ── Role (CLUB_ADMIN / COACH / GUARDIAN / MEMBER) ─────────────────────────
  static void setRole(String role) => setString('role', role);

  static String? getRole() => getString('role') ?? '';

  // ── Username ───────────────────────────────────────────────────────────────
  static void setUsername(String username) => setString('username', username);

  static String? getUsername() => getString('username') ?? '';

  // ── Other existing helpers ─────────────────────────────────────────────────
  static void setIsOtpVerified(bool isVerified) =>
      setBool('is_otp_verified', isVerified);

  static bool? getIsOtpVerified() => getBool('is_otp_verified');

  static void setKilo(bool track) => setBool('kilo', track);

  static bool getKilo() => getBool('kilo') ?? false;

  static void setIsKycVerified(bool isVerified) =>
      setBool('is_kyc_verified', isVerified);

  static bool? getIsKycVerified() => getBool('is_kyc_verified');

  static void TrackingId(String trackId) => setString("tracking_id", trackId);

  static String? TrackId() => getString('tracking_id') ?? "";

  static void setMobile(String mobile) => setString("mobile", mobile);

  static String? getMobile() => getString('mobile');

  static Future<void> setDeliveryAddress(String address) async =>
      await setString('delivery_address', address);

  static String? getDeliveryAddress() => getString('delivery_address');

  static Future<void> setLatitude(double latitude) async =>
      await setDouble('latitude', latitude);

  static double? getLatitude() => getDouble('latitude');

  static Future<void> setLongitude(double longitude) async =>
      await setDouble('longitude', longitude);

  static double? getLongitude() => getDouble('longitude');

  static Future<void> setLastLatitude(double latitude) async =>
      await setDouble('last_latitude', latitude);

  static double? getLastLatitude() => getDouble('last_latitude');

  static Future<void> setLastLongitude(double longitude) async =>
      await setDouble('last_longitude', longitude);

  static double? getLastLongitude() => getDouble('last_longitude');

  static void setPermission(String data) => setString("permission", data);

  static String? getPermission() => getString('permission');

  static void setFcmToken(String token) => setString("fcm_token", token);

  static String? getFcmToken() => getString("fcm_token");

  static Future<void> verifyOtp(String verifyOtp) async =>
      await setString("verify_otp", verifyOtp);

  static String? getVerify() => getString("verify_otp");

  static Future<void> setRideId(int rideId) async =>
      await setInt('ride_id', rideId);

  static int? getRideId() => getInt('ride_id');

  static Future<void> setTripKm(String tripKm) async =>
      await setString('tripKm', tripKm);

  static String getTripKm() => getString('tripKm') ?? "0.0";

  static Future<void> clearRideId() async => await remove('ride_id');

  static void setInternet(bool connect) => setBool('internet', connect);

  static bool getInternet() => getBool('internet') ?? false;

  static void setSplash(bool splash) => setBool('navigate', splash);

  static bool getSplash() => getBool('navigate') ?? false;

  static void setApprove(String approve) => setString("approved", approve);

  static String? getApprove() => getString('approved') ?? "";
}
