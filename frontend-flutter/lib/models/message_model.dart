class Message {
  final String senderId;
  final String receiverId;
  final String text;
  final DateTime timestamp;

  Message({
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.timestamp,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      senderId: json["sender"] ?? "",
      receiverId: json["receiver"] ?? "",
      text: json["text"] ?? "[No message]",
      timestamp: DateTime.tryParse(json["createdAt"] ?? "") ?? DateTime.now(),
    );
  }
}
