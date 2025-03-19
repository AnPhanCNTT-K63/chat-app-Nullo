import 'dart:io';
import 'package:app_chat_nullo/apis/services/media_service.dart';
import 'package:app_chat_nullo/apis/services/user_service.dart';
import 'package:app_chat_nullo/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();
  final MediaService _mediaService = MediaService();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();

  String _avatarUrl = "";
  String _originalAvatarUrl = "";

  bool _isEditing = false;
  bool _isLoading = false;
  bool _isFetching = true;
  bool _isChangeImage = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try{
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      final response = await _userService.getProfile(userProvider.id.toString());
      _firstNameController.text = response["data"]["profile"]["firstName"];
      _lastNameController.text = response["data"]["profile"]["lastName"];
      _phoneController.text = response["data"]["profile"]["phone"];
      _birthdayController.text = DateFormat('yyyy-MM-dd').format(
          DateTime.parse(response["data"]["profile"]["birthday"])
      );
      _avatarUrl = response["data"]["profile"]["avatar"]["filePath"];
      _originalAvatarUrl = _avatarUrl;
    }
    catch(e){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Something went wrong. Try again.")));
    }
    finally{
      setState(() {
        _isFetching = false;
      });
    }
  }

  void _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _avatarUrl = image.path;
        _isChangeImage = true;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    // Try to parse the current date from text field or use current date as fallback
    DateTime initialDate;
    try {
      initialDate = DateFormat('yyyy-MM-dd').parse(_birthdayController.text);
    } catch (e) {
      initialDate = DateTime.now();
    }

    // Limit date selection to reasonable range
    final DateTime firstDate = DateTime(1900);
    final DateTime lastDate = DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate.isAfter(lastDate) ? lastDate : initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.blueGrey,
            colorScheme: ColorScheme.light(primary: Colors.blueGrey),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _birthdayController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _cancelEdit() {
    setState(() {
      // Restore original values
      _fetchUserData();
      _avatarUrl = _originalAvatarUrl;
      _isChangeImage = false;
      _isEditing = false;
    });
  }

  void _saveChanges(BuildContext context) async {
    if (_firstNameController.text.isEmpty || _lastNameController.text.isEmpty || _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("All fields are required")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try{
      final response = await _userService.updateProfile(_firstNameController.text, _lastNameController.text,  _phoneController.text, _birthdayController.text);
      _firstNameController.text = response["data"]["firstName"];
      _lastNameController.text = response["data"]["lastName"];
      _phoneController.text = response["data"]["phone"];
      _birthdayController.text = response["data"]["birthday"];

      if(_isChangeImage){
        await _mediaService.uploadAvatar(_avatarUrl);
        _isChangeImage = false;
      }
      _originalAvatarUrl = _avatarUrl;
    }
    catch(e){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Something went wrong. Try again.")));
      print(e);
    }


    setState(() {
      _isLoading = false;
      _isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Profile updated successfully")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Profile"),
        backgroundColor: Colors.blueGrey,
      ),
      body: _isFetching
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: _avatarUrl.isNotEmpty
                        ? (_avatarUrl.startsWith('http')
                        ? NetworkImage(_avatarUrl) as ImageProvider
                        : FileImage(File(_avatarUrl)))
                        : AssetImage("assets/default_avatar.png"),
                    onBackgroundImageError: (exception, stackTrace) {
                      print("Image load error: $exception");
                    },
                  ),

                  if (_isEditing) // Show only when editing
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 15,
                          backgroundColor: Colors.blueGrey,
                          child: Icon(Icons.camera_alt, color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // First Name
            Text("First Name", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            TextField(
              controller: _firstNameController,
              enabled: _isEditing,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 15),

            // Last Name
            Text("Last Name", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            TextField(
              controller: _lastNameController,
              enabled: _isEditing,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 15),

            // Phone
            Text("Phone", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            TextField(
              controller: _phoneController,
              enabled: _isEditing,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 15),

            // Birthday with Date Picker
            Text("Birthday", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            TextField(
              controller: _birthdayController,
              enabled: _isEditing,
              readOnly: true, // Make it read-only since we're using date picker
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "YYYY-MM-DD",
                suffixIcon: _isEditing
                    ? IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context),
                )
                    : null,
              ),
              onTap: _isEditing ? () => _selectDate(context) : null,
            ),
            SizedBox(height: 20),

            // Edit Button (Shown only when not editing)
            if (!_isEditing)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isEditing = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text("Tap here to Edit", style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),

            // Save and Cancel Buttons (Only appears when editing is enabled)
            if (_isEditing)
              Row(
                children: [
                  // Save Button
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : () => _saveChanges(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text("Save Changes", style: TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  // Cancel Button
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _cancelEdit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text("Cancel", style: TextStyle(fontSize: 16, color: Colors.white)),
                      ),
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