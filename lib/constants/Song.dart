import 'dart:convert';

class Song {
  String songUrl;
  String songName;
  String songArtists;
  bool isExplicit;

  Song(this.songUrl, this.songName, this.songArtists, this.isExplicit);

  // Convert a Song object into a Map object
  Map<String, dynamic> toMap() {
    return {
      'songUrl': songUrl,
      'songName': songName,
      'songArtists': songArtists,
      'isExplicit': isExplicit,
    };
  }

  // Extract a Song object from a Map object
  factory Song.fromMap(Map<String, dynamic> map) {
    return Song(
      map['songUrl'] ?? '',
      map['songName'] ?? '',
      map['songArtists'] ?? '',
      map['isExplicit'] ?? false,
    );
  }

  // Convert a Song object into a JSON string
  String toJson() => json.encode(toMap());

  // Convert a JSON string into a Song object
  factory Song.fromJson(String source) => Song.fromMap(json.decode(source));
}
