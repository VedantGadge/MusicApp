import 'package:spotify_clone_app/models/category.dart';

class CategoryOperations {
  CategoryOperations._(); //Writing the constructor withm '._' so that the constructor remains private, and does not gets tampered later on.
  static List<Category> getCategories() {
    return <Category>[
      Category(
        name: 'This Is Arijit Singh',
        imageURL:
            'https://i.scdn.co/image/ab67706f0000000285c716247c24f66ef40f011e',
        desc: 'Bollywood crooner\'s essential songs.',
        year: '',
        showTitle: false,
      ),
      Category(
        name: 'UTOPIA',
        imageURL:
            'https://i.scdn.co/image/ab67616d0000b273881d8d8378cd01099babcd44',
        desc: '',
        year: '• 2023',
        showTitle: true,
      ),
      Category(
        name: 'Punya Paap',
        imageURL:
            'https://i.scdn.co/image/ab67616d0000b27383c726c3768d0981c76acd38',
        desc: '',
        year: '',
        showTitle: true,
      ),
      Category(
        name: 'This is Kendrick Lamar',
        imageURL:
            'https://thisis-images.spotifycdn.com/37i9dQZF1DZ06evO1IPOOk-default.jpg',
        desc:
            'This is Kendrick Lamar. The essential tracks, all in one playlist.',
        year: '',
        showTitle: false,
      ),
      Category(
          name: '÷ (Deluxe)',
          imageURL:
              'https://i.scdn.co/image/ab67616d0000b273ba5db46f4b838ef6027e6f96',
          desc: '',
          year: '',
          showTitle: true),
      Category(
        name: 'Starboy',
        imageURL:
            'https://i.scdn.co/image/ab67616d0000b2734718e2b124f79258be7bc452',
        desc: '',
        year: '• 2016',
        showTitle: true,
      ),
    ];
  }
}
