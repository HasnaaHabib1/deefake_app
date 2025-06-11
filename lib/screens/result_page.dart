import 'package:flutter/material.dart';
import 'dart:io';
import 'package:deep_fake/services/model_servise.dart';
import 'package:video_player/video_player.dart';

class ResultPage extends StatefulWidget {
  final File? imageFile;

  const ResultPage({Key? key, required this.imageFile}) : super(key: key);

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  bool isLoading = true;
  String prediction = '';
  double confidence = 0.0;
  String? error;
  bool isVideo = false;
  VideoPlayerController? _videoController;
  bool _isVideoPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializeMedia();
  }

  Future<void> _initializeMedia() async {
    if (widget.imageFile == null) {
      setState(() {
        error = 'No media file provided';
        isLoading = false;
      });
      return;
    }

    // Check if the file is a video
    final String ext = widget.imageFile!.path.split('.').last.toLowerCase();
    final List<String> videoFormats = [
      'mp4',
      'mov',
      'avi',
      'mkv',
      'wmv',
      'flv',
      '3gp',
      'webm'
    ];
    isVideo = videoFormats.contains(ext);

    if (isVideo) {
      _videoController = VideoPlayerController.file(widget.imageFile!);
      try {
        await _videoController!.initialize();
        setState(() {});
      } catch (e) {
        setState(() {
          error = 'Failed to load video: $e';
          isLoading = false;
        });
        return;
      }
    }

    _getPrediction();
  }

  void _toggleVideo() {
    if (isVideo && _videoController != null) {
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

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _getPrediction() async {
    try {
      FileApiService api = FileApiService();
      final result = isVideo
          ? await api.predictVideo(widget.imageFile!)
          : await api.predictImage(widget.imageFile!);

      setState(() {
        prediction = result['prediction'].toString().toLowerCase();
        confidence = (result['confidence'] as num).toDouble();
        isLoading = false;
      });
    } catch (e) {
      print('Error during prediction: $e');
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Detection Result')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 50, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          error!.replaceAll('Exception: ', ''),
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    const SizedBox(height: 20),
                    if (widget.imageFile != null)
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: isVideo && _videoController != null
                                ? AspectRatio(
                                    aspectRatio:
                                        _videoController!.value.aspectRatio,
                                    child: VideoPlayer(_videoController!),
                                  )
                                : Image.file(
                                    widget.imageFile!,
                                    width: 300,
                                    height: 300,
                                    fit: BoxFit.contain,
                                  ),
                          ),
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: prediction == 'fake'
                                  ? Colors.redAccent
                                  : Colors.green,
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                                prediction == 'fake'
                                    ? Icons.close
                                    : Icons.check,
                                size: 50,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    const SizedBox(height: 30),
                    Icon(
                      prediction == 'fake'
                          ? Icons.warning_amber_rounded
                          : Icons.verified,
                      size: 40,
                      color:
                          prediction == 'fake' ? Colors.orange : Colors.green,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      prediction == 'fake' ? 'Fake Detected' : 'Authentic',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: prediction == 'fake' ? Colors.red : Colors.green,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Confidence: ${confidence.toStringAsFixed(2)}%',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                    if (isVideo)
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: IconButton(
                          icon: Icon(
                            _isVideoPlaying ? Icons.pause : Icons.play_arrow,
                            color: Color.fromRGBO(1, 119, 183, 1),
                            size: 40,
                          ),
                          onPressed: _toggleVideo,
                        ),
                      ),
                  ],
                ),
    );
  }
}
