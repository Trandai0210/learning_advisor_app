import 'package:edubot/services/api_service.dart';
import 'package:flutter/foundation.dart';
import 'package:edubot/models/chat.dart';

class ChatProvider with ChangeNotifier{
  List<Chat> chats = [];
  List<Chat> get Chats => chats;

  void addUserMessage(String message){
    chats.add(Chat(message, 0));
    notifyListeners();
  }

  Future<void> sendMessageAndGetAnswers(String message) async {
    chats.addAll(await ApiService.sendMessage(message));
    notifyListeners();
  }
}