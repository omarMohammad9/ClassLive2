import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../BottomNavigation/bottomNavigation.dart';

class CourseDetailsPage extends StatefulWidget {
  final Map<String, dynamic> course;
  const CourseDetailsPage({Key? key, required this.course}) : super(key: key);

  @override
  State<CourseDetailsPage> createState() => _CourseDetailsPageState();
}

class _CourseDetailsPageState extends State<CourseDetailsPage> {
  late YoutubePlayerController _controller;
  int selectedLectureIndex = 0;
  bool _isLoading = false; // متغير لتتبع حالة التحميل

  final List<Map<String, String>> lectures = [
    {'title': 'المحاضرة 1', 'videoUrl': 'https://youtu.be/DOxng1YwX8w'},
    {'title': 'المحاضرة 2', 'videoUrl': 'https://youtu.be/L5gwRiomQkc?si=BEr0xdBRecWGIoYO'},
    {'title': 'المحاضرة 3', 'videoUrl': 'https://youtu.be/DOxng1YwX8w'},
    {'title': 'المحاضرة 4', 'videoUrl': 'https://youtu.be/DOxng1YwX8w'},
    {'title': 'المحاضرة 5', 'videoUrl': 'https://youtu.be/DOxng1YwX8w'},
    {'title': 'المحاضرة 6', 'videoUrl': 'https://youtu.be/DOxng1YwX8w'},
    {'title': 'المحاضرة 7', 'videoUrl': 'https://youtu.be/DOxng1YwX8w'},
    {'title': 'المحاضرة 8', 'videoUrl': 'https://youtu.be/DOxng1YwX8w'},
    {'title': 'المحاضرة 9', 'videoUrl': 'https://youtu.be/DOxng1YwX8w'},
    {'title': 'المحاضرة 10', 'videoUrl': 'https://youtu.be/DOxng1YwX8w'},
  ];

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    final videoUrl = lectures[selectedLectureIndex]['videoUrl']!;
    final videoId = YoutubePlayer.convertUrlToId(videoUrl)!;

    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    )..addListener(() {
      if (_controller.value.isReady && _isLoading) {
        setState(() {
          _isLoading = false; // إخفاء مؤشر التحميل عندما يكون الفيديو جاهزًا
        });
      }
    });
  }

  void _changeLecture(int index) {
    if (index != selectedLectureIndex) {
      setState(() {
        selectedLectureIndex = index;
        _isLoading = true; // إظهار مؤشر التحميل
        _controller.pause(); // إيقاف الفيديو الحالي
        final videoUrl = lectures[selectedLectureIndex]['videoUrl']!;
        final videoId = YoutubePlayer.convertUrlToId(videoUrl)!;
        _controller.load(videoId); // تحميل الفيديو الجديد بدلاً من إعادة إنشاء _controller
      });
    }
  }

  @override
  void dispose() {
    _controller.pause();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        key: ValueKey(lectures[selectedLectureIndex]['videoUrl']),
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
          appBar: AppBar(
            title: Text(widget.course['title']),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          body: Column(
            children: [
              Container(
                margin: const EdgeInsets.all(16),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : player, // إظهار مؤشر التحميل أو الفيديو
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  lectures[selectedLectureIndex]['title']!,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: lectures.length,
                  itemBuilder: (context, index) {
                    final isSelected = index == selectedLectureIndex;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isSelected ? Colors.blue : Colors.grey[300],
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          lectures[index]['title']!,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? Colors.blue : Colors.black,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.play_circle_filled, color: Colors.blue)
                            : const Icon(Icons.play_circle_outline, color: Colors.grey),
                        tileColor: isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: isSelected ? Colors.blue : Colors.grey[300]!,
                            width: 1,
                          ),
                        ),
                        onTap: () => _changeLecture(index),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('سيتم تحميل PDF المادة قريباً'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.download),
                    label: const Text('تحميل PDF المادة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
