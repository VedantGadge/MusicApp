import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:spotify_clone_app/constants/Song.dart';
import 'package:spotify_clone_app/models/lyric.dart';

class LyricsPage extends StatefulWidget {
  final Song song;
  final AudioPlayer player;
  final Color bgcolor;

  const LyricsPage({
    super.key,
    required this.song,
    required this.player,
    required this.bgcolor,
  });

  @override
  State<LyricsPage> createState() => _LyricsPageState();
}

class _LyricsPageState extends State<LyricsPage> {
  List<Lyric>? lyrics;
  final ItemScrollController itemScrollController = ItemScrollController();

  @override
  void initState() {
    super.initState();

    // Listening to player's position updates to scroll lyrics
    widget.player.positionStream.listen((position) {
      _onPositionChanged(position);
    });

    // Fetching lyrics data
    get(Uri.parse(
            'https://paxsenixofc.my.id/server/getLyricsMusix.php?q=${widget.song.songName} ${widget.song.songArtists}&type=default'))
        .then((response) {
      if (response.statusCode == 200) {
        String data = response.body;
        try {
          final RegExp regExp = RegExp(r'\[(\d+:\d+\.\d+)\]\s*(.*)');

          lyrics = data.split('\n').map((line) {
            final match = regExp.firstMatch(line);
            if (match != null) {
              final timeString = match.group(1) ?? "";
              final lyricText = match.group(2) ?? "";

              // Parse timestamp and return a Lyric object
              return Lyric(
                lyricText,
                DateFormat("mm:ss.SS").parse(timeString),
              );
            } else {
              return Lyric('', DateTime(1970));
            }
          }).toList();
        } catch (e) {
          print("Error parsing lyrics: $e");
        }
        setState(() {});
      } else {
        print('Failed to load lyrics');
      }
    });
  }

  void _onPositionChanged(Duration position) {
    if (lyrics != null && lyrics!.isNotEmpty) {
      DateTime currentTime = DateTime(1970, 1, 1).copyWith(
        hour: position.inHours,
        minute: position.inMinutes.remainder(60),
        second: position.inSeconds.remainder(60),
      );

      for (int i = 0; i < lyrics!.length; i++) {
        if (lyrics![i].timeStamp.isAfter(currentTime)) {
          itemScrollController.scrollTo(
            index: i - 3 < 0 ? 0 : i - 3, // Ensure index stays valid
            duration: const Duration(milliseconds: 600),
          );
          break;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.bgcolor,
      body: lyrics != null
          ? SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0)
                    .copyWith(top: 20),
                child: ScrollablePositionedList.builder(
                  itemCount: lyrics!.length,
                  itemBuilder: (context, index) {
                    bool isCurrentLyric = lyrics![index].timeStamp.isBefore(
                        DateTime(1970, 1, 1).add(widget.player.position));
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        lyrics![index].words,
                        style: TextStyle(
                          color: isCurrentLyric ? Colors.white : Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                  itemScrollController: itemScrollController,
                ),
              ),
            )
          : const Center(
              child: CircularProgressIndicator(
                color: Colors.white38,
              ),
            ),
    );
  }
}
