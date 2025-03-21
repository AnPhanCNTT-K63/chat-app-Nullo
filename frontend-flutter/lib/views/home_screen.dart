import 'dart:io';

import 'package:app_chat_nullo/apis/api_service.dart';
import 'package:app_chat_nullo/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();

  dynamic users = [];
  bool isLoading = true;
  String errorMessage = '';
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      var response = await _apiService.get("user");
      setState(() {
        users = response["data"] ?? [];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Failed to load users";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final currentUserEmail = userProvider.email;

    final currentUser = users.firstWhere(
          (user) => user["email"] == currentUserEmail,
      orElse: () => {},
    );
    final filteredUsers = users.where((user) => user["email"] != currentUserEmail).toList();

    String avatarUrl = currentUser["profile"]?["avatar"]?["filePath"] ?? "";

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat App'),
        backgroundColor: Colors.blueGrey,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: fetchUsers,
          ),
          GestureDetector(
            onTap: () {
              showMenu(
                context: context,
                position: RelativeRect.fromLTRB(1000, 80, 10, 0),
                items: [
                  PopupMenuItem(
                    value: "profile",
                    child: Text("Profile"),
                    onTap: () => Navigator.pushNamed(context, '/profile'),
                  ),
                  PopupMenuItem(
                    value: "account",
                    child: Text("Account"),
                    onTap: () => Navigator.pushNamed(context, '/account'),
                  ),

                ],
              );
            },
            child: CircleAvatar(
                radius: 25,
                backgroundImage: avatarUrl.isNotEmpty
                 ? NetworkImage(avatarUrl)
                  : AssetImage("assets/default_avatar.png"),
            ),
          ),
          SizedBox(width: 15),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage))
          : Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search users...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 3,
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      leading: CircleAvatar(
                        backgroundColor: Colors.blueGrey,
                        child: Text(
                          filteredUsers[index]["username"].substring(0, 1).toUpperCase(),
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                      title: Text(
                        filteredUsers[index]["username"],
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      subtitle: Text(filteredUsers[index]["email"], style: TextStyle(color: Colors.grey[700])),
                      trailing: Icon(Icons.chat_bubble, color: Colors.blueGrey),
                      onTap: () {
                        print('Navigating to ChatScreen with user: ${filteredUsers[index]}');
                        Navigator.pushNamed(context, '/chat', arguments: filteredUsers[index]);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/login');
        },
        backgroundColor: Colors.blueGrey,
        child: Icon(Icons.exit_to_app, color: Colors.white),
      ),
    );
  }
}