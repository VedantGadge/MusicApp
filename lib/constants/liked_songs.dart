import 'package:shared_preferences/shared_preferences.dart';
import 'package:spotify_clone_app/constants/Song.dart';

class LikedSongs {
  static const _likedSongsKey = 'liked_songs';

  Future<void> addSong(Song song) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> likedSongsJson =
        prefs.getStringList(_likedSongsKey) ?? [];
    likedSongsJson.add(song.toJson());
    await prefs.setStringList(_likedSongsKey, likedSongsJson);
  }

  Future<void> removeSong(Song song) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> likedSongsJson =
        prefs.getStringList(_likedSongsKey) ?? [];
    likedSongsJson.remove(song.toJson());
    await prefs.setStringList(_likedSongsKey, likedSongsJson);
  }

  Future<List<Song>> getSongs() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> likedSongsJson =
        prefs.getStringList(_likedSongsKey) ?? [];
    return likedSongsJson.map((json) => Song.fromJson(json)).toList();
  }

  Future<bool> containsSong(Song song) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> likedSongsJson =
        prefs.getStringList(_likedSongsKey) ?? [];
    return likedSongsJson.contains(song.toJson());
  }
}
