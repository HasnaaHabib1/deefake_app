import 'package:flutter/material.dart';
import 'dart:io';
import 'package:deep_fake/services/model_servise.dart';

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

  @override
  void initState() {
    super.initState();
    _getPrediction();
  }

  Future<void> _getPrediction() async {
    if (widget.imageFile == null) {
      setState(() {
        error = 'No image file provided';
        isLoading = false;
      });
      return;
    }

    try {
      final apiService = FileApiService();
      final result = await apiService.predictImage(widget.imageFile!);

      setState(() {
        prediction = result['prediction'] as String;
        confidence = (result['confidence'] as num).toDouble();
        isLoading = false;
      });
    } catch (e) {
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
                            child: Image.file(
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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        prediction == 'fake'
                            ? 'Image is fake! We detected clear signs of editing.'
                            : 'Image appears to be genuine.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 18, color: Colors.black87),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      confidence.toStringAsFixed(1) + '% Confidence',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color:
                            prediction == 'fake' ? Colors.pink : Colors.green,
                      ),
                    ),
                  ],
                ),
    );
  }
}
