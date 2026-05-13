import 'package:shared_preferences/shared_preferences.dart';
// import 'package:troobot_mobile/services/auth_service.dart';

Future<void> getStr(String spGetter, Function(String?) callBackF) async {
  final sharedPreferences = await SharedPreferences.getInstance();
  final value = sharedPreferences.getString(spGetter);
  callBackF(value);
}

Future<String> getStrReal(String spGetter) async {
  final sharedPreferences = await SharedPreferences.getInstance();
  return sharedPreferences.getString(spGetter) ?? '';
}

Future<void> setStrReal(String spGetter, String value) async {
  final sharedPreferences = await SharedPreferences.getInstance();
  sharedPreferences.setString(spGetter, value);
}

Future<void> removeData(String spRemove, Function() callBackF) async {
  final sharedPreferences = await SharedPreferences.getInstance();
  sharedPreferences.remove(spRemove);
  // await AuthService().signOut();
  callBackF();
}

Future<void> setStr(String spGetter, String value) async {
  final sharedPreferences = await SharedPreferences.getInstance();
  sharedPreferences.setString(spGetter, value);
}

Future<void> setIntgr(String spGetter, int value) async {
  final sharedPreferences = await SharedPreferences.getInstance();
  sharedPreferences.setInt(spGetter, value);
}

Future<void> setIntgr2(String spGetter, int value) async {
  final sharedPreferences = await SharedPreferences.getInstance();
  int? value2 = sharedPreferences.getInt(spGetter);

  sharedPreferences.setInt(spGetter, value2 != null ? value2 += value : value);
}

Future<void> getIntgr2(String spGetter, Function(int?) callBackF) async {
  final sharedPreferences = await SharedPreferences.getInstance();
  final value = sharedPreferences.getInt(spGetter);
  callBackF(value);
}

Future<int?> getIntgr(String spGetter) async {
  final sharedPreferences = await SharedPreferences.getInstance();
  return sharedPreferences.getInt(spGetter);
}

Future<bool?> getBoolean(String spGetter) async {
  final sharedPreferences = await SharedPreferences.getInstance();
  final value = sharedPreferences.getBool(spGetter) ?? false;
  return value;
}

Future<void> setBoolean(String spGetter, bool value) async {
  final sharedPreferences = await SharedPreferences.getInstance();
  sharedPreferences.setBool(spGetter, value);
}

Future<void> removeKey(String spGetter) async {
  final sharedPreferences = await SharedPreferences.getInstance();
  sharedPreferences.remove(spGetter);
}
