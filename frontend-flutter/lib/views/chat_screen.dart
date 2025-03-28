import 'package:app_chat_nullo/apis/services/chat_service.dart';
import 'package:app_chat_nullo/models/message_model.dart';
import 'package:app_chat_nullo/providers/user_provider.dart';
import 'package:app_chat_nullo/utils/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();

  Map<String, dynamic>? selectedUser;
  String conversationId = '';
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final SocketService _socketService = SocketService();
  final List<Message> _messages = [];
  String? _currentUserId;
  String? _selectedReceiverId;
  bool _isConnected = false;
  List<dynamic> _onlineUsers = [];
  late StreamSubscription _messageSubscription;
  late StreamSubscription _usersSubscription;
  late StreamSubscription _connectionSubscription;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is Map<String, dynamic>) {
        selectedUser = args['user'];
        conversationId = args['conversationId'];
        _selectedReceiverId = selectedUser?["_id"];
        _initializeChat();
      }
    });


  }

  Future<void> _getMessage(String conversationId) async {
    try {
      final response = await _chatService.getMessage(conversationId);

        List<dynamic> messagesData = response["data"];

        setState(() {
          _messages.clear();
          _messages.addAll(messagesData.map((msg) => Message.fromJson(msg)).toList());
        });

        _scrollToBottom();

    } catch (e) {
      print("Error fetching messages: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load messages. Try again.")),
      );
    }
  }

  Future<void> _storeMessage(BuildContext context, String message) async{
    try{
      await _chatService.createMessage(message, _currentUserId!, _selectedReceiverId!, conversationId);
    }
    catch(e){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Can't send message. Try again.")));
      print("Error: $e");
    }
  }

  void _initializeChat() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _currentUserId = userProvider.id;



    if (_currentUserId != null) {
      _socketService.initSocket(_currentUserId!);

      _messageSubscription = _socketService.onMessage.listen((data) {
        print("data : $data");
        setState(() {
          _messages.add(Message(
            senderId: data['senderId'],
            receiverId: data['receiverId'],
            text: data['text'],
            timestamp: DateTime.now().toUtc(),
          ));
        });
        _scrollToBottom();
      });

      _usersSubscription = _socketService.onUsersUpdate.listen((users) {
        setState(() {
          _onlineUsers = users;
        });
      });

      _connectionSubscription = _socketService.onConnectionStatus.listen((status) {
        setState(() {
          _isConnected = status;
        });
      });

      if (conversationId.isNotEmpty) {
        _getMessage(conversationId);
      }
    }
  }

  void _scrollToBottom() {
    // Add a slight delay to ensure the list view has been updated
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty ||
        _selectedReceiverId == null ||
        _currentUserId == null) {
      return;
    }

    final messageText = _messageController.text;
    _messageController.clear();

    setState(() {
      _messages.add(Message(
        senderId: _currentUserId!,
        receiverId: _selectedReceiverId!,
        text: messageText,
        timestamp: DateTime.now(),
      ));
    });

    _socketService.sendMessage(
      senderId: _currentUserId!,
      receiverId: _selectedReceiverId!,
      text: messageText,
    );

    _scrollToBottom();
    _storeMessage(context, messageText);
  }

  @override
  void dispose() {
    _messageSubscription.cancel();
    _usersSubscription.cancel();
    _connectionSubscription.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    _socketService.disconnect();
    super.dispose();
  }

  String _formatTimestamp(DateTime timestamp) {
    return DateFormat('HH:mm').format(timestamp);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.blue.shade200,
              child: Text(
                (selectedUser?['username'] ?? 'U')[0].toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedUser?['username'] ?? _selectedReceiverId ?? 'Unknown User',
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  _isConnected ? 'Connected' : 'Disconnected',
                  style: TextStyle(
                    fontSize: 12,
                    color: _isConnected ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 15),
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isConnected ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.grey.shade100,
              child: ListView.builder(
                key: const PageStorageKey('messageList'),
                controller: _scrollController,
                padding: const EdgeInsets.all(10),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final bool isMe = message.senderId == _currentUserId;

                  return _buildMessageItem(message, isMe);
                },
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  color: Colors.blue,
                  onPressed: () {}, // Placeholder for attachment functionality
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade200,
                    ),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send_rounded),
                  color: Colors.blue,
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(Message message, bool isMe) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue.shade200,
              child: Text(
                (selectedUser?['username'] ?? 'U')[0].toUpperCase(),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isMe ? Colors.blue : Colors.white,
              borderRadius: BorderRadius.circular(20).copyWith(
                bottomLeft: isMe ? const Radius.circular(20) : const Radius.circular(0),
                bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 1,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  message.text,
                  style: TextStyle(
                    color: isMe ? Colors.white : Colors.black,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatTimestamp(message.timestamp),
                  style: TextStyle(
                    color: isMe ? Colors.white.withOpacity(0.7) : Colors.grey,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          if (isMe) const SizedBox(width: 8),
        ],
      ),
    );
  }
}