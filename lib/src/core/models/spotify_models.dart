import 'package:json_annotation/json_annotation.dart';

part 'spotify_models.g.dart';

@JsonSerializable()
class SpotifyTokens {
  @JsonKey(name: 'access_token')
  final String accessToken;
  
  @JsonKey(name: 'refresh_token')
  final String? refreshToken;
  
  @JsonKey(name: 'expires_in')
  final int expiresIn;
  
  @JsonKey(name: 'token_type')
  final String tokenType;
  
  final String scope;
  
  final DateTime? expiresAt;

  SpotifyTokens({
    required this.accessToken,
    this.refreshToken,
    required this.expiresIn,
    required this.tokenType,
    required this.scope,
    this.expiresAt,
  });

  factory SpotifyTokens.fromJson(Map<String, dynamic> json) =>
      _$SpotifyTokensFromJson(json);

  Map<String, dynamic> toJson() => _$SpotifyTokensToJson(this);

  SpotifyTokens copyWith({
    String? accessToken,
    String? refreshToken,
    int? expiresIn,
    String? tokenType,
    String? scope,
    DateTime? expiresAt,
  }) {
    return SpotifyTokens(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresIn: expiresIn ?? this.expiresIn,
      tokenType: tokenType ?? this.tokenType,
      scope: scope ?? this.scope,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }
}

@JsonSerializable()
class CurrentlyPlaying {
  @JsonKey(name: 'is_playing')
  final bool isPlaying;
  
  @JsonKey(name: 'progress_ms')
  final int? progressMs;
  
  final Track? item;
  
  final String? device;

  CurrentlyPlaying({
    required this.isPlaying,
    this.progressMs,
    this.item,
    this.device,
  });

  factory CurrentlyPlaying.fromJson(Map<String, dynamic> json) =>
      _$CurrentlyPlayingFromJson(json);

  Map<String, dynamic> toJson() => _$CurrentlyPlayingToJson(this);
}

@JsonSerializable()
class Track {
  final String id;
  final String name;
  final List<Artist> artists;
  final Album album;
  @JsonKey(name: 'duration_ms')
  final int durationMs;

  Track({
    required this.id,
    required this.name,
    required this.artists,
    required this.album,
    required this.durationMs,
  });

  factory Track.fromJson(Map<String, dynamic> json) => _$TrackFromJson(json);
  Map<String, dynamic> toJson() => _$TrackToJson(this);

  String get artistNames => artists.map((a) => a.name).join(', ');
}

@JsonSerializable()
class Artist {
  final String id;
  final String name;

  Artist({required this.id, required this.name});

  factory Artist.fromJson(Map<String, dynamic> json) => _$ArtistFromJson(json);
  Map<String, dynamic> toJson() => _$ArtistToJson(this);
}

@JsonSerializable()
class Album {
  final String id;
  final String name;
  final List<SpotifyImage> images;

  Album({required this.id, required this.name, required this.images});

  factory Album.fromJson(Map<String, dynamic> json) => _$AlbumFromJson(json);
  Map<String, dynamic> toJson() => _$AlbumToJson(this);

  String? get imageUrl => images.isNotEmpty ? images.first.url : null;
}

@JsonSerializable()
class SpotifyImage {
  final String url;
  final int? width;
  final int? height;

  SpotifyImage({required this.url, this.width, this.height});

  factory SpotifyImage.fromJson(Map<String, dynamic> json) =>
      _$SpotifyImageFromJson(json);
  Map<String, dynamic> toJson() => _$SpotifyImageToJson(this);
}

@JsonSerializable()
class AudioAnalysis {
  final List<Segment> segments;
  final AudioAnalysisTrack track;

  AudioAnalysis({required this.segments, required this.track});

  factory AudioAnalysis.fromJson(Map<String, dynamic> json) =>
      _$AudioAnalysisFromJson(json);
  Map<String, dynamic> toJson() => _$AudioAnalysisToJson(this);
}

@JsonSerializable()
class AudioAnalysisTrack {
  final double duration;
  final double tempo;
  @JsonKey(name: 'time_signature')
  final int timeSignature;
  final double loudness;

  AudioAnalysisTrack({
    required this.duration,
    required this.tempo,
    required this.timeSignature,
    required this.loudness,
  });

  factory AudioAnalysisTrack.fromJson(Map<String, dynamic> json) =>
      _$AudioAnalysisTrackFromJson(json);
  Map<String, dynamic> toJson() => _$AudioAnalysisTrackToJson(this);
}

@JsonSerializable()
class Segment {
  final double start;
  final double duration;
  final double confidence;
  @JsonKey(name: 'loudness_start')
  final double loudnessStart;
  @JsonKey(name: 'loudness_max')
  final double loudnessMax;
  @JsonKey(name: 'loudness_max_time')
  final double loudnessMaxTime;
  @JsonKey(name: 'loudness_end')
  final double loudnessEnd;
  final List<double> pitches;
  final List<double> timbre;

  Segment({
    required this.start,
    required this.duration,
    required this.confidence,
    required this.loudnessStart,
    required this.loudnessMax,
    required this.loudnessMaxTime,
    required this.loudnessEnd,
    required this.pitches,
    required this.timbre,
  });

  factory Segment.fromJson(Map<String, dynamic> json) =>
      _$SegmentFromJson(json);
  Map<String, dynamic> toJson() => _$SegmentToJson(this);
}

@JsonSerializable()
class AudioFeatures {
  final double danceability;
  final double energy;
  final int key;
  final double loudness;
  final int mode;
  final double speechiness;
  final double acousticness;
  final double instrumentalness;
  final double liveness;
  final double valence;
  final double tempo;
  @JsonKey(name: 'duration_ms')
  final int durationMs;
  @JsonKey(name: 'time_signature')
  final int timeSignature;

  AudioFeatures({
    required this.danceability,
    required this.energy,
    required this.key,
    required this.loudness,
    required this.mode,
    required this.speechiness,
    required this.acousticness,
    required this.instrumentalness,
    required this.liveness,
    required this.valence,
    required this.tempo,
    required this.durationMs,
    required this.timeSignature,
  });

  factory AudioFeatures.fromJson(Map<String, dynamic> json) =>
      _$AudioFeaturesFromJson(json);
  Map<String, dynamic> toJson() => _$AudioFeaturesToJson(this);
}