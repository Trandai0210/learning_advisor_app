import 'dart:convert';
import 'package:edubot/user/user_model.dart';
import 'package:http/http.dart';

class UserRepository{
  final String token;
  UserRepository(this.token);
  Future<List<User>> getUser() async {
    String endpoint = 'https://localhost:44302/api/User/List';
    Response response = await get(Uri.parse(endpoint), headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    final List result = jsonDecode(response.body);
    List<User> data = result.map((e) => User.fromJson(e)).toList();
    return data; 
  }

  Future<bool> addUser(String name, String gmail, String phone, String image, String dob) async {
    name = Uri.encodeComponent(name);
    String endpoint = 'https://localhost:44302/api/User/Add?name=$name&gmail=$gmail&phone=$phone&image=$image&dob=$dob';
    Response response = await post(Uri.parse(endpoint), headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    return response.statusCode == 200 ? true : false;
  }

  Future<bool> updateUser(int id,String name, String gmail, String phone, String image, String dob) async {
    String endpoint = 'https://localhost:44302/api/User/Update?id=$id&name=$name&gmail=$gmail&phone=$phone&image=$image&dob=$dob';
    Response response = await put(Uri.parse(endpoint), headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    return response.statusCode == 200 ? true : false;
  }

  Future<bool> deleteUser(int id) async {
    String endpoint = "https://localhost:44302/api/User/Delete/$id";
    Response response = await delete(Uri.parse(endpoint), headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    return response.statusCode == 200 ? true : false;
  }

  Future<bool> blockUser(int id) async {
    String endpoint = "https://localhost:44302/api/User/Block/$id";
    Response response = await post(Uri.parse(endpoint), headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    return response.statusCode == 200 ? true : false;
  }

  Future<bool> unBlockUser(int id) async {
    String endpoint = "https://localhost:44302/api/User/UnBlock/$id";
    Response response = await post(Uri.parse(endpoint), headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    return response.statusCode == 200 ? true : false;
  }

  Future<bool> setPermission(int userId, int permissionId) async {
    String endpoint = "https://localhost:44302/api/User/SetPermission?userId=$userId&permissionId=$permissionId";
    Response response = await post(Uri.parse(endpoint), headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    return response.statusCode == 200 ? true : false;
  }

  Future<User> getUserById(int id) async {
    String endpoint = "https://localhost:44302/api/User/GetById?id=$id";
    Response response = await get(Uri.parse(endpoint), headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    final result = jsonDecode(response.body);
    User data = User.fromJson(result);
    return data;
  } 

  Future<bool> updateImage(int id, String image) async {
    image = Uri.encodeComponent(image);
    String endpoint = "https://localhost:44302/api/User/UpdateImage?id=$id&image=$image";
    Response response = await get(Uri.parse(endpoint), headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    final result = jsonDecode(response.body);
    User data = User.fromJson(result);
    return response.statusCode == 200 ? true : false;
  }

  Future<User> getUserByEmail(String email) async {
    String endpoint = "https://localhost:44302/api/User/GetByEmail?email=$email";
    Response response = await post(Uri.parse(endpoint), headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    final result = jsonDecode(response.body);
    User data = User.fromJson(result);
    return data;
  }
}