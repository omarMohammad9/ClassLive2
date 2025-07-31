import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../BottomNavigation/bottomNavigation.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  Home2 createState() => Home2();
}

class Home2 extends State<Home> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    const videoUrl = 'https://youtu.be/DOxng1YwX8w';
    final videoId = YoutubePlayer.convertUrlToId(videoUrl)!;

    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.red,
      ),
      onEnterFullScreen: () {

        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      },
      onExitFullScreen: () {

        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
        ]);
      },
      builder: (context, player) {
        return Scaffold(

          backgroundColor: Colors.white,
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.only(
              left: 7,
              right: 7,
              bottom: 16,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: BottomNavigation(
                selectedIndex: 2,
              ),
            ),
          ),          appBar: AppBar(title: const Text('عرض فيديو يوتيوب')),
          drawer: const Drawer(),
          body: Center(child: player),
        );
      },
    );
  }
}
