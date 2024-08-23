import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:just_audio/just_audio.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spotify/spotify.dart' as Spotify;
import 'package:spotify_clone_app/constants/Song.dart';
import 'package:spotify_clone_app/constants/audio_manager.dart';
import 'package:spotify_clone_app/constants/clientId.dart';
import 'package:spotify_clone_app/constants/musicSlabData.dart';
import 'package:spotify_clone_app/constants/musicSlabVisibility.dart';
import 'package:spotify_clone_app/constants/playback_state.dart';
import 'package:spotify_clone_app/constants/pressEffect.dart';
import 'package:spotify_clone_app/constants/Colors.dart';
import 'package:spotify_clone_app/constants/recent_songs.dart';
import 'package:spotify_clone_app/screens/musicSlab.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class AlbumView extends StatefulWidget {
  final String title;
  final String imageUrl;
  final String desc;
  final String year;
  final List<Song> songInfo;
  final bool showTitle;

  AlbumView({
    Key? key,
    required this.title,
    required this.imageUrl,
    required this.songInfo,
    required this.desc,
    required this.year,
    required this.showTitle,
  }) : super(key: key);

  @override
  _AlbumViewState createState() => _AlbumViewState();
}

class _AlbumViewState extends State<AlbumView> {
  final AudioManager _audioManager = AudioManager();
  final player = AudioPlayer();
  Duration? duration;
  bool isLoading = true;
  late int songIndex = 0;
  late ScrollController scrollController;
  double imageSize = 0;
  double initialSize = 240;
  double imageTopMargin = 80; // Initial top margin for the image
  double minImageSize = 100; // Minimum size the image can shrink to
  double imageOpacity = 1;
  double appBarOpacity = 0;
  Color? _backgroundColor;
  late AudioPlayer _audioPlayer;
  late List<Song> _songs;
  int _currentIndex = 0;
  final RecentSongsManager _recentSongs = RecentSongsManager();
  Color darkenColor(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    int r = (color.red * (1 - amount)).toInt();
    int g = (color.green * (1 - amount)).toInt();
    int b = (color.blue * (1 - amount)).toInt();
    return Color.fromARGB(color.alpha, r, g, b);
  }

  Future<int> loadSongIndex() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('songIndex') ?? 0; // Default to 0 if not found
  }

  void _loadSong(int index) async {
    try {
      print('Loading song at index: $index');
      final songUrl = widget.songInfo[index].songUrl;
      await _audioPlayer.setUrl(songUrl);
      _audioPlayer.play();
    } catch (e) {
      print('Error loading song: $e');
    }
  }

  void _playNextSong() {
    print('Current Index: $_currentIndex');
    print('Songs Length: ${_songs.length}');
    setState(() {
      _currentIndex = (_currentIndex + 1) % _songs.length;
      _loadSong(_currentIndex);
    });
  }

  void saveSongIndex(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('songIndex', index);
  }

  @override
  void initState() {
    _audioPlayer = AudioPlayer();
    _songs = widget.songInfo;
    // Listen to the completion of the current song
    _audioPlayer.playerStateStream.listen((state) {
      print('Player State: ${state.processingState}');
      if (state.processingState == ProcessingState.completed) {
        _playNextSong();
        print('Song completed, playing next song');
      }
    });
    loadSongIndex().then((index) {
      setState(() {
        songIndex = index;
        _loadSong(songIndex);
      });
    });
    imageSize = initialSize;
    scrollController = ScrollController()
      ..addListener(() {
        double offset = scrollController.offset;
        if (offset < imageTopMargin) {
          // Image moves up with the rest of the screen
          imageOpacity = 1;
        } else {
          // Image starts shrinking and fading when it reaches the top
          double shrinkOffset = offset - imageTopMargin;
          imageSize =
              (initialSize - shrinkOffset).clamp(minImageSize, initialSize);
          imageOpacity =
              ((initialSize - shrinkOffset) / initialSize).clamp(0.0, 1.0);
        }

        // Adjust app bar opacity based on when the image reaches its minimum size
        if (imageSize == minImageSize) {
          double minSizeOffset =
              offset - (initialSize - minImageSize + imageTopMargin);
          appBarOpacity =
              minSizeOffset / 100.0; // Adjust 50.0 to control the fade-in speed
          appBarOpacity = appBarOpacity.clamp(0.0, 1.0);
        } else {
          appBarOpacity = 0;
        }

        setState(() {});
      });
    _loadPalette();
    super.initState();
  }

  Future<void> _initializePlayer() async {
    try {
      final credentials = Spotify.SpotifyApiCredentials(
          CustomStrings.clientId, CustomStrings.clientSecret);
      final spotify = Spotify.SpotifyApi(credentials);
      String? tempSongName = '';
      setState(() async {
        final track =
            await spotify.tracks.get(widget.songInfo[songIndex].songUrl);
        tempSongName = track.name;

        if (tempSongName == null) {
          throw Exception('Track name is null');
        }

        final yt = YoutubeExplode();
        final searchResults = await yt.search.search(
            "$tempSongName ${widget.songInfo[songIndex].songArtists} Lyrics");
        final video = searchResults.elementAt(1);
        duration = video.duration;
        setState(() {
          player.processingState == ProcessingState.loading ||
                  player.processingState == ProcessingState.buffering
              ? isLoading = true
              : isLoading = false;
        });
        var manifest =
            await yt.videos.streamsClient.getManifest(video.id.value);
        var audioUrl = manifest.audioOnly.first.url;
        print(audioUrl);
        _audioManager.setUrl(audioUrl);
      });
    } catch (e) {
      print("Error initializing player: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadPalette() async {
    final imageProvider = NetworkImage(widget.imageUrl);
    PaletteGenerator paletteGenerator =
        await PaletteGenerator.fromImageProvider(imageProvider);
    setState(() {
      _backgroundColor = paletteGenerator.dominantColor?.color;
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
    player.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double topPosition = (scrollController.hasClients &&
            scrollController.offset < imageTopMargin)
        ? imageTopMargin - scrollController.offset
        : 0;
    if (_backgroundColor == null) {
      return Center(
        child: SingleChildScrollView(
            controller: scrollController,
            child: const CircularProgressIndicator(
              color: Color(0xff1DB954),
              strokeWidth: 4,
            )),
      );
    }
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            SingleChildScrollView(
              controller: scrollController,
              physics: const ClampingScrollPhysics(),
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 2500,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _backgroundColor ?? const Color(0xff121212),
                      const Color(0xff121212),
                    ],
                    stops: const [0.2, 0.4],
                    begin: Alignment.topCenter,
                    end: Alignment.center,
                  ),
                ),
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: initialSize + imageTopMargin + 30),
                    albumInfo(),
                    playlistFunctions(),
                    const SizedBox(height: 30),
                    ...generateSongWidgets(context),
                  ],
                ),
              ),
            ),
            Positioned(
              top: topPosition + 20,
              left: MediaQuery.of(context).size.width / 2 - imageSize / 2,
              child: Opacity(
                opacity: imageOpacity,
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 20,
                        spreadRadius: 7.5,
                        color: Colors.black.withOpacity(0.3),
                      ),
                    ],
                  ),
                  child: CachedNetworkImage(
                    imageUrl: widget.imageUrl,
                    height: imageSize,
                    width: imageSize,
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _backgroundColor!.withOpacity(appBarOpacity),
                      darkenColor(_backgroundColor!, 0.55).withOpacity(
                        appBarOpacity < 0.3
                            ? 0
                            : appBarOpacity == 1
                                ? appBarOpacity
                                : appBarOpacity - 0.1,
                      ),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: AppBar(
                  scrolledUnderElevation: 0,
                  title: Opacity(
                    opacity: appBarOpacity,
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  backgroundColor: Colors.transparent,
                  leading: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back_outlined,
                      color: Colors.white,
                    ),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: IgnorePointer(
                child: Container(
                  height: 220,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        Colors.transparent,
                        Colors.transparent,
                        Colors.transparent,
                        Colors.transparent,
                        Colors.transparent,
                        Colors.transparent,
                        Colors.transparent,
                        Colors.transparent,
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black.withOpacity(0.02),
                        Colors.black.withOpacity(0.05),
                        Colors.black.withOpacity(0.1),
                        Colors.black.withOpacity(0.15),
                        Colors.black.withOpacity(0.2),
                        Colors.black.withOpacity(0.25),
                        Colors.black.withOpacity(0.3),
                        Colors.black.withOpacity(0.35),
                        Colors.black.withOpacity(0.4),
                        Colors.black.withOpacity(0.45),
                        Colors.black.withOpacity(0.5),
                        Colors.black.withOpacity(0.55),
                        Colors.black.withOpacity(0.6),
                        Colors.black.withOpacity(0.65),
                        Colors.black.withOpacity(0.7),
                        Colors.black.withOpacity(0.75),
                        Colors.black.withOpacity(0.8),
                        Colors.black.withOpacity(0.85),
                        Colors.black.withOpacity(0.87),
                        Colors.black.withOpacity(0.9),
                        Colors.black.withOpacity(0.92),
                        Colors.black.withOpacity(0.93),
                        Colors.black.withOpacity(0.94),
                        Colors.black.withOpacity(0.94),
                        Colors.black.withOpacity(0.95),
                        Colors.black.withOpacity(0.96),
                        Colors.black.withOpacity(0.97),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: globalSlabVisibilityState,
              builder: (context, isVisible, child) {
                return Visibility(visible: isVisible, child: MusicSlab());
              },
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> generateSongWidgets(BuildContext context) {
    List<Widget> songWidgets = [];
    for (int i = 0; i < widget.songInfo.length; i++) {
      songWidgets.add(songWidget(context, i));
    }
    return songWidgets;
  }

  Widget songWidget(BuildContext context, int index) {
    return PressableItem(
      child: InkWell(
        onTap: () async {
          setState(() {
            songIndex = index;
            saveSongIndex(songIndex);
            _recentSongs.addSong(widget.songInfo[songIndex]);
            // Initialize MusicSlabData with updated values
            MusicSlabData.instance.updateMusicSlab(
              newsongInfo: ValueNotifier(widget.songInfo[songIndex]),
              newalbumArtUrl: ValueNotifier(widget.imageUrl),
              newisPlaying: ValueNotifier(globalPlaybackState.value),
              newbackgroundColor:
                  ValueNotifier(_backgroundColor ?? Colors.transparent),
              newsrcName: ValueNotifier(widget.title),
              player: _audioPlayer,
            );
            globalSlabVisibilityState.setVisible(true);
            _initializePlayer(); // Show the music slab
          });

          print('${widget.songInfo[index].songName} button pressed');
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          width: MediaQuery.of(context).size.width,
          height: 70,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.songInfo[index].songName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      widget.songInfo[index].isExplicit
                          ? Row(
                              children: [
                                const Icon(
                                  Icons.explicit_rounded,
                                  color: Color(0xffa7a7a7),
                                  size: 17.75,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  widget.songInfo[index].songArtists,
                                  style: const TextStyle(
                                    color: Color(0xffa7a7a7),
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              widget.songInfo[index].songArtists,
                              style: const TextStyle(
                                color: Color.fromARGB(161, 255, 255, 255),
                                fontSize: 12.75,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                    ],
                  ),
                  GestureDetector(
                    child: const Icon(Icons.more_vert_rounded,
                        color: Colors.white),
                    onTap: () {
                      print('More button pressed');
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Column albumInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 5, left: 10),
          child: widget.showTitle
              ? Text(
                  widget.title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.w700),
                )
              : Padding(
                  padding: const EdgeInsets.only(left: 3),
                  child: Text(
                    widget.desc,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
        ),
        widget.showTitle
            ? Padding(
                padding: const EdgeInsets.only(left: 10, top: 5),
                child: Text(
                  widget.songInfo[0].songArtists,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700),
                ),
              )
            : const SizedBox(),
        widget.showTitle
            ? Padding(
                padding: const EdgeInsets.only(left: 10, top: 5),
                child: Text(
                  widget.showTitle ? 'Album ${widget.year}' : '',
                  style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
                      fontWeight: FontWeight.w400),
                ),
              )
            : const SizedBox(),
      ],
    );
  }

  Row playlistFunctions() {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10, top: 1, right: 7),
          child: Image.asset(
            'assets/icons/logo.png',
            height: 20,
            width: 20,
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Text(
            'Spotify',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white60,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        GestureDetector(
          child: const Padding(
            padding: EdgeInsets.only(left: 16, top: 3),
            child: Icon(
              Icons.playlist_add_rounded,
              color: Colors.white70,
              size: 25,
            ),
          ),
          onTap: () {
            print('Add to playlist button tapped');
          },
        ),
        GestureDetector(
          child: const Padding(
            padding: EdgeInsets.only(left: 16, top: 2),
            child: Icon(
              Icons.download_for_offline_outlined,
              color: Colors.white70,
              size: 25,
            ),
          ),
          onTap: () {
            print('Download button tapped');
          },
        ),
        GestureDetector(
          child: const Padding(
            padding: EdgeInsets.only(left: 16, top: 2),
            child: Icon(
              Icons.more_vert_sharp,
              color: Colors.white70,
              size: 25,
            ),
          ),
          onTap: () {
            print('More button tapped');
          },
        ),
        GestureDetector(
          child: const Padding(
            padding: EdgeInsets.only(left: 80, top: 3, right: 13),
            child: Icon(
              Icons.shuffle_rounded,
              color: Colors.white70,
              size: 25,
            ),
          ),
          onTap: () {
            final random = Random();
            int randomInt = random.nextInt(widget.songInfo.length);
            setState(() {
              songIndex = randomInt;
              saveSongIndex(songIndex);

              // Initialize MusicSlabData with updated values
              MusicSlabData.instance.updateMusicSlab(
                newsongInfo: ValueNotifier(widget.songInfo[songIndex]),
                newalbumArtUrl: ValueNotifier(widget.imageUrl),
                newisPlaying: ValueNotifier(globalPlaybackState.value),
                newbackgroundColor:
                    ValueNotifier(_backgroundColor ?? Colors.transparent),
                newsrcName: ValueNotifier(widget.title),
                player: _audioPlayer,
              );
              globalSlabVisibilityState.setVisible(true);
              _initializePlayer();
            });
          },
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8, left: 7),
          child: PressableItem(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  songIndex = 0;
                  // Initialize MusicSlabData with updated values
                  MusicSlabData.instance.updateMusicSlab(
                    newsongInfo: ValueNotifier(widget.songInfo[songIndex]),
                    newalbumArtUrl: ValueNotifier(widget.imageUrl),
                    newisPlaying: ValueNotifier(globalPlaybackState.value),
                    newbackgroundColor:
                        ValueNotifier(_backgroundColor ?? Colors.transparent),
                    newsrcName: ValueNotifier(widget.title),
                    player: _audioPlayer,
                  );
                  globalSlabVisibilityState.setVisible(true);
                  _initializePlayer(); // Show the music slab
                });
              },
              child: Container(
                width: 55,
                height: 55,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: customColors.primaryColor),
                child: const Icon(
                  Icons.play_arrow_sharp,
                  size: 37,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AudioPlayerStream extends ChangeNotifier {
  late StreamSubscription _subscription;
  late Stream<PlayerState> _playerStateStream;
  late Stream<Duration> _positionStream;
  AudioPlayerStream(
      Stream<PlayerState> playerStateStream, Stream<Duration> positionStream) {
    _playerStateStream = playerStateStream;
    _positionStream = positionStream;
    _subscription = _playerStateStream.listen((state) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  Stream<PlayerState> get playerStateStream => _playerStateStream;
  Stream<Duration> get positionStream => _positionStream;
}

class NoGlowScrollBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
