import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:spotify/spotify.dart';
import 'package:spotify_clone_app/constants/Song.dart';

class MusicSlabData with ChangeNotifier {
  // Private constructor
  MusicSlabData._internal();

  // Singleton instance
  static final MusicSlabData _instance = MusicSlabData._internal();

  // Get the singleton instance
  static MusicSlabData get instance => _instance;

  // Initialize ValueNotifiers
  ValueNotifier<Song>? _songInfoNotifier;
  ValueNotifier<String>? _albumArtUrlNotifier;
  ValueNotifier<bool>? _isPlayingNotifier;
  ValueNotifier<Color?>? _backgroundColorNotifier;
  ValueNotifier<String>? _srcNameNotifier;
  late AudioPlayer _player;

  // Getters for ValueNotifiers
  ValueNotifier<Song>? get songInfoNotifier => _songInfoNotifier;
  ValueNotifier<String>? get albumArtUrlNotifier => _albumArtUrlNotifier;
  ValueNotifier<bool>? get isPlayingNotifier => _isPlayingNotifier;
  ValueNotifier<Color?>? get backgroundColorNotifier =>
      _backgroundColorNotifier;
  ValueNotifier<String>? get srcNameNotifier => _srcNameNotifier;
  AudioPlayer get player => _player;

  // Method to update the Notifiers
  void updateMusicSlab({
    required ValueNotifier<Song> newsongInfo,
    required ValueNotifier<String> newalbumArtUrl,
    required ValueNotifier<bool> newisPlaying,
    required ValueNotifier<Color?> newbackgroundColor,
    required ValueNotifier<String> newsrcName,
    required AudioPlayer player,
  }) {
    _songInfoNotifier = newsongInfo;
    _albumArtUrlNotifier = newalbumArtUrl;
    _isPlayingNotifier = newisPlaying;
    _backgroundColorNotifier = newbackgroundColor;
    _srcNameNotifier = newsrcName;
    _player = player;

    // Notify listeners about the update
    notifyListeners();
  }

  // Method to listen to changes
  void addListener(VoidCallback listener) {
    super.addListener(listener);
  }
}
