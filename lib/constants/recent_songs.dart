import 'dart:convert'; // For JSON encoding/decoding
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spotify_clone_app/constants/Song.dart';

class RecentSongsManager {
  static const _recentSongsKey = 'recent_songs';

  // Add a song to the recent songs list
  Future<void> addSong(Song song) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> recentSongsJson =
        prefs.getStringList(_recentSongsKey) ?? [];

    final String songJson = jsonEncode(song.toJson());

    // If the song is already in the list, remove it
    if (recentSongsJson.contains(songJson)) {
      recentSongsJson.remove(songJson);
    }

    // Add the song to the beginning of the list
    recentSongsJson.insert(0, songJson);

    // Keep only the 10 most recent songs
    if (recentSongsJson.length > 20) {
      recentSongsJson.removeRange(20, recentSongsJson.length);
    }

    await prefs.setStringList(_recentSongsKey, recentSongsJson);
  }

  // Get the list of recent songs
  Future<List<Song>> getRecentSongs() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> recentSongsJson =
        prefs.getStringList(_recentSongsKey) ?? [];

    // Convert each JSON string back to a Song object
    return recentSongsJson
        .map((json) => Song.fromJson(jsonDecode(json)))
        .toList();
  }
}
