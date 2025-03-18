import 'package:app_chat_nullo/apis/api_service.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService apiService = ApiService();
  dynamic users = [];
  dynamic filteredUsers = [];
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
      var response = await apiService.getRequest("users"); // Adjust endpoint
      setState(() {
        users = response ?? [];
        filteredUsers = users;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Failed to load users";
        isLoading = false;
      });
    }
  }

  void filterUsers(String query) {
    setState(() {
      filteredUsers = users.where((user) {
        return user["username"].toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat App'),
        backgroundColor: Colors.blueGrey,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: fetchUsers,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == "profile") {
                Navigator.pushNamed(context, '/profile');
              } else if (value == "account") {
                Navigator.pushNamed(context, '/account');
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: "profile", child: Text("Profile")),
              PopupMenuItem(value: "account", child: Text("Account")),
            ],
          ),
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
              onChanged: filterUsers,
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
