class Chat{
  final String message;
  final int chatIndex;

  Chat(this.message, this.chatIndex);

  factory Chat.fromJson(Map<String, dynamic> json) => Chat(json["msg"], json["chatIndex"]);
}