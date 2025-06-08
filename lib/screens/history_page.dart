import 'package:flutter/material.dart';
import 'package:deep_fake/services/models/response/user.dart';
import 'package:deep_fake/services/model_servise.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final FileApiService _fileApiService = FileApiService(token: 'YOUR_TOKEN_HERE');
  List<UserFile> historyData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final files = await _fileApiService.fetchUserFiles();
      setState(() {
        historyData = files;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load history: $e')),
      );
    }
  }

  Future<void> _deleteHistoryItem(int index) async {
    try {
      final file = historyData[index];
      final success = await _fileApiService.deleteFile(file.id);
      if (success) {
        setState(() {
          historyData.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File deleted successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete file: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Stack(
            children: [
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.lightBlueAccent,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
              ),
              Positioned(
                top: 60,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    'History',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : historyData.isEmpty
                    ? Center(
                        child: Text(
                          'History is empty',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: historyData.length,
                        itemBuilder: (context, index) {
                          final item = historyData[index];
                          return Card(
                            margin: EdgeInsets.only(bottom: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(8),
                              leading: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 28,
                                    backgroundImage: NetworkImage(item.filePath),
                                  ),
                                  Positioned(
                                    bottom: -2,
                                    right: -2,
                                    child: Icon(
                                      item.isFake == true
                                          ? Icons.cancel
                                          : Icons.check_circle,
                                      color: item.isFake == true
                                          ? Colors.red
                                          : Colors.green,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                              title: Text(
                                  'File uploaded on: ${item.createdAt?.toLocal().toString().split(' ')[0] ?? ''}'),
                              subtitle: Text(
                                  'Type: ${item.fileType}, Confidence: ${item.confidenceScore?.toStringAsFixed(2) ?? 'N/A'}'),
                              trailing: IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteHistoryItem(index),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
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
                    color: const Color.fromARGB(178, 26, 3, 3),
                    size: 30,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/home');
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.person,
                    color: const Color.fromARGB(178, 26, 3, 3),
                    size: 30,
                  ),
                  onPressed: () {
                    Navigator.pop(context, '/profile');
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
