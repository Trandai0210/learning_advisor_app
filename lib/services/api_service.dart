import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:edubot/constants/api_constants.dart';
import 'package:edubot/models/chat.dart';
import 'package:edubot/question/question_repository.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService{
  static Future<List<Chat>> sendMessage(String message) async{
    try{
      List<Chat> chats = [];
      // String token = await SharedPreferences.getInstance().then((value) => value.getString("token")) ?? "";
      // String answer = await QuestionRepository(token).sendQuestionGetAnswer(message);
      // if(answer != ""){
      //   chats = [Chat(answer, 1)];
      //   return chats;
      // } else {
        var params = {
          "model": "text-davinci-003",
          "prompt": message,
          "max_tokens": 3000,
        };
        var response = await http.post(
          Uri.parse(BASE_URL),
          headers: {
            'Authorization': 'Bearer $API_KEY',
            "Content-Type": "application/json"
          },
          body: jsonEncode(params),
        );
        Map res = jsonDecode(response.body);
        if(res['error'] != null){
          throw HttpException(res['error']['message']);
        }
        
        if(res["choices"].length > 0){
          chats = List.generate(
            res["choices"].length,
            (index) => Chat(
              utf8.decode(res["choices"][index]["text"].toString().codeUnits),
              1
            ),
          );
        }
        return chats;
      // }
    }catch(error){
      log("error: $error");
      rethrow;
    }
  }
}

