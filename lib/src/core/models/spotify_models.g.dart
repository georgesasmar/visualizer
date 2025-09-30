// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spotify_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SpotifyTokens _$SpotifyTokensFromJson(Map<String, dynamic> json) =>
    SpotifyTokens(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String?,
      expiresIn: (json['expires_in'] as num).toInt(),
      tokenType: json['token_type'] as String,
      scope: json['scope'] as String,
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
    );

Map<String, dynamic> _$SpotifyTokensToJson(SpotifyTokens instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'refresh_token': instance.refreshToken,
      'expires_in': instance.expiresIn,
      'token_type': instance.tokenType,
      'scope': instance.scope,
      'expiresAt': instance.expiresAt?.toIso8601String(),
    };

CurrentlyPlaying _$CurrentlyPlayingFromJson(Map<String, dynamic> json) =>
    CurrentlyPlaying(
      isPlaying: json['is_playing'] as bool,
      progressMs: (json['progress_ms'] as num?)?.toInt(),
      item: json['item'] == null
          ? null
          : Track.fromJson(json['item'] as Map<String, dynamic>),
      device: json['device'] as String?,
    );

Map<String, dynamic> _$CurrentlyPlayingToJson(CurrentlyPlaying instance) =>
    <String, dynamic>{
      'is_playing': instance.isPlaying,
      'progress_ms': instance.progressMs,
      'item': instance.item,
      'device': instance.device,
    };

Track _$TrackFromJson(Map<String, dynamic> json) => Track(
      id: json['id'] as String,
      name: json['name'] as String,
      artists: (json['artists'] as List<dynamic>)
          .map((e) => Artist.fromJson(e as Map<String, dynamic>))
          .toList(),
      album: Album.fromJson(json['album'] as Map<String, dynamic>),
      durationMs: (json['duration_ms'] as num).toInt(),
    );

Map<String, dynamic> _$TrackToJson(Track instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'artists': instance.artists,
      'album': instance.album,
      'duration_ms': instance.durationMs,
    };

Artist _$ArtistFromJson(Map<String, dynamic> json) => Artist(
      id: json['id'] as String,
      name: json['name'] as String,
    );

Map<String, dynamic> _$ArtistToJson(Artist instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
    };

Album _$AlbumFromJson(Map<String, dynamic> json) => Album(
      id: json['id'] as String,
      name: json['name'] as String,
      images: (json['images'] as List<dynamic>)
          .map((e) => SpotifyImage.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AlbumToJson(Album instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'images': instance.images,
    };

SpotifyImage _$SpotifyImageFromJson(Map<String, dynamic> json) => SpotifyImage(
      url: json['url'] as String,
      width: (json['width'] as num?)?.toInt(),
      height: (json['height'] as num?)?.toInt(),
    );

Map<String, dynamic> _$SpotifyImageToJson(SpotifyImage instance) =>
    <String, dynamic>{
      'url': instance.url,
      'width': instance.width,
      'height': instance.height,
    };

AudioAnalysis _$AudioAnalysisFromJson(Map<String, dynamic> json) =>
    AudioAnalysis(
      segments: (json['segments'] as List<dynamic>)
          .map((e) => Segment.fromJson(e as Map<String, dynamic>))
          .toList(),
      track: AudioAnalysisTrack.fromJson(json['track'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AudioAnalysisToJson(AudioAnalysis instance) =>
    <String, dynamic>{
      'segments': instance.segments,
      'track': instance.track,
    };

AudioAnalysisTrack _$AudioAnalysisTrackFromJson(Map<String, dynamic> json) =>
    AudioAnalysisTrack(
      duration: (json['duration'] as num).toDouble(),
      tempo: (json['tempo'] as num).toDouble(),
      timeSignature: (json['time_signature'] as num).toInt(),
      loudness: (json['loudness'] as num).toDouble(),
    );

Map<String, dynamic> _$AudioAnalysisTrackToJson(AudioAnalysisTrack instance) =>
    <String, dynamic>{
      'duration': instance.duration,
      'tempo': instance.tempo,
      'time_signature': instance.timeSignature,
      'loudness': instance.loudness,
    };

Segment _$SegmentFromJson(Map<String, dynamic> json) => Segment(
      start: (json['start'] as num).toDouble(),
      duration: (json['duration'] as num).toDouble(),
      confidence: (json['confidence'] as num).toDouble(),
      loudnessStart: (json['loudness_start'] as num).toDouble(),
      loudnessMax: (json['loudness_max'] as num).toDouble(),
      loudnessMaxTime: (json['loudness_max_time'] as num).toDouble(),
      loudnessEnd: (json['loudness_end'] as num).toDouble(),
      pitches: (json['pitches'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      timbre: (json['timbre'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
    );

Map<String, dynamic> _$SegmentToJson(Segment instance) => <String, dynamic>{
      'start': instance.start,
      'duration': instance.duration,
      'confidence': instance.confidence,
      'loudness_start': instance.loudnessStart,
      'loudness_max': instance.loudnessMax,
      'loudness_max_time': instance.loudnessMaxTime,
      'loudness_end': instance.loudnessEnd,
      'pitches': instance.pitches,
      'timbre': instance.timbre,
    };

AudioFeatures _$AudioFeaturesFromJson(Map<String, dynamic> json) =>
    AudioFeatures(
      danceability: (json['danceability'] as num).toDouble(),
      energy: (json['energy'] as num).toDouble(),
      key: (json['key'] as num).toInt(),
      loudness: (json['loudness'] as num).toDouble(),
      mode: (json['mode'] as num).toInt(),
      speechiness: (json['speechiness'] as num).toDouble(),
      acousticness: (json['acousticness'] as num).toDouble(),
      instrumentalness: (json['instrumentalness'] as num).toDouble(),
      liveness: (json['liveness'] as num).toDouble(),
      valence: (json['valence'] as num).toDouble(),
      tempo: (json['tempo'] as num).toDouble(),
      durationMs: (json['duration_ms'] as num).toInt(),
      timeSignature: (json['time_signature'] as num).toInt(),
    );

Map<String, dynamic> _$AudioFeaturesToJson(AudioFeatures instance) =>
    <String, dynamic>{
      'danceability': instance.danceability,
      'energy': instance.energy,
      'key': instance.key,
      'loudness': instance.loudness,
      'mode': instance.mode,
      'speechiness': instance.speechiness,
      'acousticness': instance.acousticness,
      'instrumentalness': instance.instrumentalness,
      'liveness': instance.liveness,
      'valence': instance.valence,
      'tempo': instance.tempo,
      'duration_ms': instance.durationMs,
      'time_signature': instance.timeSignature,
    };
