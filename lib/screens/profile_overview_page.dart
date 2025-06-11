import 'package:flutter/material.dart';
import 'dart:io';
import 'package:deep_fake/services/auth_service.dart';

class ProfileOverviewScreen extends StatefulWidget {
  @override
  _ProfileOverviewScreenState createState() => _ProfileOverviewScreenState();
}

class _ProfileOverviewScreenState extends State<ProfileOverviewScreen> {
  File? _imageFile;
  String _username = 'User Name';
  String _email = 'user@example.com';

  @override
  void initState() {
    super.initState();
    final userData = AuthService().userData();
    _username = userData?['full_name'] ?? 'User Name';
    _email = userData?['email'] ?? 'user@example.com';
  }

  @override
  Widget build(BuildContext context) {
    String currentRoute = ModalRoute.of(context)?.settings.name ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 320,
                  decoration: BoxDecoration(
                    color: Colors.lightBlueAccent,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(60),
                      bottomRight: Radius.circular(60),
                    ),
                  ),
                ),
                Positioned(
                  top: 90,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: _imageFile != null
                            ? FileImage(_imageFile!)
                            : AssetImage("assets/gallery_placeholder.png")
                                as ImageProvider,
                      ),
                      SizedBox(height: 10),
                      Text(
                        _username,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _email,
                        style: TextStyle(color: Colors.grey[700], fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            buildCardSection([
              buildListTile(Icons.edit, "Edit profile information", () async {
                final result = await Navigator.pushNamed(
                  context,
                  '/edit_profile',
                  arguments: {
                    'image': _imageFile,
                    'username': _username,
                    //'email': _email,
                  },
                );

                if (result != null && result is Map) {
                  setState(() {
                    _imageFile = result['image'] as File?;
                    _username = result['username'] ?? _username;
                  });
                }
              }),
              buildListTile(Icons.language, "Language", () {},
                  trailing:
                      Text("English", style: TextStyle(color: Colors.blue))),
              buildListTile(Icons.history, "History", () {
                Navigator.pushNamed(context, '/history');
              }),
            ]),
            buildCardSection([
              buildListTile(Icons.help_outline, "Help & Support", () {
                Navigator.pushNamed(context, '/help');
              }),
              buildListTile(Icons.privacy_tip_outlined, "Privacy policy", () {
                Navigator.pushNamed(context, '/privacy');
              }),
              buildListTile(Icons.logout, "Logout", () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Confirm Logout"),
                      content: Text("Are you sure you want to log out?"),
                      actions: [
                        TextButton(
                          child: Text("Cancel"),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        TextButton(
                          child: Text("Logout"),
                          onPressed: () async {
                            Navigator.of(context).pop();
                            try {
                              await AuthService().logout();
                              Navigator.pushNamedAndRemoveUntil(
                                  context, '/login', (route) => false);
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Logout failed. Please try again.')),
                              );
                            }
                          },
                        ),
                      ],
                    );
                  },
                );
              }),
            ]),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: buildBottomNavigationBar(currentRoute),
    );
  }

  Widget buildListTile(IconData icon, String title, VoidCallback onTap,
      {Widget? trailing}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: trailing,
      onTap: onTap,
    );
  }

  Widget buildCardSection(List<Widget> children) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(children: children),
    );
  }

  Widget buildBottomNavigationBar(String currentRoute) {
    return Container(
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
                icon: Icon(Icons.home,
                    color: const Color.fromRGBO(1, 119, 183, 1), size: 30),
                onPressed: () {
                  if (ModalRoute.of(context)?.settings.name != '/home') {
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/home', (route) => false);
                  }
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.person,
                  color: currentRoute == '/profile'
                      ?Color.fromRGBO(0, 162, 255, 1)
                      : Colors.cyan,
                  size: 30,
                ),
                onPressed: () {
                  if (currentRoute != '/profile') {
                    Navigator.pushNamed(context, '/profile');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
