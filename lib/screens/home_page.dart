import 'dart:io';
import 'package:deep_fake/services/model_servise.dart';
import 'package:deep_fake/services/models/response/user.dart';
import 'package:deep_fake/screens/result_page.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? _media;
  VideoPlayerController? _videoController;
  bool _isVideo = false;
  bool _isVideoPlaying = false;
  bool _isLoading = false;

  Future<void> _pickMedia() async {
    final picker = ImagePicker();

    final pickedFile = await showDialog<XFile?>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Select Media"),
        actions: [
          TextButton(
            onPressed: () async {
              final file = await picker.pickImage(source: ImageSource.gallery);
              Navigator.of(context).pop(file);
            },
            child: Text("Pick Image"),
          ),
          TextButton(
            onPressed: () async {
              final file = await picker.pickVideo(source: ImageSource.gallery);
              Navigator.of(context).pop(file);
            },
            child: Text("Pick Video"),
          ),
        ],
      ),
    );

    if (pickedFile != null) {
      File file = File(pickedFile.path);
      bool isVideo = pickedFile.path.toLowerCase().endsWith('.mp4') ||
          pickedFile.path.toLowerCase().endsWith('.mov');

      setState(() {
        _media = file;
        _isVideo = isVideo;
      });

      if (isVideo) {
        _videoController?.dispose();
        _videoController = VideoPlayerController.file(file)
          ..initialize().then((_) {
            setState(() {});
            _videoController!.pause();
          });
      }
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  void _toggleVideo() {
    if (_isVideo && _videoController != null) {
      setState(() {
        if (_isVideoPlaying) {
          _videoController!.pause();
        } else {
          _videoController!.play();
        }
        _isVideoPlaying = !_isVideoPlaying;
      });
    }
  }

  // Future<void> uploadMedia() async {
  //   if (_media == null) return;

  //   try {
  //     print("Uploading file...");
  //     FileApiService api = FileApiService();
  //     UserFile uploadedFile = await api.uploadFile(_media!);
  //     print('File uploaded with ID: ${uploadedFile.id}');
  //     print('Prediction: ${uploadedFile.isFake == true ? "Fake" : "Real"}');
  //     print('Confidence: ${uploadedFile.confidenceScore}');
  //   } catch (e) {
  //     print("Upload error: $e");
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    bool isHomePage = ModalRoute.of(context)?.settings.name == '/home';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  if (_media != null)
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.4),
                      spreadRadius: 4,
                      blurRadius: 15,
                      offset: Offset(0, 8),
                    ),
                ],
                image: _isVideo
                    ? null
                    : _media != null
                        ? DecorationImage(
                            image: FileImage(_media!),
                            fit: BoxFit.contain,
                          )
                        : DecorationImage(
                            image: AssetImage('assets/login_image.png'),
                            fit: BoxFit.contain,
                          ),
              ),
              child: _isVideo
                  ? _videoController != null &&
                          _videoController!.value.isInitialized
                      ? AspectRatio(
                          aspectRatio: _videoController!.value.aspectRatio,
                          child: VideoPlayer(_videoController!),
                        )
                      : Center(child: CircularProgressIndicator())
                  : null,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Click here to ',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
                ElevatedButton(
                  onPressed: (_media != null && !_isLoading)
                      ? () async {
                          setState(() => _isLoading = true);
                          try {
                            FileApiService api = FileApiService();
                            final result = await api.predictImage(_media!);
                            print(
                                'Prediction: ${result['prediction']}, Confidence: ${result['confidence']}');

                            // Navigate to result page
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ResultPage(imageFile: _media),
                              ),
                            );
                            print(
                                'Prediction: ${result['prediction']}, Confidence: ${result['confidence']}');
                          } catch (e) {
                            print('Error analyzing image: $e');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Failed to analyze image: $e')),
                            );
                          } finally {
                            setState(() => _isLoading = false);
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff0177b7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Detect',
                          style: TextStyle(color: Colors.white, fontSize: 15),
                        ),
                ),
              ],
            ),
            if (_isVideo)
              IconButton(
                icon: Icon(
                  _isVideoPlaying ? Icons.pause : Icons.play_arrow,
                  color: Color.fromRGBO(1, 119, 183, 1),
                  size: 30,
                ),
                onPressed: _toggleVideo,
              ),
          ],
        ),
      ),
      floatingActionButton: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.9, end: 1.2),
        duration: Duration(seconds: 5),
        curve: Curves.easeInOut,
        builder: (context, scale, child) {
          return Transform.scale(scale: scale, child: child);
        },
        onEnd: () {
          Future.delayed(Duration(milliseconds: 100), () {
            if (mounted) setState(() {});
          });
        },
        child: SizedBox(
          width: 70,
          height: 80,
          child: FloatingActionButton(
            onPressed: _pickMedia,
            backgroundColor: Color.fromRGBO(1, 119, 183, 1),
            shape: CircleBorder(),
            elevation: 8,
            child: Icon(Icons.add_a_photo, color: Colors.white, size: 35),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        margin: EdgeInsets.only(bottom: 0, left: 10, right: 10, top: 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 8,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: BottomAppBar(
          color: Colors.transparent,
          shape: CircularNotchedRectangle(),
          notchMargin: 10,
          elevation: 0,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.home,
                    color: isHomePage
                        ? Color.fromRGBO(0, 162, 255, 1)
                        : Colors.cyan,
                    size: 30,
                  ),
                  onPressed: () {
                    if (!isHomePage) {
                      Navigator.pushNamed(context, '/home');
                    }
                  },
                ),
                IconButton(
                  icon: Icon(Icons.person,
                      color: const Color.fromRGBO(1, 119, 183, 1), size: 30),
                  onPressed: () {
                    Navigator.pushNamed(context, '/profile');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
