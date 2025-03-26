import 'package:app_chat_nullo/apis/api_service.dart';

class ChatService {
  final _apiService = ApiService();

  Future<Map<String, dynamic>> getConversation(String id) async {
    final response = await _apiService.get("conversation/create/$id");

    return response;
  }

  Future<Map<String, dynamic>> getMessage(String conversationId) async {
    final response = await _apiService.get("message/$conversationId");

    return response;
  }

  Future<Map<String, dynamic>> createConversation(String senderId, String receiverId) async {
    final response = await _apiService.post("conversation/create", {
      "senderId": senderId,
      "receiverId": receiverId,
    });

    return response;
  }

  Future<Map<String, dynamic>> createMessage(String text, String sender, String receiver, String conversation) async {
    final response = await _apiService.post("message/create", {
      "text": text,
      "sender": sender,
      "receiver": receiver,
      "conversation": conversation,
    });

    return response;
  }

}