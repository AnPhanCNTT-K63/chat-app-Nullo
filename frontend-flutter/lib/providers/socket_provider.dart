import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


class SocketProvider with ChangeNotifier {
  late IO.Socket _socket;
  final String _socketUrl = dotenv.env['API_URL'] ?? 'http://127.0.0.1:3002';

  IO.Socket get socket => _socket;

  void connect(String userId) {
    _socket = IO.io(_socketUrl, <String, dynamic>{
      'transports': ['websocket'],
    });

    _socket.onConnect((_) {
      print('Connected to WebSocket');
      _socket.emit('addUser', userId);
    });

    _socket.on('getMessage', (data) {
      print('New message: ${data['text']}');
      notifyListeners(); // Notify UI of updates if needed
    });
  }

  void sendMessage(String senderId, String receiverId, String text) {
    _socket.emit('sendMessage', {'senderId': senderId, 'receiverId': receiverId, 'text': text});
  }

  void disconnect() {
    _socket.disconnect();
  }
}
