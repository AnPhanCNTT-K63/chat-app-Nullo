  import 'package:socket_io_client/socket_io_client.dart' as IO;
  import 'package:flutter_dotenv/flutter_dotenv.dart';
  import 'dart:async';

  class SocketService {
    // Socket instance
    late IO.Socket socket;
    final String SOCKET_URL = dotenv.env['SOCKET_URL_DEV'] ?? "wss://10.0.2.2:3000";

    // Stream controllers for events
    final _messageController = StreamController<Map<String, dynamic>>.broadcast();
    final _usersController = StreamController<List<dynamic>>.broadcast();
    final _connectionStatusController = StreamController<bool>.broadcast();

    // Streams that UI components can listen to
    Stream<Map<String, dynamic>> get onMessage => _messageController.stream;
    Stream<List<dynamic>> get onUsersUpdate => _usersController.stream;
    Stream<bool> get onConnectionStatus => _connectionStatusController.stream;

    // Singleton pattern
    static final SocketService _instance = SocketService._internal();

    factory SocketService() {
      return _instance;
    }

    SocketService._internal();

    // Initialize socket connection
    void initSocket(String userId) {
      socket = IO.io(SOCKET_URL, <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': true,
      });

      _setupSocketListeners();

      // Connect and add user once socket is ready
      socket.onConnect((_) {
        _connectionStatusController.add(true);
        addUser(userId);
      });
    }

    // Setup socket event listeners
    void _setupSocketListeners() {
      socket.onDisconnect((_) => _connectionStatusController.add(false));

      socket.on('getMessage', (data) {
        _messageController.add(data);
      });

      socket.on('getUsers', (users) {
        _usersController.add(users);
      });
    }

    // Add user to socket server
    void addUser(String userId) {
      socket.emit('addUser', userId);
    }

    // Send message to another user
    void sendMessage({
      required String senderId,
      required String receiverId,
      required String text,
    }) {
      socket.emit('sendMessage', {
        'senderId': senderId,
        'receiverId': receiverId,
        'text': text,
      });
    }

    // Get current list of online users
    List<dynamic> getUsers() {
      List<dynamic> users = [];
      socket.on('getUsers', (data) {
        users = data;
      });
      return users;
    }

    // Get user by ID
    Map<String, dynamic>? getUser(String userId) {
      List<dynamic> users = getUsers();
      final user = users.firstWhere(
            (user) => user['userId'] == userId,
        orElse: () => null,
      );
      return user;
    }

    // Disconnect socket
    void disconnect() {
      socket.dispose();
    }

    // Dispose resources
    void dispose() {
      _messageController.close();
      _usersController.close();
      _connectionStatusController.close();
      socket.dispose();
    }
  }