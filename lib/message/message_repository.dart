import 'dart:convert';
import 'package:edubot/message/message_model.dart';
import 'package:http/http.dart';

class MessageRepository{
  final String token;
  MessageRepository(this.token);
  Future<List<Message>> getMessages() async {
    String endpoint = "https://localhost:44302/api/Message/List";
    Response response = await get(Uri.parse(endpoint), headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    final List result = jsonDecode(response.body);
    List<Message> data = result.map((e) => Message.fromJson(e)).toList();
    return data;
  }

  Future<List<Message>> getMessagesByFacultyId(int id) async {
    String endpoint = "https://localhost:44302/api/Message/ListByFacultyId?id=$id";
    Response response = await get(Uri.parse(endpoint), headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    final List result = jsonDecode(response.body);
    List<Message> data = result.map((e) => Message.fromJson(e)).toList();
    return data;
  }

  Future<bool> addMessage(String content, int userId,int facultyId) async {
    content = Uri.encodeComponent(content);
    String endpoint = "https://localhost:44302/api/Message/Add?content=$content&userid=$userId&facultyId=$facultyId";
    Response response = await post(Uri.parse(endpoint), headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    return response.statusCode == 200 ? true : false;
  }

  Future<bool> deleteMessage(int id) async {
    String endpoint = "https://localhost:44302/api/Message/Delete/$id";
    Response response = await delete(Uri.parse(endpoint), headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    return response.statusCode == 200 ? true : false;
  }
}