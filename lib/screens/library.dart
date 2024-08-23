import 'package:flutter/material.dart';
import 'package:spotify_clone_app/constants/Song.dart';
import 'package:spotify_clone_app/constants/liked_songs.dart';
import 'package:spotify_clone_app/constants/musicSlabData.dart';
import 'package:spotify_clone_app/screens/album.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  _LibraryPageState createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  List<Song> likedSongs = [];

  @override
  void initState() {
    MusicSlabData.instance.addListener(_updatePlaybackState);
    super.initState();
    _loadLikedSongs();
  }

  void _updatePlaybackState() {
    // Trigger a rebuild when MusicSlab data state changes
    setState(() {});
  }

  Future<void> _loadLikedSongs() async {
    final likedSongsFromPrefs = await LikedSongs().getSongs();
    setState(() {
      likedSongs = likedSongsFromPrefs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ScrollConfiguration(
            behavior: NoGlowScrollBehavior(),
            child: SingleChildScrollView(
              child: SafeArea(
                child: Container(
                  height: 1000,
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: const BoxDecoration(
                    color: Color(0xff121212),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20, left: 10),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AlbumView(
                                    title: 'Liked Songs',
                                    imageUrl:
                                        'https://i1.sndcdn.com/artworks-y6qitUuZoS6y8LQo-5s2pPA-t500x500.jpg',
                                    songInfo: likedSongs,
                                    desc: 'Your liked songs',
                                    year: '2024',
                                    showTitle: false,
                                  ),
                                ));
                          },
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/icons/LikedSongs.jpg',
                                scale: 10,
                              ),
                              const Padding(
                                padding: EdgeInsets.only(left: 10),
                                child: Text(
                                  'Liked Songs',
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(left: 15, top: 15, bottom: 10),
          child: Text(
            'Your Library',
            style: TextStyle(
                color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: const Color(0xff121212),
      ),
    );
  }
}
