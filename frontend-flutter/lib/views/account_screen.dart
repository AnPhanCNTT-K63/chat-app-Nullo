import 'package:app_chat_nullo/apis/services/auth_service.dart';
import 'package:app_chat_nullo/apis/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_chat_nullo/providers/user_provider.dart';

class AccountScreen extends StatefulWidget {
  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _userService = UserService();
  final _authService = AuthService();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _currentPasswordController = TextEditingController();

  bool _isLoading = false;
  String _editingField = "";
  late String _originalUsername;
  late String _originalEmail;

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _usernameController.text = userProvider.username ?? "";
    _emailController.text = userProvider.email ?? "";
    _originalUsername = _usernameController.text;
    _originalEmail = _emailController.text;
  }

  void _toggleEditing(String field) {
    setState(() {
      if (_editingField == field) {
        _editingField = "";
      } else {
        _editingField = field;
      }
    });
  }

  void _cancelEditing() {
    setState(() {
      _usernameController.text = _originalUsername;
      _emailController.text = _originalEmail;
      _passwordController.clear();
      _editingField = "";
    });
  }

  Future<void> _showPasswordConfirmationDialog() async {
    _currentPasswordController.clear();
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Your Password'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Please enter your current password to confirm changes:'),
                SizedBox(height: 20),
                TextField(
                  controller: _currentPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Current Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Confirm'),
              onPressed: () {
                Navigator.of(context).pop();
                if (_currentPasswordController.text.isNotEmpty)  {
                  _verifyPasswordAndSaveChanges();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Password cannot be empty")),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _verifyPasswordAndSaveChanges() async {
    setState(() {
      _isLoading = true;
    });

    try {
      print(_currentPasswordController.text);
      await _authService.checkPassword(_currentPasswordController.text);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Authentication failed. Please try again.")),
        );
        print("Update error: $e");
      }

      setState(() {
        _isLoading = false;
      });

      return;
    }

    try {
      final response = await _userService.updateAccount(
        _usernameController.text,
        _emailController.text,
        _passwordController.text,
      );

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.updateUser(response["data"]["username"], response["data"]["email"]);

      setState(() {
        _originalUsername = _usernameController.text;
        _originalEmail = _emailController.text;
        _editingField = "";
        _passwordController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Account updated successfully")),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Something went wrong. Please try again.")),
        );
        print("Update error: $e");
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }


  void _initiateChanges(BuildContext context) async {
    if (_usernameController.text.isEmpty || _emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Username and Email cannot be empty")),
      );
      return;
    }

    _showPasswordConfirmationDialog();
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    required TextEditingController controller,
    required String fieldKey,
    bool obscureText = false,
  }) {
    return Column(
      children: [
        ListTile(
          title: Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          subtitle: _editingField == fieldKey
              ? TextField(
            controller: controller,
            obscureText: obscureText,
            decoration: InputDecoration(
              hintText: "Enter new $label",
              border: OutlineInputBorder(),
            ),
          )
              : Text(value, style: TextStyle(fontSize: 16)),
          trailing: IconButton(
            icon: Icon(
              _editingField == fieldKey ? Icons.close : Icons.edit,
              color: _editingField == fieldKey ? Colors.red : Colors.blueGrey,
            ),
            onPressed: () => _toggleEditing(fieldKey),
          ),
        ),
        Divider(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("My Account"),
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildInfoRow(
              label: "Username",
              value: userProvider.username ?? "Not set",
              controller: _usernameController,
              fieldKey: "username",
            ),
            _buildInfoRow(
              label: "Email",
              value: userProvider.email ?? "Not set",
              controller: _emailController,
              fieldKey: "email",
            ),
            _buildInfoRow(
              label: "Password",
              value: "********",
              controller: _passwordController,
              fieldKey: "password",
              obscureText: true,
            ),
            if (_editingField.isNotEmpty)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : () => _initiateChanges(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text("Save Changes", style: TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _cancelEditing,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text("Cancel", style: TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}