import 'dart:ui';

import 'package:flickd_app/controllers/profile_controller.dart';
import 'package:flickd_app/models/movie.dart';
import 'package:flickd_app/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../filter/wishlist_providers.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.width;

    final favorites = ref.watch(filteredAndSortedFavouritesProvider);
    final profile = ref.watch(profileProvider);

    return _BuildUI(
      deviceWidth,
      deviceHeight,
      favorites,
      profile,
      context,
      ref,
    );
  }

  Widget _BuildUI(
    double deviceWidth,
    double deviceHeight,
    List<Movie> favorites,
    String? profile,
    BuildContext context,
    WidgetRef ref,
  ) {
    return Container(
      width: deviceWidth,
      child: Stack(
        children: [
          _backgroundWidget(deviceWidth, deviceHeight),
          _allUIWidgets(
            deviceWidth,
            deviceHeight,
            favorites,
            profile,
            context,
            ref,
          ),
        ],
      ),
    );
  }

  _backgroundWidget(double deviceWidth, double deviceHeight) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight, // to-br
            colors: [
              Color(0xFF78350F), // amber-900
              Color(0xFF1E293B), // slate-800
              Color(0xFF1E3A8A), // blue-900
            ],
          ),
        ),
      ),
    );
  }

  Widget _allUIWidgets(
    double deviceWidth,
    double deviceHeight,
    List<Movie> favorites,
    String? profile,
    BuildContext context,
    WidgetRef ref,
  ) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _topBarWidget(deviceWidth, deviceHeight, ref),
            SizedBox(
              height: deviceHeight * 0.02,
            ), //khoảng cách giữa top bar và danh sách phim
            Expanded(
              //Dùng Expanded để cho widget con chiếm toàn bộ không gian còn lại
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: deviceHeight * 0.01,
                ), //khoảng cách trên dưới
                child: _informationProfileWidget(
                  //danh sách phim
                  deviceHeight,
                  deviceWidth,
                  profile,
                  favorites,
                  context,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topBarWidget(double deviceWidth, double deviceHeight, WidgetRef ref) {
    return Material(
      color: const Color(0xCC0F172A),
      child: Padding(
        padding: EdgeInsets.only(
          top: deviceHeight * 0.01,
          left: 12,
          right: 12,
          bottom: deviceHeight * 0.05,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_titleBarWidget()],
        ),
      ),
    );
  }

  Widget _titleBarWidget() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 16, top: 25),
          child: Text(
            'My Profile',
            style: TextStyle(
              color: Colors.white,
              fontSize: 35,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: 16, top: 16),
          child: Icon(Icons.person, color: Colors.white, size: 32),
        ),
      ],
    );
  }

  Widget _informationProfileWidget(
    double deviceHeight,
    double deviceWidth,
    String? profile,
    List<Movie> favorites,
    BuildContext context,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _profile(deviceWidth, deviceHeight, profile, favorites),
        SizedBox(height: deviceHeight * 0.02),
        _overview(favorites),
        SizedBox(height: deviceHeight * 0.02),
        Expanded(child: _settings(context)),
      ],
    );
  }

  Widget _profile(
    double deviceWidth,
    double deviceHeight,
    String? profile,
    List<Movie> favourites,
  ) {
    final height = deviceHeight * 0.25;
    final width = deviceWidth * 0.9;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.35), // nền hơi mờ
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white12),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    buildAvatar(profile ?? 'Guest', 100),
                    SizedBox(width: 12),
                    Text(
                      profile ?? 'Guest',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                _totalWishlist(favourites),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _totalWishlist(List<Movie> favourites) {
    return Expanded(
      child: Container(
        height: 100,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.favorite, color: Colors.redAccent, size: 32),
                Divider(
                  thickness: 1.5,
                  color: const Color.fromARGB(60, 234, 18, 18),
                ),
                SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      favourites.length.toString(),
                      style: TextStyle(
                        color: const Color.fromARGB(255, 248, 171, 29),
                        fontSize: 45,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Movie in Wishlist',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAvatar(String username, double size) {
    final initial = username.isNotEmpty ? username[0].toUpperCase() : '?';

    return CircleAvatar(
      radius: size / 2,
      backgroundColor: Colors.blueGrey,
      child: Text(
        initial,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.45,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _overview(List<Movie> favorites) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.35), // nền hơi mờ
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white12),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(child: Center(child: _totalReleasingSoon(favorites))),
                Expanded(child: Center(child: _totalTopRated(favorites))),
                Expanded(child: Center(child: _totalYearly(favorites))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _totalReleasingSoon(List<Movie> favorites) {
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);

    final upcomingCount = favorites.where((m) {
      final dateStr = m.releaseDate?.trim();
      if (dateStr == null || dateStr.isEmpty || dateStr == 'Unknown')
        return false;

      final parsed = DateTime.tryParse(dateStr);
      if (parsed == null) return false;

      // inclusive: true nếu releaseDate >= startOfToday
      return !parsed.isBefore(startOfToday);
    }).length;

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.calendar_month,
          color: const Color.fromARGB(255, 65, 98, 243),
          size: 32,
        ),
        SizedBox(height: 8),
        Text(
          upcomingCount.toString(),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: const Color.fromARGB(255, 255, 255, 255),
            fontSize: 35,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Releasing Soon',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      ],
    );
  }

  Widget _totalTopRated(List<Movie> favorites) {
    final AvgRating = favorites.isNotEmpty
        ? (favorites.map((m) => m.rating).reduce((a, b) => a + b) /
              favorites.length)
        : 0.0;
    final avg = AvgRating.toStringAsFixed(1);
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.star, color: Colors.orangeAccent, size: 32),
        SizedBox(height: 8),
        Text(
          avg.toString(),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: const Color.fromARGB(255, 255, 255, 255),
            fontSize: 35,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Avg Rating',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      ],
    );
  }

  Widget _totalYearly(List<Movie> favorites) {
    final topYear = <int, int>{};
    for (var movie in favorites) {
      if (movie.releaseDate != null && movie.releaseDate!.length >= 4) {
        final year = int.tryParse(movie.releaseDate!.substring(0, 4));
        if (year != null) {
          topYear[year] = (topYear[year] ?? 0) + 1;
        }
      }
    }
    if (topYear.isEmpty) {
      return "N/A" as Widget;
    }
    int maxYear = topYear.keys.first;
    int maxCount = topYear[maxYear]!;
    topYear.forEach((year, count) {
      if (count > maxCount) {
        maxYear = year;
        maxCount = count;
      }
    });
    final Top = maxYear.toString();

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.arrow_upward,
          color: const Color.fromARGB(255, 23, 240, 27),
          size: 32,
        ),
        SizedBox(height: 8),
        Text(
          Top,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: const Color.fromARGB(255, 255, 255, 255),
            fontSize: 35,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Top Year',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      ],
    );
  }

  Widget _settings(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      children: [
        _editProfile(),
        SizedBox(height: 10),
        _notifications(),
        SizedBox(height: 10),
        _appSettings(),
        SizedBox(height: 10),
        _helpSupport(),
        SizedBox(height: 10),
        _logout(context),
      ],
    );
  }

  Widget _editProfile() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.35), // nền hơi mờ
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white12),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              //mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              //crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                icon(Icons.person_outline),
                SizedBox(width: 30),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Edit Profile',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Update username and avatar',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _notifications() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.35), // nền hơi mờ
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white12),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              //mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              //crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                icon(Icons.notifications_on_outlined),
                SizedBox(width: 30),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notifications',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Release date reminders',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _appSettings() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.35), // nền hơi mờ
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white12),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              //mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              //crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                icon(Icons.settings_outlined),
                SizedBox(width: 30),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'App Settings',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Language and preferences',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _helpSupport() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.35), // nền hơi mờ
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white12),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              //mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              //crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                icon(Icons.help_outline),
                SizedBox(width: 30),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Help & Support',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Get help and support',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _logout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: Color.fromARGB(
                255,
                174,
                101,
                5,
              ).withOpacity(0.35), // nền hơi mờ
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white12),
            ),
            padding: const EdgeInsets.all(12),
            child: InkWell(
              onTap: () {
                // Handle logout action
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => LoginPage()),
                ); // Close the profile page
              },
              child: Row(
                //mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                //crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  icon(Icons.logout),
                  SizedBox(width: 30),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Logout',
                        style: TextStyle(
                          color: const Color.fromARGB(255, 174, 101, 5),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Sign out of your account',
                        style: TextStyle(
                          color: Color.fromARGB(255, 174, 101, 5),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget icon(IconData iconData) {
    return Container(
      padding: const EdgeInsets.all(3), // độ dày viền
      decoration: BoxDecoration(shape: BoxShape.circle),
      child: CircleAvatar(
        radius: 24,
        backgroundColor: const Color.fromARGB(255, 225, 187, 126),
        child: Icon(
          iconData,
          color: const Color.fromARGB(255, 174, 101, 5),
          size: 28,
        ),
      ),
    );
  }
}
