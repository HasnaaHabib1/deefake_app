import 'dart:io';
import 'package:deep_fake/services/model_servise.dart';
import 'package:deep_fake/screens/result_page.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

class MediaFile {
  final XFile file;
  final bool isVideo;

  MediaFile(this.file, this.isVideo);
}

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

    try {
      bool? isVideo = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Select Media'),
          content: const Text('Choose media type for analysis'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(null);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop(false);
              },
              child: const Text('Pick Image'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop(true);
              },
              child: const Text('Pick Video'),
            ),
          ],
        ),
      );

      if (isVideo == null) return;

      final XFile? pickedFile;
      if (isVideo) {
        pickedFile = await picker.pickVideo(
          source: ImageSource.gallery,
          maxDuration: const Duration(minutes: 10),
        );
      } else {
        pickedFile = await picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1920,
          maxHeight: 1080,
          imageQuality: 85,
        );
      }

      if (pickedFile == null) return;

      final String ext = pickedFile.path.split('.').last.toLowerCase();
      final List<String> supportedVideoFormats = [
        'mp4',
        'mov',
        'avi',
        'mkv',
        'wmv',
        'flv',
        '3gp',
        'webm'
      ];
      final List<String> supportedImageFormats = [
        'jpg',
        'jpeg',
        'png',
        'webp',
        'gif'
      ];

      if (isVideo && !supportedVideoFormats.contains(ext)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Unsupported video format. Supported formats: ${supportedVideoFormats.join(", ")}'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      } else if (!isVideo && !supportedImageFormats.contains(ext)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Unsupported image format. Supported formats: ${supportedImageFormats.join(", ")}'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final path = pickedFile.path;

      setState(() {
        _media = File(path);
        _isVideo = isVideo;
      });

      if (isVideo) {
        _videoController?.dispose();
        _videoController = VideoPlayerController.file(_media!);
        await _videoController!.initialize();
        setState(() {});
      }
    } catch (e) {
      print('Error picking media: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting media: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
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
                      offset: const Offset(0, 8),
                    ),
                ],
              ),
              child: _media != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: _isVideo && _videoController != null
                          ? AspectRatio(
                              aspectRatio: _videoController!.value.aspectRatio,
                              child: VideoPlayer(_videoController!),
                            )
                          : Image.file(
                              _media!,
                              fit: BoxFit.contain,
                            ),
                    )
                  : Image.asset(
                      'assets/login_image.png',
                      fit: BoxFit.contain,
                    ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Click here to ',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
                ElevatedButton(
                  onPressed: (_media != null && !_isLoading)
                      ? () async {
                          setState(() => _isLoading = true);
                          try {
                            FileApiService api = FileApiService();
                            final result = _isVideo
                                ? await api.predictVideo(_media!)
                                : await api.predictImage(_media!);

                            if (mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ResultPage(imageFile: _media),
                                ),
                              );
                            }
                          } catch (e) {
                            print('Error analyzing media: $e');
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to analyze media: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } finally {
                            if (mounted) {
                              setState(() => _isLoading = false);
                            }
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff0177b7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
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
        duration: const Duration(seconds: 5),
        curve: Curves.easeInOut,
        builder: (context, scale, child) {
          return Transform.scale(scale: scale, child: child);
        },
        onEnd: () {
          if (mounted) {
            setState(() {});
          }
        },
        child: SizedBox(
          width: 70,
          height: 80,
          child: FloatingActionButton(
            onPressed: _pickMedia,
            backgroundColor: const Color(0xff0177b7),
            shape: const CircleBorder(),
            elevation: 8,
            child: const Icon(Icons.add_a_photo, color: Colors.white, size: 35),
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
