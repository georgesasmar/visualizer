import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:app_links/app_links.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/spotify_models.dart';
import 'storage_service.dart';

class SpotifyService {
  static const String clientId = 'd1341ffc2cd844b9b94b942a188a16fd'; // Replace with actual client ID
  static const String redirectUri = 'com.example.spotifyvisualizer://callback';
  static const String scopes = 'user-read-playback-state user-read-currently-playing';
  static const String baseUrl = 'https://api.spotify.com/v1';
  static const String authUrl = 'https://accounts.spotify.com/api/token';
  static const String authorizeUrl = 'https://accounts.spotify.com/authorize';

  final StorageService storageService;
  SpotifyTokens? _currentTokens;

  SpotifyService({required this.storageService});

  Future<void> initialize() async {
    _currentTokens = await storageService.getTokens();
    if (_currentTokens?.isExpired == true) {
      await _refreshTokens();
    }
  }

  bool get isAuthenticated =>
      _currentTokens != null && !_currentTokens!.isExpired;

  Future<bool> authenticate() async {
    try {
      final codeVerifier = _generateCodeVerifier();
      final codeChallenge = _generateCodeChallenge(codeVerifier);
      final state = _generateRandomString(16);

      final authUri = Uri.parse(authorizeUrl).replace(queryParameters: {
        'client_id': clientId,
        'response_type': 'code',
        'redirect_uri': redirectUri,
        'code_challenge_method': 'S256',
        'code_challenge': codeChallenge,
        'state': state,
        'scope': scopes,
      });

      if (!await launchUrl(authUri, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch auth URL');
      }

      final appLinks = AppLinks();

      // First check if app was opened with a link
      final Uri? initialUri = await appLinks.getInitialLink();
      if (initialUri != null &&
          initialUri.toString().startsWith(redirectUri)) {
        final code = initialUri.queryParameters['code'];
        final returnedState = initialUri.queryParameters['state'];

        if (code != null && returnedState == state) {
          await _exchangeCodeForTokens(code, codeVerifier);
          return true;
        }
      }

      // Listen for new incoming links
      await for (final Uri? uri in appLinks.uriLinkStream) {
        if (uri == null) continue;

        if (uri.toString().startsWith(redirectUri)) {
          final code = uri.queryParameters['code'];
          final returnedState = uri.queryParameters['state'];

          if (code != null && returnedState == state) {
            await _exchangeCodeForTokens(code, codeVerifier);
            return true;
          }
        }
      }

      return false;
    } catch (e) {
      print('Authentication error: $e');
      return false;
    }
  }

  Future<void> _exchangeCodeForTokens(
      String code, String codeVerifier) async {
    final response = await http.post(
      Uri.parse(authUrl),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'client_id': clientId,
        'grant_type': 'authorization_code',
        'code': code,
        'redirect_uri': redirectUri,
        'code_verifier': codeVerifier,
      },
    );

    if (response.statusCode == 200) {
      final tokens = SpotifyTokens.fromJson(json.decode(response.body));
      _currentTokens = tokens;
      await storageService.storeTokens(tokens);
    } else {
      throw Exception('Token exchange failed: ${response.body}');
    }
  }

  Future<void> _refreshTokens() async {
    if (_currentTokens?.refreshToken == null) return;

    final response = await http.post(
      Uri.parse(authUrl),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'refresh_token',
        'refresh_token': _currentTokens!.refreshToken!,
        'client_id': clientId,
      },
    );

    if (response.statusCode == 200) {
      final newTokens = SpotifyTokens.fromJson(json.decode(response.body));
      _currentTokens = newTokens.copyWith(
        refreshToken:
        newTokens.refreshToken ?? _currentTokens!.refreshToken,
      );
      await storageService.storeTokens(_currentTokens!);
    }
  }

  Future<CurrentlyPlaying?> getCurrentlyPlaying() async {
    if (!isAuthenticated) return null;

    try {
      final response = await _makeAuthenticatedRequest(
          '$baseUrl/me/player/currently-playing');
      if (response.statusCode == 200) {
        return CurrentlyPlaying.fromJson(json.decode(response.body));
      } else if (response.statusCode == 204) {
        return null; // No track currently playing
      }
      return null;
    } catch (e) {
      print('Error getting currently playing: $e');
      return null;
    }
  }

  Future<AudioAnalysis?> getAudioAnalysis(String trackId) async {
    if (!isAuthenticated) return null;

    try {
      final response =
      await _makeAuthenticatedRequest('$baseUrl/audio-analysis/$trackId');
      if (response.statusCode == 200) {
        return AudioAnalysis.fromJson(json.decode(response.body));
      }
      return null;
    } catch (e) {
      print('Error getting audio analysis: $e');
      return null;
    }
  }

  Future<AudioFeatures?> getAudioFeatures(String trackId) async {
    if (!isAuthenticated) return null;

    try {
      final response =
      await _makeAuthenticatedRequest('$baseUrl/audio-features/$trackId');
      if (response.statusCode == 200) {
        return AudioFeatures.fromJson(json.decode(response.body));
      }
      return null;
    } catch (e) {
      print('Error getting audio features: $e');
      return null;
    }
  }

  Future<http.Response> _makeAuthenticatedRequest(String url) async {
    if (_currentTokens?.isExpired == true) {
      await _refreshTokens();
    }

    return await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer ${_currentTokens!.accessToken}',
        'Content-Type': 'application/json',
      },
    );
  }

  String _generateCodeVerifier() {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
    final random = Random.secure();
    return List.generate(
        128, (i) => chars[random.nextInt(chars.length)]).join();
  }

  String _generateCodeChallenge(String codeVerifier) {
    final bytes = utf8.encode(codeVerifier);
    final digest = sha256.convert(bytes);
    return base64Url.encode(digest.bytes).replaceAll('=', '');
  }

  String _generateRandomString(int length) {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random.secure();
    return List.generate(
        length, (i) => chars[random.nextInt(chars.length)]).join();
  }

  Future<void> logout() async {
    _currentTokens = null;
    await storageService.clearTokens();
  }
}
