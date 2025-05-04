import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<bool> isAccessTokenExpired() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? accessToken = prefs.getString('access_token');

  if (accessToken == null) {
    return true; // Token not available, assume expired
  }

  // Check if the token is expired
  bool isExpired = JwtDecoder.isExpired(accessToken);
  return isExpired;
}
