import 'package:app_chat_nullo/apis/api_service.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService apiService = ApiService();
  dynamic users = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchUsers(); // Call API when the screen loads
  }

  Future<void> fetchUsers() async {
    try {
      var response = await apiService.getRequest("users"); // Adjust endpoint
      print(response);
      setState(() {
        users = response["data"] ?? []; // Assuming response is a list of users
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Failed to load users";
        print(e);
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Show loader while fetching
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage)) // Show error if any
          : ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(users[index]["username"]),
            subtitle: Text(users[index]["email"]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/login');
        },
        child: Icon(Icons.login),
      ),
    );
  }
}
