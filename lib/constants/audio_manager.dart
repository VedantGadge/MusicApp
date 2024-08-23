import 'package:just_audio/just_audio.dart';
import 'package:spotify_clone_app/constants/playback_state.dart';

class AudioManager {
  static final AudioPlayer player = AudioPlayer();

  // Singleton pattern
  static final AudioManager _instance = AudioManager._internal();

  factory AudioManager() {
    return _instance;
  }

  AudioManager._internal() {
    // Listen to player state changes and update the global playback state
    player.playerStateStream.listen((PlayerState state) {
      globalPlaybackState.setPlaying(state.playing);
    });
  }

  // Streams to provide current player states
  Stream<PlayerState> get playerStateStream => player.playerStateStream;
  Stream<Duration> get positionStream => player.positionStream;
  Stream<Duration?> get durationStream => player.durationStream;

  // Method to toggle play/pause
  void playPause() {
    if (player.playing) {
      player.pause();
    } else {
      player.play();
    }
  }

  // Method to set the audio source URL
  Future<void> setUrl(Uri url) async {
    await player.setAudioSource(AudioSource.uri(url));
  }

  bool get isPlaying => player.playing;
}
