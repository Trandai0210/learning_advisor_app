import 'dart:convert';
import 'package:edubot/question/question_model.dart';
import 'package:http/http.dart';

class QuestionRepository{
  final String token;
  QuestionRepository(this.token);
  Future<List<Question>> getQuestions(int page, int size, String? search) async {
    String endpoint = 'https://localhost:44302/api/Question/List';
    Response response = await get(Uri.parse(endpoint), headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    if(response.statusCode == 200){
      final List result = jsonDecode(response.body);
      List<Question> data = result.map((e) => Question.fromJson(e)).toList();
      return data;
    } else {
      throw Exception(response.reasonPhrase);
    }
  }

  Future<bool> addQuestion(String keyword, int answerId) async{
    keyword = Uri.encodeComponent(keyword);
    String endpoint = "https://localhost:44302/api/Question/Add?keyword=$keyword&answerId=$answerId";
    Response response = await post(Uri.parse(endpoint), headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    if(response.statusCode == 200){
      return true;
    } else {
      return false;
    }
  }

  Future<bool> deleteQuestion(int id) async {
    String endpoint = "https://localhost:44302/api/Question/Delete/$id";
    Response response = await delete(Uri.parse(endpoint), headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    if(response.statusCode ==200){
      return true;
    } else {
      throw Exception(response.reasonPhrase);
    }
  }

  Future<bool> updateQuestion(int id, String keyword, int answerId) async{
    keyword = Uri.encodeComponent(keyword);
    String endpoint = "https://localhost:44302/api/Question/Update?questionId=$id&keyword=$keyword&answerId=$answerId";
    Response response = await put(Uri.parse(endpoint), headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    if(response.statusCode == 200){
      return true;
    } else {
      return false;
    }
  }

  Future<String> sendQuestionGetAnswer(String keyword) async {
    keyword = keyword.trim();
    keyword = Uri.encodeComponent(keyword);
    String endpoint = "https://localhost:44302/api/Question/GetAnswer?question=$keyword";
    Response response = await get(Uri.parse(endpoint), headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    if(response.statusCode == 200){
      return response.body.substring(1,response.body.length-1);
    } else {
      return "";
    }
  }
}