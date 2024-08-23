import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:spotify_clone_app/constants/Song.dart';
import 'package:spotify_clone_app/constants/audio_manager.dart';
import 'package:spotify_clone_app/constants/musicSlabData.dart';
import 'package:spotify_clone_app/constants/playback_state.dart';
import 'package:spotify_clone_app/constants/pressEffect.dart';
import 'package:spotify_clone_app/screens/musicPlayer.dart';

class MusicSlab extends StatelessWidget {
  // Access the singleton instance of MusicSlabData
  final MusicSlabData musicSlabData = MusicSlabData.instance;

  MusicSlab({super.key});

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<Song> songInfoNotifier =
        musicSlabData.songInfoNotifier!;
    final ValueNotifier<String> albumArtUrlNotifier =
        musicSlabData.albumArtUrlNotifier!;
    final ValueNotifier<Color?> backgroundColorNotifier =
        musicSlabData.backgroundColorNotifier!;
    final ValueNotifier<String> srcNameNotifier =
        musicSlabData.srcNameNotifier!;
    final AudioPlayer player = musicSlabData.player;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 60,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: PressableItem(
          child: GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                isDismissible: true,
                enableDrag: true,
                useSafeArea: true,
                builder: (context) => Musicplayer(
                  songBgColor:
                      backgroundColorNotifier.value ?? const Color(0xff121212),
                  srcName: srcNameNotifier.value,
                  imgUrl: albumArtUrlNotifier.value,
                  song: songInfoNotifier.value,
                  player: player,
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: ValueListenableBuilder<Color?>(
                valueListenable: backgroundColorNotifier,
                builder: (context, backgroundColor, child) {
                  return Container(
                    color: backgroundColor ??
                        const Color(0xff121212), // Fallback color
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(5),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: SizedBox(
                                  height: 45,
                                  child: ValueListenableBuilder<String>(
                                    valueListenable: albumArtUrlNotifier,
                                    builder: (context, albumArtUrl, child) {
                                      return CachedNetworkImage(
                                        imageUrl: albumArtUrl,
                                        placeholder: (context, url) =>
                                            const CircularProgressIndicator(),
                                        errorWidget: (context, url, error) =>
                                            const Icon(Icons.error),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: ValueListenableBuilder<Song>(
                                      valueListenable: songInfoNotifier,
                                      builder: (context, songInfo, child) {
                                        return Text(
                                          songInfo.songName,
                                          style: const TextStyle(
                                              color: Colors.white),
                                          overflow: TextOverflow.ellipsis,
                                        );
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: ValueListenableBuilder<Song>(
                                      valueListenable: songInfoNotifier,
                                      builder: (context, songInfo, child) {
                                        return Text(
                                          songInfo.songArtists,
                                          style: const TextStyle(
                                              color: Color(0xffa7a7a7)),
                                          overflow: TextOverflow.ellipsis,
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            _buildControls(),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: _buildProgressBar(),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
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
              icon: Icon(
                isPlaying ? Icons.pause_outlined : Icons.play_arrow_sharp,
                size: 28,
              ),
              color: Colors.white,
              onPressed: () async {
                final AudioManager _audioManager = AudioManager();
                _audioManager.playPause();
                globalPlaybackState.setPlaying(!isPlaying);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildProgressBar() {
    final AudioManager _audioManager = AudioManager();
    return Stack(
      children: [
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
        StreamBuilder<Duration?>(
          stream: _audioManager.durationStream,
          builder: (context, durationSnapshot) {
            final duration = durationSnapshot.data;
            return StreamBuilder<Duration>(
              stream: _audioManager.positionStream,
              builder: (context, positionSnapshot) {
                final position = positionSnapshot.data ?? Duration.zero;

                if (duration == null || duration.inMilliseconds == 0) {
                  return Container(height: 2);
                }

                double sliderValue =
                    position.inMilliseconds / duration.inMilliseconds;

                return Container(
                  height: 2,
                  width: sliderValue * (MediaQuery.of(context).size.width - 32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(7),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
