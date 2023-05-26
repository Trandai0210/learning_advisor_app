import 'dart:convert';
import 'package:edubot/answer/answer_model.dart';
import 'package:http/http.dart';

class AnswerRepository{
  final String token;
  AnswerRepository(this.token);
  Future<List<Answer>> getAnswers() async {
    String endpoint = 'https://localhost:44302/api/Answer/List';
    Response response = await get(Uri.parse(endpoint), headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    if(response.statusCode == 200){
      final List result = jsonDecode(response.body);
      return result.map((e) => Answer.fromJson(e)).toList();
    } else {
      throw Exception(response.reasonPhrase);
    }
  }

  Future<bool> addAnswer(String content) async {
    content = Uri.encodeComponent(content);
    String endpoint = "https://localhost:44302/api/Answer/Add?content=$content";
    Response response = await post(Uri.parse(endpoint), headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    if(response.statusCode == 200){
      return true;
    }
    return false;
  }

  Future<bool> deleteAnswer(int id) async {
    String endpoint = "https://localhost:44302/api/Answer/Delete/$id";
    Response response = await delete(Uri.parse(endpoint), headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    if(response.statusCode ==200){
      return true;
    }
    return false;
  }

  Future<bool> updateAnswer(String id, String content) async {
    content = Uri.encodeComponent(content);
    String endpoint = "https://localhost:44302/api/Answer/Update?answerId=$id&content=$content";
    Response response = await put(Uri.parse(endpoint), headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    if(response.statusCode == 200){
      return true;
    }
    return false;
  }
}