import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:spotify_clone_app/constants/Song.dart';
import 'package:spotify_clone_app/constants/musicSlabData.dart';
import 'package:spotify_clone_app/constants/pressEffect.dart';
import 'package:spotify_clone_app/constants/recent_songs.dart';
import 'package:spotify_clone_app/models/category.dart';
import 'package:spotify_clone_app/models/musicList.dart';
import 'package:spotify_clone_app/screens/album.dart';
import 'package:spotify_clone_app/services/category_operations.dart';
import 'package:spotify_clone_app/services/musicList_operations1.dart';
import 'package:spotify_clone_app/services/musicList_operations2.dart';
import 'package:spotify_clone_app/services/musicList_operations2b.dart';
import 'package:spotify_clone_app/services/musicList_operations3.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<Category> categoryList;
  late List<MusicList> musicList1;
  late List<MusicList> musicList2;
  late List<MusicList> musicList3;
  late List<MusicList> musicList2b;
  List<Song> recentSongs = [];

  void _updatePlaybackState() async {
    final recentSongsFromPrefs = await RecentSongsManager().getRecentSongs();
    // Trigger a rebuild when MusicSlab data state changes
    setState(() {
      recentSongs = recentSongsFromPrefs;
    });
  }

  Future<void> _loadRecentSongs() async {
    final recentSongsFromPrefs = await RecentSongsManager().getRecentSongs();
    setState(() {
      recentSongs = recentSongsFromPrefs;
    });
  }

  @override
  void initState() {
    super.initState();
    // Initialize your data fetching or any other initialization here
    MusicSlabData.instance.addListener(_updatePlaybackState);
    categoryList = CategoryOperations.getCategories();
    musicList1 = MusiclistOperations1.getMusic1();
    musicList2 = MusiclistOperations2.getMusic2();
    musicList3 = MusiclistOperations3.getMusic3();
    musicList2b = MusiclistOperations2b.getMusic2b();
    _loadRecentSongs();
  }

  @override
  void dispose() {
    MusicSlabData.instance.removeListener(_updatePlaybackState);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            ScrollConfiguration(
              behavior: NoOverscrollGlowBehavior(),
              child: SingleChildScrollView(
                child: SafeArea(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: const BoxDecoration(
                      color: Color(0xff121212),
                    ),
                    child: Column(
                      children: [
                        _appBar(), // Custom app bar widget
                        const SizedBox(height: 5),
                        createGrid(context), // Grid of categories
                        const SizedBox(height: 5),
                        createMusicList2b(context),
                        const SizedBox(height: 5),
                        createMusicList1(context), // First list of music
                        const SizedBox(height: 5),
                        createMusicList2(context), // Second  list of music
                        const SizedBox(height: 5),
                        createMusicList3(context), // Third list of music
                      ],
                    ),
                  ),
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
          ],
        ),
      ),
    );
  }

  // Custom app bar with dynamic greeting based on time of day
  AppBar _appBar() {
    return AppBar(
      title: Container(
        padding: const EdgeInsets.only(top: 8.0),
        child: Text(
          (DateTime.now().hour >= 5 && DateTime.now().hour <= 12
              ? 'Good morning'
              : (DateTime.now().hour >= 12 && DateTime.now().hour <= 17
                  ? 'Good afternoon'
                  : (DateTime.now().hour >= 17 && DateTime.now().hour <= 21
                      ? 'Good evening'
                      : 'Good night'))),
          style: const TextStyle(
            fontFamily: 'Circular',
            fontWeight: FontWeight.w700,
            fontSize: 25,
            color: Colors.white,
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 15),
          child: Container(
            height: 27,
            width: 27,
            child: SvgPicture.asset('assets/icons/gear.svg'),
          ),
        )
      ],
      backgroundColor: Colors.transparent, // Transparent app bar background
    );
  }

  // Create a category widget with a gesture detector for navigation
  Widget createCategory(BuildContext context, Category category, int index) {
    return PressableItem(
      child: GestureDetector(
        onTap: () {
          List<Song> songs;
          switch (index) {
            case 0:
              songs = [
                Song("1YMLgvsQdE27r30q0fsLeV", "Tera Fitoor", 'Arijit Singh',
                    false),
                Song("4nc6XiUze2Yh7wFueGOPv7", "Chaleya",
                    'Arijit Singh,Shilpa Rao', false),
                Song("3MVPReTwLNOBFb6KjiIRNM", "Kabhi Jo Baadal Barse",
                    'Arijit Singh', false),
                Song("4blqlsA1uf2d2I40E90EUC", "Tere Hawale",
                    'Arijit Singh,Pritam,Shilpa Rao', false),
                Song("6FjbAnaPRPwiP3sciEYctO", "Raabta", 'Arijit Singh,Pritam',
                    false),
                Song("0WdbnNKO0Jt4BZACSDQh44", "Ghungroo",
                    'Arijit Singh,Shilpa Rao', false),
                Song("1J9vyEntJ79CppvgUxJs75", "Zaalima",
                    'Arijit Singh,Harshdeep Kaur', false),
                Song("6UgcN95w7vQxkR8sEFmwHG", "Chahun Main Ya Naa",
                    'Arijit Singh,Palak Muchhal', false),
                Song("5cgKosPPj5Cs9a2JQufUc1", "Ilahi", 'Arijit Singh,Pritam',
                    false),
                Song(
                    "2sryZMs4aLRCLbXiOl69lP",
                    "Main Rang Sharabton Ka - Reprise",
                    'Arijit Singh,Pritam',
                    false),
                Song("0EZTe2i9yDYsYVO1YNEVZf", "Shaayraana",
                    'Arijit Singh,Pritam', false),
                Song("2b2HutIDmoeBnnKRWDLAtV", "Phir Mohabbat",
                    'Arijit Singh,Mohammed Irfan,Saim Bhat', false),
                Song("3oNVqllTnz7bHrY3f0nICg", "Phir Bhi Tumko Chaahunga",
                    'Arijit Singh,Mithoon,Shashaa Tirupati', false),
              ];
              break;
            case 1:
              songs = [
                Song("42VsgItocQwOQC3XWZ8JNA", "FE!N",
                    "Travis Scott, Playboi Carti", true),
                Song("04WxWo7XeVyx22xEsrWRUb", "GOD'S COUNTRY", "Travis Scott",
                    true),
                Song("4kjI1gwQZRKNDkw1nI475M", "MY EYES", "Travis Scott", true),
                Song("0hL9gOw6XBWsygEUcVjxEc", "HYAENA", "Travis Scott", true),
                Song("0lodMO0qK83vfPiiD7FMEt", "TOPIA TWINS",
                    "Travis Scott, Rob49, 21 Savage", true),
                Song("4GL9GMX9t7Qkprvf1YighZ", "CIRCUS MAXIMUS",
                    "Travis Scott, The Weeknd, Swae Lee", true),
                Song("5L3ecxQnQ9qTBmnLQiwf0C", "K-POP",
                    "Travis Scott, Bad Bunny, The Weeknd", true),
              ];
              break;
            case 2:
              songs = [
                Song("2gNMXJDKRmKWuevBGjN8wo", "3:59", "DIVINE", true),
                Song("1xSCr5uIndaHKFdO4s2V6B", "Satya", "DIVINE", true),
                Song("3zIhQR5cyxpVn8WpEivBCr", "Punya Paap", "DIVINE", false),
                Song("7zKzD5wM18bQSiJTAxTpwH", "Mirchi",
                    "DIVINE, MC Altaf, Stylo G", false),
                Song("1T44wPr7LUlBY4vX6LlygG", "Baazigar",
                    "DIVINE, Armani White", true),
                Song("66qAXPAHwLKPLi8Gx58x5z", "Drill Karte",
                    "DIVINE, dutchavelli", false),
                Song("6Kynli1iHBqJRWUCohcV9h", "Kaam 25 - Sacred Games",
                    "DIVINE", false),
              ];
              break;
            case 3:
              songs = [
                Song("6AI3ezQ4o3HUoP6Dhudph3", "Not Like Us", "Kendrick Lamar",
                    true),
                Song("3QFInJAm9eyaho5vBzxInN", "family ties",
                    "Kendrick Lamar, Baby Keem", true),
                Song("7KXjTSCq5nL1LoYtL7XAwS", "HUMBLE.", "Kendrick Lamar",
                    true),
                Song("2tudvzsrR56uom6smgOcSf", "Like That",
                    "Kendrick Lamar, Future, Metro Boomin", true),
                Song("6huNf4dutXRjJyGn7f5BPS", "Pray For Me",
                    "Kendrick Lamar, The Weeknd", true),
                Song("5o3GnrcFtvkdf3zFznuSbA", "Don't Wanna Know",
                    "Kendrick Lamar, Maroon 5", false),
                Song("3MLOAIJNWWS8FQpvdaiKR7", "Poetic Justice",
                    "Kendrick Lamar, Drake", true),
              ];
              break;
            case 4:
              songs = [
                Song("7qiZfU4dY1lWllzX7mPBI3", "Shape Of You", "Ed Sheeran",
                    false),
                Song("0tgVpDi06FyKpA1z0VMD4v", "Perfect", "Ed Sheeran", false),
                Song("7oolFzHipTMg2nL7shhdz2", "Eraser", "Ed Sheeran", false),
                Song("2RttW7RAu5nOAfq6YFvApB", "Happier", "Ed Sheeran", false),
                Song("2pJZ1v8HezrAoZ0Fhzby92", "What Do I Know?", "Ed Sheeran",
                    false),
                Song("1nHKI4L5pWrN5CUvW07nHP", "Let Her Go",
                    "Ed Sheeran, Passenger", false),
                Song("6PCUP3dWmTjcTtXY02oFdT", "Castle on the Hill",
                    "Ed Sheeran", false),
              ];
              break;
            case 5:
              songs = [
                Song("7MXVkk9YMctZqd1Srtv4MB", "Starboy", "The Weeknd", false),
                Song("2Ch7LmS7r2Gy2kc64wv3Bz", "Die For You", "The Weeknd",
                    false),
                Song("36YCdzT57us0LhDmCYtrNE", "Rockin'", "The Weeknd", false),
                Song("0VjIjW4GlUZAMYd2vXMi3b", "Blinding Lights", "The Weeknd",
                    false),
                Song("4EDijkJdHBZZ0GwJ12iTAj", "Stargirl Interlude",
                    "The Weeknd, Lana Del Ray", false),
                Song("3dhjNA0jGA8vHBQ1VdD6vV", "I Feel It Coming",
                    "The Weeknd, Daft Punk", false),
                Song("4F7A0DXBrmUAkp32uenhZt", "Party Monster", "The Weeknd",
                    false),
              ];
              break;
            default:
              songs = [Song("default_url1", "", "", false)];
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AlbumView(
                title: category.name,
                imageUrl: category.imageURL,
                songInfo: songs,
                desc: category.desc,
                year: category.year,
                showTitle: category.showTitle,
              ),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xff2a2a2a),
            borderRadius: BorderRadius.circular(4), // Rounded corners
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.horizontal(left: Radius.circular(3)),
                child: CachedNetworkImage(
                  imageUrl: category.imageURL,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const SizedBox(width: 58.5),
                ), // Category image
              ),
              const SizedBox(width: 7),
              Flexible(
                //The Flexible widget is used here to make sure the text wraps within the available space.
                child: Text(
                  category.name, // Category name
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow:
                      TextOverflow.ellipsis, // Ellipsis if text is too long
                  maxLines: 2, // Allow text to wrap to the next line
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Create a list of category widgets
  List<Widget> createListOfCategories(BuildContext context) {
    return categoryList.asMap().entries.map((entry) {
      int index = entry.key;
      Category category = entry.value;
      return createCategory(context, category, index);
    }).toList();
  }
/* => categoryList.asMap().entries creates an iterable of entries where each entry is a key-value pair of index and category.
   => entry.key provides the index.
   => entry.value provides the category.
   => createCategory(context, category, index) is called with the appropriate index for each category.
*/

  // Create a grid view of categories
  Widget createGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 9.0),
      child: Container(
        height: 200,
        width: 380,
        child: GridView.count(
          childAspectRatio: 7 / 2.2, // Aspect ratio for grid items
          crossAxisSpacing: 7,
          mainAxisSpacing: 7,
          crossAxisCount: 2, // Number of columns
          physics: const NeverScrollableScrollPhysics(), // Disable scrolling
          children: createListOfCategories(context), // Add category widgets
        ),
      ),
    );
  }

  Widget madeFor2b(BuildContext context, MusicList music, int index) {
    return PressableItem(
      child: GestureDetector(
        onTap: () {
          List<Song> songs;
          switch (index) {
            case 0:
              songs = [
                Song("7F8RNvTQlvbeBLeenycvN6", "Kun Faya Kun",
                    "Javed Ali, Mohit Chauhan", false),
                Song("7eQl3Yqv35ioqUfveKHitE", "Tum Se Hi",
                    "Pritam, Mohit Chauhan", false),
                Song("6GQK4G5o60E8YA18DGpAzv", "Hale Dil", "Harshit Saxena",
                    false),
                Song("0pPGUL7171TRGgI6wyP8wP", "Tumhe Jo Maine Dekha",
                    "Abijeet, Shreya Ghoshal", false),
                Song("5ZLkihi6DVsHwDL3B8ym1t", "One Love", "Shubh", false),
                Song("0FBQ4NrrHUbR9kus7rzrOj", "Dil Diyan Gallan", "Atif Aslim",
                    false),
                Song("3MVPReTwLNOBFb6KjiIRNM", "Kabhi Jo Badal Barse",
                    "Arijit Singh", false),
                Song("3HFjh7QljnUCBLsoTwMuTj", "Kya Mujhe Pyaar Hai", "KK",
                    false),
                Song("4bD9z9qa4qg9BhryvYWB7c", "Kabira", "Pritam", false),
                Song("17opN752ZQpNuoptelsNQ1", "Pehli Nazar Main",
                    "Atif Aslam. Pritam", false),
                Song("52itZ0w0CydihB2JCZEIft", "Pee Loon",
                    "Pritam, Mohit Chuhan", false),
                Song("1QufGJee7k9v4Cfp2NxXbv", "Abhi Kuch Dino Se",
                    "Pritam , Mohit Chauhan", false),
                Song("1hQia6rxgfM1ly2hE3StWp", "Ishq Vala Love",
                    "Vishal-Shekhar", false),
              ];
              break;

            case 0:
              songs = [
                Song("6RUKPb4LETWmmr3iAEQktW", "Something Just Like This",
                    "Coldplay, The Chainsmokers", false),
                Song("1mea3bSkSGXuIRvnydlB5b", "Viva La Vida", "Coldplay",
                    false),
                Song("3AJwUDP919kvQ9QcozQPxg", "Yellow", "Coldplay", false),
                Song("0FDzzruyVECATHXKHFs9eJ", "A Sky Full of Stars",
                    "Coldplay", false),
                Song("75JFxkI2RXiU7L9VXzMkle", "The Scientist", "Coldplay",
                    false),
                Song("3RiPr603aXAoi4GHyXx0uy", "Hymn for the Weekend",
                    "Coldplay", false),
                Song("6nek1Nin9q48AVZcWs9e9D", "Paradise", "Coldplay", false),
                Song("7LVHVU3tWfcxj5aiPFEW4Q", "Fix You", "Coldplay", false),
              ];
              break;
            case 1:
              songs = [
                Song("5SjfjoYaRJ5jycgqwV0ow0", "Scars", "Keenan Te", false),
                Song("2ap6qvIIBQ5BomjRrBJyer", "Never Let You Go", "Keenan Te",
                    false),
                Song("6H9UUMwRcnyhhYLJvSRgI2", "Dependant", "Keenan Te", false),
                Song("5WJtuMqSdxcbuNvouacT37", "Forget About Us", "Keenan Te",
                    false),
                Song("2gZebZcW1mUWoZoJmTE6pr", "Mine", "Keenan Te", false),
                Song(
                    "1hH4syeWdhmTv9dAVxUIqp", "Unlearn You", "Keenan Te", false)
              ];

              break;
            case 2:
              songs = [
                Song("47BBI51FKFwOMlIiX6m8ya", "I Want It That Way",
                    "Backstreet Boys", false),
                Song(
                    "1di1BEgJYzPvXUuinsYJGP",
                    "Everybody (Backstreet's Back) - Radio Edit",
                    "Backstreet Boys",
                    false),
                Song("3UpS7kBnkVQYG13pDDFTC4", "As Long as You Love Me",
                    "Backstreet Boys", false),
                Song("35o9a4iAfLl5jRmqMX9c1D", "Shape of My Heart",
                    "Backstreet Boys", false),
                Song(
                    "0Uqs7ilt5kGX9NzFDWTBrP",
                    "Quit Playing Games (With My Heart)",
                    "Backstreet Boys",
                    false),
                Song("6sbXGUn9V9ZaLwLdOfpKRE", "Larger Than Life",
                    "Backstreet Boys", false),
              ];
              break;
            case 3:
              songs = [
                Song("1ax8ZuwRVkSdzzsIqyCNWQ", "Tumse Milke Dil Ka",
                    "Sonu Nigam", false),
                Song("3WVHfTd7xz9VPYJQFpOp8j", "Main Agar Kahoon",
                    "Sonu Nigam, Shreya Ghoshal", false),
                Song("251PNRmJU9KcUnFQAB5t6I", "Kal Ho Naa Ho",
                    "Sonu Nigam. Shankar-Ehsaan-Loy", false),
                Song("6cUaCs1lKfDOyFKMkBF8ch", "Dil Dooba",
                    "Sonu Nigam, Shreya Ghoshal", false),
                Song("4J5OpeZUR2msDPfMsIeGSU", "Soniyo",
                    "Sonu Nigam, Raju Singh, Shreya Ghoshal", false),
                Song("73y649QhnXdcm6fRdvfraO", "Abhi Mujh Mein Kahin",
                    "Sonu Nigam, Ajay-Atul", false),
              ];
              break;
            case 4:
              songs = [
                Song("0TL0LFcwIBF5eX7arDIKxY", "Husn", "Anuv Jain", false),
                Song(
                    "3WLJ7D5kh44K5eJ1NqZQ6W", "Baarishein", "Anuv Jain", false),
                Song("3bQsp4Vr9Rg4fNCx6HPOgX", "Alag Aasmaan", "Anuv Jain",
                    false),
                Song("6ivemTXTn27PwVjtd0oqDs", "Gul", "Anuv Jain", false),
                Song("6P1pBAEUoHwRMToeVoTPrg", "Mishri", "Anuv Jain", false),
                Song("0uBo93xl23O60oErtKvSAg", "Mazaak", "Anuv Jain", false),
              ];
              break;
            case 5:
              songs = [
                Song("4BiPsAV070dg3eLSVf727A", "Ye Ishq Hai", "Shreya Ghoshal",
                    false),
                Song("3t3wsY5IdLVzB9WidegJSU", "Jeene Laga Hoon",
                    "Shreya Ghoshal", false),
                Song("4ZVfIGaZP93t0stmBj4FqA", "Teri Yaadon Mein",
                    "Shreya Ghoshal ", false),
                Song("0pPGUL7171TRGgI6wyP8wP", "Tumhe Jo Main Dekha",
                    "Shreya Ghoshal", false),
                Song("0fCQRUbk8LIQTdQYGNtGyv", "Tere Liye", "Shreya Ghoshal",
                    false),
                Song("3H43T5swYywvcdCBFiDgW6", "Manwa Laage", "Shreya Ghoshal",
                    false),
                Song("5aU0fpmu2sdYJVOHVHCz5s", "Teri Ore", "Shreya Ghoshal",
                    false),
                Song("1vSXwYeKnzsVvekSpqVabx", "Chikni Chameli",
                    "Shreya Ghoshal", false),
              ];
              break;
            default:
              songs = [Song("", "", "", false)];
          }

          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AlbumView(
                  title: music.name,
                  imageUrl: music.imageURL,
                  songInfo: songs,
                  desc: music.description,
                  year: music.year,
                  showTitle: music.showTitle,
                ),
              ));
        },
        child: Padding(
          padding: const EdgeInsets.only(right: 18.0, top: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 180,
                width: 180,
                child: CachedNetworkImage(
                  imageUrl: music.imageURL,
                  fit: BoxFit.cover,
                ), // Music cover image
              ),
              const SizedBox(height: 10),
              Text(music.name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700)), // Music name
              Container(
                height: 40,
                width: 180,
                child: Flexible(
                  child: Text(
                    music.desc,
                    style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                        fontWeight: FontWeight.w200),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ), // Music description
            ],
          ),
        ),
      ),
    );
  }

  Widget createMusicList2b(BuildContext context) {
    return Column(
      children: [
        Container(
          alignment: Alignment.topLeft,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: const Text(
            'Made For You', // Section title
            style: TextStyle(
                color: Colors.white, fontSize: 25, fontWeight: FontWeight.w700),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9),
          height: 260,
          child: ScrollConfiguration(
            behavior:
                NoOverscrollGlowBehavior(), // Disable overscroll glow effect
            child: ListView.builder(
              scrollDirection: Axis.horizontal, // Horizontal scrolling
              itemBuilder: (ctx, index) {
                return madeFor2b(
                    context, musicList2b[index], index); // Create music widgets
              },
              itemCount: musicList2b.length, // Number of music items
            ),
          ),
        ),
      ],
    );
  }

  // Create a widget for 'Made For You' music section
  Widget madeForYou(BuildContext context, MusicList music, int index) {
    return PressableItem(
      child: GestureDetector(
        onTap: () {
          List<Song> songs;
          switch (index) {
            case 0:
              songs = recentSongs;
              break;
            case 1:
              songs = [
                Song("7yq4Qj7cqayVTp3FF9CWbm", "Riptide", "Vance Joy", false),
                Song("7e6qTHVfRdaYsio90s1fHC", "Ik Junoon (Paint It Red)",
                    "Vishal Dadlani", false),
                Song("4fyR24BKznXBLNkK8LwWla", "Dheere Dheere",
                    "Yo Yo Honey Singh", false),
                Song("39bx4zZrPxTjw8VNuvjt6X", "Criminal", "Akon", false),
              ];
              break;
            case 2:
              songs = [
                Song("0k9k2Mr1gR7zeSLiNAqimY", "Alors Brazil", "NONTHENSE",
                    true),
                Song(
                    "24WBge8e53iDTeXOtVB02s", "Eu sento gabu", "PXLWYSE", true),
                Song("60AVJqYgyAlCckC6Nh2tgO", "X-SLIDE", "2KE, 808iuli", true),
                Song("67smGwuPEtA6GAfeweAVNO", "SLAY!", "Eternxlkz", true),
                Song("6qyS9qBy0mEk3qYaH8mPss", "Murder in My Mind", "kordhell",
                    true),
                Song("4hcnbu7PdISGGj82ZuDpFQ", "FRESH", "NXVAMANE", false),
                Song("0hEjvk5rMwLzt9rUcFmZG7", "Sequência da Dz7",
                    "TRASHXRL, Mc Menor Do Alvorada", true),
                Song("1A7qPfbcyRVEdcZiwTFhZI", "Memory Reboot", "VØJ", false),
                Song("7vtGOauV0Zz8Px5EJYm7d7", "life in Rio",
                    "Slowboy, NEUKICrazy Mano", true),
              ];
              break;
            default:
              songs = [Song("default_url1", "", "", false)];
          }

          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AlbumView(
                  title: music.name,
                  imageUrl: music.imageURL,
                  songInfo: songs,
                  desc: music.description,
                  year: music.year,
                  showTitle: music.showTitle,
                ),
              ));
        },
        child: Padding(
          padding: const EdgeInsets.only(right: 18.0, top: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 180,
                width: 180,
                child: CachedNetworkImage(
                  imageUrl: music.imageURL,
                  fit: BoxFit.cover,
                ), // Music cover image
              ),
              const SizedBox(height: 10),
              Text(music.name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700)), // Music name
              Container(
                height: 40,
                width: 180,
                child: Flexible(
                  child: Text(
                    music.desc,
                    style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                        fontWeight: FontWeight.w200),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ), // Music description
            ],
          ),
        ),
      ),
    );
  }

  // Create the 'Made For You' music list section
  Widget createMusicList1(BuildContext context) {
    return Column(
      children: [
        Container(
          alignment: Alignment.topLeft,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: const Text(
            'Made For You', // Section title
            style: TextStyle(
                color: Colors.white, fontSize: 25, fontWeight: FontWeight.w700),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9),
          height: 260,
          child: ScrollConfiguration(
            behavior:
                NoOverscrollGlowBehavior(), // Disable overscroll glow effect
            child: ListView.builder(
              scrollDirection: Axis.horizontal, // Horizontal scrolling
              itemBuilder: (ctx, index) {
                return madeForYou(
                    context, musicList1[index], index); // Create music widgets
              },
              itemCount: musicList1.length, // Number of music items
            ),
          ),
        ),
      ],
    );
  }

  // Create a widget for 'Best Of Artists' music section
  Widget bestOfArtists(BuildContext context, MusicList music, int index) {
    return PressableItem(
      child: GestureDetector(
        onTap: () {
          List<Song> songs;
          switch (index) {
            case 0:
              songs = [
                Song("5icOoE6VgqFKohjWWNp0Ac", "Here With Me",
                    "Marshmello, CHVRCHES", false),
                Song("08bNPGLD8AhKpnnERrAc6G", "FRIENDS",
                    "Marshmello, Anne-Marie", true),
                Song("3MEYFivt6bilQ9q9mFWZ4g", "Alone", "Marshmello", false),
                Song("4EAV2cKiqKP5UPZmY6dejk", "Everyday", "Marshmello, Logic",
                    true),
                Song("1Hk0QRlUFCHYG6zIvUh0Xd", "Summer", "Marshmello", false),
                Song("7BqHUALzNBTanL6OvsqmC1", "Happier", "Marshmello", false),
                Song("0tBbt8CrmxbjRP0pueQkyU", "Wolves",
                    "Marshmello, Selena Gomez", false),
              ];
              break;
            case 1:
              songs = [
                Song("5T7ZFtCcOgkpjxcuaeZbw0", "Best Song Ever",
                    "One Direction", false),
                Song("5O2P9iiztwhomNh8xkR9lJ", "Night Changes", "One Direction",
                    false),
                Song("4cluDES4hQEUhmXj6TXkSo", "What makes You Beautiful",
                    "One Direction", false),
                Song("2K87XMYnUMqLcX3zvtAF4G", "Drag Me Down", "One Direction",
                    false),
                Song("4JaLkM90MJutDAl5jD9BZX", "No Control", "One Direction",
                    false),
                Song("6Vh03bkEfXqekWp7Y1UBRb", "Live While We're Young",
                    "One Direction", false),
                Song("3NLnwwAQbbFKcEcV8hDItk", "Perfect", "One Direction",
                    false),
              ];
              break;
            case 2:
              songs = [
                Song("0KKkJNfGyhkQ5aFogxQAPU", "That's What I Like",
                    "Bruno Mars", false),
                Song("7BqBn9nzAq8spo5e7cZ0dJ", "Just the Way You Are",
                    "Bruno Mars", false),
                Song(
                    "6b8Be6ljOzmkOmFslEb23P", "24K Magic", "Bruno Mars", false),
                Song("32OlwWuMpZ6b0aN2RZOeMS", "Uptown Funk",
                    "Bruno Mars,Mark Ronson", true),
                Song("4lLtanYk6tkMvooU0tWzG8", "Grenade", "Bruno Mars", false),
                Song("02VBYrHfVwfEWXk5DXyf0T", "Leave The Door Open",
                    "Bruno Mars, Anderson Paak, Silk Sonic", false),
                Song("0kN8xEmgMW9mh7UmDYHlJP", "Versace on the Floor",
                    "Bruno Mars", false),
              ];
              break;
            case 3:
              songs = [
                Song("285pBltuF7vW8TeWk8hdRR", "Lucid Dreams", "Juice WRLD",
                    true),
                Song("4VXIryQMWpIdGgYR4TrjT1", "All Girls Are The Same",
                    "Juice WRLD", true),
                Song("2Y0wPrPQBrGhoLn14xRYCG", "Come & Go (with Marshmello)",
                    "Juice WRLD", true),
                Song("1a7WZZZH7LzyvorhpOJFTe", "Wasted",
                    "Juice WRLD, Lil Uzi Vert", true),
              ];
              break;
            default:
              songs = [Song("default_url1", "", "", false)];
          }

          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AlbumView(
                  title: music.name,
                  imageUrl: music.imageURL,
                  songInfo: songs,
                  desc: music.description,
                  year: music.year,
                  showTitle: music.showTitle,
                ),
              ));
        },
        child: Padding(
          padding: const EdgeInsets.only(right: 18.0, top: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 180,
                width: 180,
                child: CachedNetworkImage(
                  imageUrl: music.imageURL,
                  fit: BoxFit.cover,
                ), // Music cover image
              ),
              const SizedBox(height: 10),
              Text(music.name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700)), // Music name
              Container(
                height: 40,
                width: 180,
                child: Flexible(
                  child: Text(
                    music.desc,
                    style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                        fontWeight: FontWeight.w200),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ), // Music description
            ],
          ),
        ),
      ),
    );
  }

  // Create the 'Best Of Artists' music list section
  Widget createMusicList2(BuildContext context) {
    return Column(
      children: [
        Container(
          alignment: Alignment.topLeft,
          padding: const EdgeInsets.only(left: 10, top: 10, bottom: 10),
          child: const Text(
            'Best Of Artists', // Section title
            style: TextStyle(
                color: Colors.white, fontSize: 25, fontWeight: FontWeight.w700),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9),
          height: 260,
          child: ScrollConfiguration(
            behavior:
                NoOverscrollGlowBehavior(), // Disable overscroll glow effect
            child: ListView.builder(
              scrollDirection: Axis.horizontal, // Horizontal scrolling
              itemBuilder: (ctx, index) {
                return bestOfArtists(
                    context, musicList2[index], index); // Create music widgets
              },
              itemCount: musicList2.length, // Number of music items
            ),
          ),
        ),
      ],
    );
  }

// Create a widget for 'Popular' music section
  Widget popular(BuildContext context, MusicList music, int index) {
    return PressableItem(
      child: GestureDetector(
        onTap: () {
          List<Song> songs;
          switch (index) {
            case 0:
              songs = [
                Song("3APdIdF8H0jsxSuGOqXedS", "Kabhi Kabhi Aditi",
                    "Rashid Ali", false),
                Song("18YHbIhrleUkKKj2DvEp79", "Zara Sa", "Pritam,KK", false),
                Song("2UKK9UEbKlykbmLVP1zWIQ", "Haule Haule",
                    "Salim-Sulaiman, SUkhwinder Singh, Jaideep Saini", false),
                Song("1EjxJHY9A6LMOlvyZdwDly", "Tum Mile",
                    "Pritam, Neeraj Shridhar", false),
                Song("1vBmaijoCBoqmwc3zs5n3s", "Dus Bahane", "Shaan,KK", false),
                Song("6CCV7FeYgEQ7Ekbes6B36Q", "Bhool Bhulaiyaa",
                    "Pritam, Neeraj Shridhar", false),
                Song("2JDsi7S0UmtGoyVPTda0ao", "Prem ki Naiyya",
                    "Neeraj Shridhar, Suzanne D'Mello, Pritam", false),
              ];
              break;
            case 1:
              songs = [
                Song("5cjVsWqIkBQC7acTRhL0RO", "Kamariya",
                    "Aastha Gill, Sachin Sanghvi, Jigar Saraiya", false),
                Song(
                    "16kiQQ4BoLHDyj5W2fkfNK",
                    "Tauba Tauba (From \"Bad Newz\")",
                    "Aastha Gill, Sachin Sanghvi, Jigar Saraiya",
                    false),
                Song("3BhjbaGeI7E0CiIjctfdD3", "Kar Gayi Chull", "Badshah",
                    false),
                Song("54SQet8YMttOgTqDNGcGpe", "Sau Tarah Ke", "Pritam", false),
                Song("4dJWik0ax9bRFXl0HqbFjT", "High rated Gabru",
                    "Guru Randhawa", false),
                Song("5cjVsWqIkBQC7acTRhL0RO", "Kamariya",
                    "Aastha Gill, Sachin Sanghvi, Jigar Saraiya", false),
              ];
              break;
            case 2:
              songs = [
                Song("48Ix6ReYdJf2H4mKb3TIpj", "Tera Hone Laga Hoon",
                    "Atif Aslam", false),
                Song("2GXXZFUxYg2LvG8SR0byOE", "Jeena Jeena", "Atif Aslam",
                    false),
                Song("0FBQ4NrrHUbR9kus7rzrOj", "Dil Diyan Gallan", "Atif Aslam",
                    false),
                Song("2IEhtVeM9TVql8fZdKdlo9", "Main Rang Sharabdon Ka",
                    "Atif Aslam", false),
                Song("5llaVhaIoowKT3fqf2NfPO", "Pehli Nazar Main", "Atif Aslam",
                    false),
              ];
              break;
            case 3:
              songs = [
                Song("5d6Mjuu2uCGRPYpFjGpCX5", "Sugar", "Maroon 5", true),
                Song("3h4T9Bg8OVSUYa6danHeH5", "Animals", "Maroon 5", false),
                Song("1XGmzt0PVuFgQYYnV2It7A", "Payphone", "Maroon 5", true),
                Song("1r299qCKBLgUS9XJ9m1kEx", "Moves like Jagger", "Maroon 5",
                    false),
                Song("7npLlaPu9Mfno8hjk5OagD", "Girls Like You", "Maroon 5",
                    true),
              ];
              break;
            default:
              songs = [Song("default_url1", "", "", false)];
          }

          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AlbumView(
                  title: music.name,
                  imageUrl: music.imageURL,
                  songInfo: songs,
                  desc: music.description,
                  year: music.year,
                  showTitle: music.showTitle,
                ),
              ));
        },
        child: Padding(
          padding: const EdgeInsets.only(right: 18.0, top: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 180,
                width: 180,
                child: CachedNetworkImage(
                  imageUrl: music.imageURL,
                  fit: BoxFit.cover,
                ), // Music cover image
              ),
              const SizedBox(height: 10),
              Text(music.name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700)), // Music name
              Container(
                height: 40,
                width: 180,
                child: Flexible(
                  child: Text(
                    music.desc,
                    style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                        fontWeight: FontWeight.w200),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ), // Music description
            ],
          ),
        ),
      ),
    );
  }

// Create the 'Popular' music list section
  Widget createMusicList3(BuildContext context) {
    return Column(
      children: [
        Container(
          alignment: Alignment.topLeft,
          padding: const EdgeInsets.only(left: 10, top: 10, bottom: 10),
          child: const Text(
            'Popular', // Section title
            style: TextStyle(
                color: Colors.white, fontSize: 25, fontWeight: FontWeight.w700),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9),
          height: 400,
          child: ScrollConfiguration(
            behavior:
                NoOverscrollGlowBehavior(), // Disable overscroll glow effect
            child: ListView.builder(
              scrollDirection: Axis.horizontal, // Horizontal scrolling
              itemBuilder: (ctx, index) {
                return popular(
                    context, musicList3[index], index); // Create music widgets
              },
              itemCount: musicList3.length, // Number of music items
            ),
          ),
        ),
      ],
    );
  }
}

// Custom ScrollBehavior to disable overscroll glow effect
class NoOverscrollGlowBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child; // Disable overscroll glow effect
  }
}
