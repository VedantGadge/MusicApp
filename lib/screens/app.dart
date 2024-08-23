import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:spotify_clone_app/constants/musicSlabData.dart';
import 'package:spotify_clone_app/constants/musicSlabVisibility.dart';
import 'package:spotify_clone_app/constants/pressEffect.dart';
import 'package:spotify_clone_app/screens/home.dart';
import 'package:spotify_clone_app/screens/library.dart';
import 'package:spotify_clone_app/screens/musicSlab.dart';
import 'package:spotify_clone_app/screens/search.dart';

class MainApp extends StatefulWidget {
  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _selectedIndex = 0;
  void _updatePlaybackState() {
    // Trigger a rebuild when MusicSlab data state changes
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    MusicSlabData.instance.addListener(_updatePlaybackState);
  }

  @override
  void dispose() {
    MusicSlabData.instance.removeListener(_updatePlaybackState);
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> tabs = [
    const HomePage(),
    SearchPage(),
    const LibraryPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: tabs[_selectedIndex],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 80,
            child: ValueListenableBuilder<bool>(
              valueListenable: globalSlabVisibilityState,
              builder: (context, isVisible, child) {
                return Visibility(visible: isVisible, child: MusicSlab());
              },
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 80,
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
                    Colors.black.withOpacity(0.94),
                    Colors.black.withOpacity(0.95),
                    Colors.black.withOpacity(0.95),
                    Colors.black.withOpacity(0.95),
                    Colors.black.withOpacity(0.96),
                    Colors.black.withOpacity(0.97),
                    Colors.black.withOpacity(0.97),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: BottomNavigationBar(
                items: [
                  BottomNavigationBarItem(
                    icon: PressableItem(
                      child: SvgPicture.asset(
                        _selectedIndex == 0
                            ? 'assets/icons/home_alt.svg'
                            : 'assets/icons/home.svg',
                        height: 30,
                        color: Colors.white,
                      ),
                      onTap: () => _onItemTapped(0),
                    ),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: PressableItem(
                      child: SvgPicture.asset(
                        _selectedIndex == 1
                            ? 'assets/icons/search_alt.svg'
                            : 'assets/icons/search.svg',
                        height: 30,
                        color: Colors.white,
                      ),
                      onTap: () => _onItemTapped(1),
                    ),
                    label: 'Search',
                  ),
                  BottomNavigationBarItem(
                    icon: PressableItem(
                      child: SvgPicture.asset(
                        'assets/icons/library.svg',
                        height: 30,
                        color: Colors.white,
                      ),
                      onTap: () => _onItemTapped(2),
                    ),
                    label: 'Your Library',
                  ),
                ],
                backgroundColor: Colors.transparent,
                currentIndex: _selectedIndex,
                selectedItemColor: Colors.white,
                unselectedItemColor: Colors.white54,
                selectedFontSize: 12,
                unselectedFontSize: 12,
                onTap: _onItemTapped,
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
