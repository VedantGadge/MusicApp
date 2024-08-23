import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:spotify_clone_app/constants/pressEffect.dart';
import 'package:spotify_clone_app/models/genres.dart';
import 'package:spotify_clone_app/screens/album.dart';
import 'package:spotify_clone_app/services/genre_operations.dart';
import 'package:spotify_clone_app/screens/genre.dart';

class SearchPage extends StatefulWidget {
  SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late List<Genres> genresList;

  @override
  void initState() {
    super.initState();
    genresList = GenreOperations.getGenres();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              decoration: const BoxDecoration(color: Color(0xff121212)),
              child: CustomScrollView(
                scrollBehavior: NoGlowScrollBehavior(),
                slivers: [
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Search',
                            style: TextStyle(
                              fontSize: 30,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.start,
                          ),
                          SizedBox(width: 260),
                          Icon(
                            Icons.camera_alt_outlined,
                            color: Colors.white,
                          )
                        ],
                      ),
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    floating: true,
                    delegate: SearchBarHeaderDelegate(),
                  ),
                  const SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 5, bottom: 4),
                          child: Text(
                            'Explore your genres',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Text(
                            'Browse all',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      childAspectRatio: 2,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        final genreInfo = genresList[index];
                        return PressableItem(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => GenreScreen(
                                    genreIndex: index,
                                    title1: genresList[index].title1,
                                    title2: genresList[index].title2,
                                    listViewImgs1:
                                        genresList[index].listViewImgs1,
                                    listViewImgs2:
                                        genresList[index].listViewImgs2,
                                    gradColor: genresList[index].bgcolor,
                                    genreName: genresList[index].genre,
                                  ),
                                ),
                              );
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: genreInfo.bgcolor,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Stack(
                                  children: [
                                    Positioned(
                                      top: 0,
                                      left: 0,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8.0, top: 12),
                                        child: Text(
                                          genreInfo.genre,
                                          style: const TextStyle(
                                            fontSize: 18.5,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      left: 133,
                                      child: Transform.rotate(
                                        angle: 0.48,
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black,
                                                blurRadius: 5,
                                              )
                                            ],
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            child: Image.asset(
                                              genreInfo.imageURL,
                                              scale: 4.2,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: genresList.length,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchBarHeaderDelegate extends SliverPersistentHeaderDelegate {
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: const Color(0xff121212),
      padding: const EdgeInsets.only(top: 5.0, bottom: 7),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'What do you want to listen to?',
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.all(11),
          hintStyle: const TextStyle(
            color: Color.fromARGB(154, 0, 0, 0),
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(11.5),
            child: SvgPicture.asset('assets/icons/search.svg'),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent => 60.0;

  @override
  double get minExtent => 60.0;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => false;
}













/*
In Flutter, slivers are the building blocks for creating intricate scrollable layouts. They offer more flexibility and control compared to standard widgets when it comes to scrolling behavior.

Here's a breakdown of each concept:

Sliver:

Represents a portion of a scrollable area.
Think of it as a slice that contributes to the overall scrolling content.
There are various built-in slivers like SliverList (for lists), SliverGrid (for grids), and SliverAppBar (for app bars).
Slivers are designed to work with CustomScrollView which manages the overall scrolling behavior.

SliverToBoxAdapter:

A specific type of sliver that acts as an adapter for a single child box widget.
It allows you to integrate a standard box widget (like Text or Row) into the scrollable area managed by slivers.
While useful for simple elements, it's generally less efficient for large datasets compared to slivers like SliverList which optimize rendering for visible items.

Delegate (SliverPersistentHeaderDelegate):

Used with SliverPersistentHeader to define the behavior of a persistent header in a scrollable view.
A delegate class specifies how the header should be built, its minimum and maximum extent (size), and how it behaves during scrolling (pinned, floating, etc.).
In the code you provided:

SliverToBoxAdapter is used to display the search title ("Search") and the search icon at the top.
SliverPersistentHeader with a custom SearchBarHeaderDelegate is used to create the search bar that remains visible while scrolling (due to the pinned: true property).
By combining different slivers and their delegates, you can achieve complex scrolling experiences with various header behaviors and content layouts.
*/