import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/spotify_models.dart';

class StorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static const String _tokensKey = 'spotify_tokens';
  static const String _themeKey = 'theme_mode';
  static const String _visualizerStyleKey = 'visualizer_style';
  static const String _visualizerColorKey = 'visualizer_color';

  // Secure storage for sensitive data
  Future<void> storeTokens(SpotifyTokens tokens) async {
    final expiresAt = DateTime.now().add(Duration(seconds: tokens.expiresIn));
    final tokensWithExpiry = tokens.copyWith(expiresAt: expiresAt);
    await _storage.write(
      key: _tokensKey,
      value: json.encode(tokensWithExpiry.toJson()),
    );
  }

  Future<SpotifyTokens?> getTokens() async {
    final tokensJson = await _storage.read(key: _tokensKey);
    if (tokensJson == null) return null;
    
    try {
      final tokensMap = json.decode(tokensJson) as Map<String, dynamic>;
      return SpotifyTokens.fromJson(tokensMap);
    } catch (e) {
      print('Error parsing tokens: $e');
      return null;
    }
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: _tokensKey);
  }

  // Shared preferences for non-sensitive data
  Future<void> setThemeMode(String themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, themeMode);
  }

  Future<String?> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeKey);
  }

  Future<void> setVisualizerStyle(String style) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_visualizerStyleKey, style);
  }

  Future<String?> getVisualizerStyle() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_visualizerStyleKey);
  }

  Future<void> setVisualizerColor(int colorValue) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_visualizerColorKey, colorValue);
  }

  Future<int?> getVisualizerColor() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_visualizerColorKey);
  }

  // Widget data sharing
  Future<void> storeWidgetData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('widget_data', json.encode(data));
  }

  Future<Map<String, dynamic>?> getWidgetData() async {
    final prefs = await SharedPreferences.getInstance();
    final dataJson = prefs.getString('widget_data');
    if (dataJson == null) return null;
    
    try {
      return json.decode(dataJson) as Map<String, dynamic>;
    } catch (e) {
      print('Error parsing widget data: $e');
      return null;
    }
  }
}