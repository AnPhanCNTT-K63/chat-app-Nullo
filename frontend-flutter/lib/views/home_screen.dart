import 'package:app_chat_nullo/apis/services/chat_service.dart';
import 'package:app_chat_nullo/apis/services/user_service.dart';
import 'package:app_chat_nullo/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final UserService _userService = UserService();
  final ChatService _chatService = ChatService();
  late AnimationController _animationController;
  late Animation<double> _animation;

  String? conversationId;
  List<dynamic> users = [];
  bool isLoading = true;
  String errorMessage = '';
  TextEditingController searchController = TextEditingController();
  List<dynamic> filteredUsersList = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    fetchUsers();

    // Add listener for search functionality
    searchController.addListener(_filterUsers);
  }

  @override
  void dispose() {
    _animationController.dispose();
    searchController.removeListener(_filterUsers);
    searchController.dispose();
    super.dispose();
  }

  void _filterUsers() {
    final query = searchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() {
        filteredUsersList = List.from(users);
      });
      return;
    }

    setState(() {
      filteredUsersList = users.where((user) =>
      user["username"]?.toLowerCase().contains(query) ||
          user["email"]?.toLowerCase().contains(query)
      ).toList();
    });
  }

  Future<void> fetchUsers() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    _animationController.forward(from: 0.0);

    try {
      var response = await _userService.getAllUsers();
      setState(() {
        users = response["data"] ?? [];
        filteredUsersList = List.from(users);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Failed to load users. Pull down to refresh.";
        isLoading = false;
      });
    }
  }

  Future<void> _openChatScreen(BuildContext context, dynamic user, String currentUserId) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Show loading indicator
    scaffoldMessenger.showSnackBar(
      const SnackBar(
        content: Text("Opening chat..."),
        duration: Duration(seconds: 1),
      ),
    );

    try {
      final response = await _chatService.createConversation(currentUserId, user["_id"]);
      print(response);
      conversationId = response["data"]["_id"];

      if (!mounted) return;

      Navigator.pushNamed(
        context,
        '/chat',
        arguments: {
          'user': user,
          'conversationId': conversationId,
        },
      );
    } catch (e) {
      print(e);
      if (!mounted) return;

      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 10),
              Flexible(
                child: Text("Couldn't open chat. Try again."),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: () => _openChatScreen(context, user, currentUserId),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final currentUserEmail = userProvider.email;
    final currentTheme = Theme.of(context);

    // Get screen dimensions for responsive design
    final screenSize = MediaQuery.of(context).size;
    final smallScreen = screenSize.width < 360;
    final padding = EdgeInsets.all(screenSize.width * 0.04);

    final currentUser = users.firstWhere(
          (user) => user["email"] == currentUserEmail,
      orElse: () => {},
    );

    final displayedUsers = filteredUsersList.where((user) =>
    user["email"] != currentUserEmail
    ).toList();

    String avatarUrl = currentUser["profile"]?["avatar"]?["filePath"] ?? "";

    return Scaffold(
      backgroundColor: currentTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Chats', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: currentTheme.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: fetchUsers,
          ),
          GestureDetector(
            onTap: () async {
              final RenderBox button = context.findRenderObject() as RenderBox;
              final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

              final Offset buttonPosition = button.localToGlobal(Offset.zero, ancestor: overlay);
              final double screenWidth = MediaQuery.of(context).size.width;
              final double menuWidth = 180; // Adjust based on menu width
              final double menuHeight = 160; // Approximate menu height

              // Position the menu properly at the right edge of the avatar
              final double menuX = screenWidth - menuWidth - 10; // Align to right side
              final double menuY = buttonPosition.dy + button.size.height + 5; // Slightly below the avatar

              final result = await showMenu(
                context: context,
                position: RelativeRect.fromLTRB(
                  350, // Left boundary (aligned to the right)
                  80, // Top position (below the avatar)
                  screenWidth - 10, // Right boundary (keep within screen)
                  menuY + menuHeight, // Bottom boundary (enough space for items)
                ),
                items: [
                  PopupMenuItem(
                    value: "profile",
                    child: Row(
                      children: [
                        Icon(Icons.person, color: currentTheme.iconTheme.color),
                        const SizedBox(width: 8),
                        const Text("Profile"),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: "account",
                    child: Row(
                      children: [
                        Icon(Icons.settings, color: currentTheme.iconTheme.color),
                        const SizedBox(width: 8),
                        const Text("Account"),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: "logout",
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.redAccent),
                        const SizedBox(width: 8),
                        const Text("Logout", style: TextStyle(color: Colors.redAccent)),
                      ],
                    ),
                  ),
                ],
              );

              if (!mounted) return;

              if (result == "profile" && currentUser["_id"] != null) {
                Navigator.pushNamed(
                  context,
                  '/profile',
                  arguments: {
                    'userId': currentUser["_id"],
                  },
                );
              } else if (result == "account") {
                Navigator.pushNamed(context, '/account');
              } else if (result == "logout") {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: currentTheme.primaryColorLight,
                child: avatarUrl.isNotEmpty
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: CachedNetworkImage(
                    imageUrl: avatarUrl,
                    placeholder: (context, url) => const CircularProgressIndicator(),
                    errorWidget: (context, url, error) => const Icon(Icons.person),
                    fit: BoxFit.cover,
                    width: 36,
                    height: 36,
                  ),
                )
                    : Text(
                  currentUser["username"]?.substring(0, 1).toUpperCase() ?? "?",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: fetchUsers,
        child: isLoading
            ? FadeTransition(
          opacity: _animation,
          child: const Center(child: CircularProgressIndicator()),
        )
            : errorMessage.isNotEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.red),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  errorMessage,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: fetchUsers,
                icon: const Icon(Icons.refresh),
                label: const Text("Try Again"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        )
            : Padding(
          padding: padding,
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: currentTheme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: "Search users...",
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        searchController.clear();
                      },
                    )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: currentTheme.cardColor,
                    contentPadding: EdgeInsets.symmetric(vertical: smallScreen ? 12 : 16),
                  ),
                  textInputAction: TextInputAction.search,
                ),
              ),
              SizedBox(height: smallScreen ? 8 : 16),
              Expanded(
                child: displayedUsers.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        searchController.text.isNotEmpty
                            ? Icons.search_off
                            : Icons.people_outline,
                        size: 60,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          searchController.text.isNotEmpty
                              ? "No users found matching '${searchController.text}'"
                              : "No users available",
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  itemCount: displayedUsers.length,
                  itemBuilder: (context, index) {
                    final user = displayedUsers[index];
                    final userAvatarUrl = user["profile"]?["avatar"]?["filePath"] ?? "";

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: currentTheme.cardColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                            vertical: smallScreen ? 4 : 8,
                            horizontal: smallScreen ? 8 : 16,
                          ),
                          leading: CircleAvatar(
                            radius: smallScreen ? 20 : 25,
                            backgroundColor: currentTheme.primaryColor.withOpacity(0.2),
                            child: userAvatarUrl.isNotEmpty
                                ? ClipRRect(
                              borderRadius: BorderRadius.circular(smallScreen ? 20 : 25),
                              child: CachedNetworkImage(
                                imageUrl: userAvatarUrl,
                                placeholder: (context, url) => CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: currentTheme.primaryColor,
                                ),
                                errorWidget: (context, url, error) => Text(
                                  user["username"].substring(0, 1).toUpperCase(),
                                  style: TextStyle(
                                    fontSize: smallScreen ? 16 : 20,
                                    fontWeight: FontWeight.bold,
                                    color: currentTheme.primaryColor,
                                  ),
                                ),
                                fit: BoxFit.cover,
                                width: smallScreen ? 40 : 50,
                                height: smallScreen ? 40 : 50,
                              ),
                            )
                                : Text(
                              user["username"].substring(0, 1).toUpperCase(),
                              style: TextStyle(
                                fontSize: smallScreen ? 16 : 20,
                                fontWeight: FontWeight.bold,
                                color: currentTheme.primaryColor,
                              ),
                            ),
                          ),
                          title: Text(

                              user["username"],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: smallScreen ? 14 : 16,
                              ),
                              overflow: TextOverflow.ellipsis,

                          ),
                          subtitle: Text(
                              user["email"],
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: smallScreen ? 12 : 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,

                          ),
                          trailing: LayoutBuilder(
                            builder: (context, constraints) {
                              // Use a menu icon for small screens
                              if (constraints.maxWidth < 100 || smallScreen) {
                                return IconButton(
                                  icon: const Icon(Icons.more_vert, size: 24, color: Colors.black54),
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                                      ),
                                      builder: (context) => Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ListTile(
                                            leading: const Icon(Icons.person, color: Colors.blueAccent),
                                            title: const Text("Profile", style: TextStyle(fontWeight: FontWeight.w500)),
                                            onTap: () {
                                              Navigator.pop(context);
                                              Navigator.pushNamed(
                                                context,
                                                '/profile',
                                                arguments: {'userId': user["_id"]},
                                              );
                                            },
                                          ),
                                          ListTile(
                                            leading: const Icon(Icons.chat_bubble_outline, color: Colors.green),
                                            title: const Text("Chat", style: TextStyle(fontWeight: FontWeight.w500)),
                                            onTap: () {
                                              Navigator.pop(context);
                                              _openChatScreen(context, user, currentUser["_id"]);
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              }

                              // For larger screens, show buttons with enhanced UI
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Profile button with enhanced UI
                                  OutlinedButton(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/profile',
                                        arguments: {'userId': user["_id"]},
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      foregroundColor: currentTheme.primaryColor,
                                      side: BorderSide(color: currentTheme.primaryColor, width: 1.5),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                    ),
                                    child: const Text("Profile"),
                                  ),
                                  const SizedBox(width: 8),
                                  // Chat button as a modern circular icon button
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: IconButton(
                                      onPressed: () {
                                        _openChatScreen(context, user, currentUser["_id"]);
                                      },
                                      icon: const Icon(Icons.chat, color: Colors.white, size: 20),
                                      style: IconButton.styleFrom(
                                        backgroundColor: currentTheme.primaryColor,
                                        shape: const CircleBorder(),
                                        padding: const EdgeInsets.all(12), // Adjust size
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),

                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: AnimatedOpacity(
        opacity: 1.0,
        duration: const Duration(milliseconds: 300),
        child: smallScreen
            ? FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Logout"),
                  content: const Text("Are you sure you want to logout?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Logout"),
                    ),
                  ],
                );
              },
            );
          },
          backgroundColor: Colors.redAccent,
          child: const Icon(Icons.exit_to_app),
        )
            : FloatingActionButton.extended(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Logout"),
                  content: const Text("Are you sure you want to logout?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Logout"),
                    ),
                  ],
                );
              },
            );
          },
          backgroundColor: Colors.redAccent,
          icon: const Icon(Icons.exit_to_app),
          label: const Text("Logout"),
        ),
      ),
    );
  }
}