import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:spotify/spotify.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:spotify_clone_app/constants/Song.dart';
import 'package:spotify_clone_app/constants/audio_manager.dart';
import 'package:spotify_clone_app/constants/clientId.dart';
import 'package:spotify_clone_app/constants/playback_state.dart';
import 'package:spotify_clone_app/screens/lyricsSection.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:spotify_clone_app/constants/colors.dart';
import 'package:spotify_clone_app/constants/liked_songs.dart';

class Musicplayer extends StatefulWidget {
  final Color songBgColor;
  final String srcName;
  final String imgUrl;
  final Song song;
  final AudioPlayer player;
  const Musicplayer({
    Key? key,
    required this.songBgColor,
    required this.srcName,
    required this.imgUrl,
    required this.song,
    required this.player,
  }) : super(key: key);

  @override
  State<Musicplayer> createState() => _MusicplayerState();
}

class _MusicplayerState extends State<Musicplayer> {
  final AudioManager _audioManager = AudioManager();
  Duration? duration;
  bool isLoading = true;
  bool isLiked = false;
  final LikedSongs _likedSongs =
      LikedSongs(); // Added state variable for liked status

  @override
  void initState() {
    super.initState();
    _initializePlayer();
    _initializeLikedStatus(); // Initialize the liked status
    AudioManager.player.playerStateStream.listen((state) {
      print('Player State: ${state.processingState}');
      if (state.processingState == ProcessingState.completed) {
        print('Song completed, playing next song');
      }
    });
  }

  Future<void> _initializePlayer() async {
    try {
      final credentials = SpotifyApiCredentials(
          CustomStrings.clientId, CustomStrings.clientSecret);
      final spotify = SpotifyApi(credentials);

      final track = await spotify.tracks.get(widget.song.songUrl);
      String? tempSongName = track.name;

      if (tempSongName == null) {
        throw Exception('Track name is null');
      }

      final yt = YoutubeExplode();
      final searchResults = await yt.search
          .search("$tempSongName ${widget.song.songArtists} Lyrics");
      final video = searchResults.elementAt(1);
      duration = video.duration;
      setState(() {
        AudioManager.player.processingState == ProcessingState.loading ||
                AudioManager.player.processingState == ProcessingState.buffering
            ? isLoading = true
            : isLoading = false;
      });
    } catch (e) {
      print("Error initializing player: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  // New method to initialize the liked status
  Future<void> _initializeLikedStatus() async {
    final liked = await _likedSongs.containsSong(widget.song);
    setState(() {
      isLiked = liked;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.songBgColor,
      body: DraggableScrollableSheet(
        initialChildSize: 1,
        minChildSize: 0.9,
        shouldCloseOnMinExtent: true,
        builder: (BuildContext context, ScrollController scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 850,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    widget.songBgColor,
                    widget.songBgColor,
                    widget.songBgColor,
                    widget.songBgColor,
                    widget.songBgColor,
                    widget.songBgColor,
                    const Color(0xff121212),
                    const Color(0xff121212),
                    const Color(0xff121212),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    _buildTopBar(context),
                    const SizedBox(height: 60),
                    _buildAlbumArt(),
                    const SizedBox(height: 60),
                    _buildSongInfo(),
                    const SizedBox(height: 10),
                    _buildProgressBar(),
                    _buildControls(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(
              Icons.arrow_downward_rounded,
              color: Colors.white,
              size: 25,
            ),
          ),
        ),
        Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 15.0),
              child: Text(
                'Playing Now',
                style:
                    TextStyle(color: customColors.primaryColor, fontSize: 15),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 3.0),
              child: Text(
                'from "${widget.srcName}" playlist',
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontSize: 15),
              ),
            )
          ],
        ),
        const Padding(
          padding: EdgeInsets.only(top: 10.0),
          child: Icon(
            Icons.more_vert_sharp,
            color: Colors.white,
            size: 25,
          ),
        ),
      ],
    );
  }

  Widget _buildAlbumArt() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: CachedNetworkImage(
        imageUrl: widget.imgUrl,
        height: 365,
        width: 365,
      ),
    );
  }

  Widget _buildSongInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.song.songName,
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 25,
                  color: Colors.white),
            ),
            Text(
              widget.song.songArtists,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 17,
                color: Color(0xffa7a7a7),
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () async {
            setState(() {
              if (isLiked) {
                _likedSongs.removeSong(widget.song);
              } else {
                _likedSongs.addSong(widget.song);
              }
              isLiked = !isLiked;
            });
          },
          child: Icon(
            isLiked ? Icons.favorite : Icons.favorite_border,
            color: customColors.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        StreamBuilder<Duration>(
          stream: _audioManager.positionStream,
          builder: (context, snapshot) {
            final position = snapshot.data ?? Duration.zero;
            return ProgressBar(
              progress: position,
              buffered: const Duration(milliseconds: 2000),
              total: duration ?? const Duration(minutes: 4),
              bufferedBarColor: Colors.transparent,
              baseBarColor: Colors.white10,
              thumbColor: Colors.white,
              thumbGlowColor: Colors.transparent,
              progressBarColor: Colors.white,
              thumbRadius: 5,
              timeLabelPadding: 5,
              timeLabelTextStyle: const TextStyle(
                color: Colors.white54,
                fontSize: 13,
                fontFamily: "Circular",
                fontWeight: FontWeight.w400,
              ),
              onSeek: (newDuration) {
                AudioManager.player.seek(newDuration);
              },
            );
          },
        ),
        StreamBuilder<PlayerState>(
          stream: _audioManager.playerStateStream,
          builder: (context, snapshot) {
            final processingState = snapshot.data?.processingState;
            if (processingState == ProcessingState.loading ||
                processingState == ProcessingState.buffering) {
              return Container(
                height: 2,
                child: const LinearProgressIndicator(
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white60),
                ),
              );
            }
            return Container();
          },
        ),
      ],
    );
  }

  Widget _buildControls() {
    return ValueListenableBuilder<bool>(
      valueListenable: globalPlaybackState,
      builder: (context, isPlaying, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.shuffle_rounded),
              color: Colors.white,
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.skip_previous_rounded, size: 40),
              color: Colors.white,
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(
                isPlaying
                    ? Icons.pause_circle_filled_sharp
                    : Icons.play_circle_fill_rounded,
                size: 75,
              ),
              color: Colors.white,
              onPressed: () async {
                _audioManager.playPause();
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.skip_next_rounded,
                size: 40,
              ),
              color: Colors.white,
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(
                Icons.lyrics_outlined,
              ),
              color: Colors.white,
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LyricsPage(
                        song: widget.song,
                        player: widget.player,
                        bgcolor: widget.songBgColor,
                      ),
                    ));
              },
            ),
          ],
        );
      },
    );
  }
}
