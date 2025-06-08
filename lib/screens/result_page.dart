import 'package:flutter/material.dart';
import 'dart:io';

class ResultPage extends StatelessWidget {
  final File? imageFile;

  const ResultPage({Key? key, required this.imageFile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('Detection Result')),
      body: Column(
        children: [
          SizedBox(height: 20),
          if (imageFile != null)
            Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    imageFile!,
                    width: 300,
                    height: 300,
                    fit: BoxFit.contain,  
                  ),
                ),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(Icons.close, size: 50, color: Colors.white),
                ),
              ],
            ),
          SizedBox(height: 30),
          Icon(Icons.warning_amber_rounded, size: 40, color: Colors.orange),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Image is fake! We detected clear signs of editing.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.black87),
            ),
          ),
          SizedBox(height: 30),
          Text(
            'Fake',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.pink,
            ),
          ),
        ],
      ),
    );
  }

}
