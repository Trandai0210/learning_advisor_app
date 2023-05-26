import 'dart:convert';
import 'package:edubot/faculty/faculty_model.dart';
import 'package:http/http.dart';

class FacultyRepository{
  final String token;
  FacultyRepository(this.token);
  Future<List<Faculty>> getFaculties() async {
    String endpoint = 'https://localhost:44302/api/Faculty/List';
    Response response = await get(Uri.parse(endpoint),headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    if(response.statusCode == 200){
      final List result = jsonDecode(response.body);
      List<Faculty> data = result.map((e) => Faculty.fromJson(e)).toList();
      return data;
    } else {
      throw Exception(response.reasonPhrase);
    }
  }

  Future<bool> addFaculty(String name) async {
    name = Uri.encodeComponent(name);
    String endpoint = "https://localhost:44302/api/Faculty/Add?name=$name";
    Response response = await post(Uri.parse(endpoint),headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    if(response.statusCode == 200){
      return true;
    } else {
      throw Exception(response.reasonPhrase);
    }
  }

  Future<bool> deleteFaculty(int id) async {
    String endpoint = "https://localhost:44302/api/Faculty/Delete/$id";
    Response response = await delete(Uri.parse(endpoint),headers: {
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

  Future<bool> updateFaculty(int id, String content) async {
    content = Uri.encodeComponent(content);
    String endpoint = "https://localhost:44302/api/Faculty/Update?facultyID=$id&name=$content";
    Response response = await put(Uri.parse(endpoint),headers: {

    });
    if(response.statusCode == 200){
      return true;
    } else {
      throw Exception(response.reasonPhrase);
    }
  }
}