import 'dart:convert';
import 'package:edubot/permission/perrmisson_model.dart';
import 'package:http/http.dart';

class PermissionRepository{
  final String token;
  PermissionRepository(this.token);
  Future<List<Permission>> getPermissions() async {
    String endpoint = 'https://localhost:44302/api/Permission/List';
    Response response = await get(Uri.parse(endpoint),headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    if(response.statusCode == 200){
      final List result = jsonDecode(response.body);
      List<Permission> data = result.map((e) => Permission.fromJson(e)).toList();
      return data;
    } else {
      throw Exception(response.reasonPhrase);
    }
  }

  Future<bool> addPermission(String permissionName) async {
    permissionName = Uri.encodeComponent(permissionName);
    String endpoint = "https://localhost:44302/api/Permission/Add?permissionName=$permissionName";
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

  Future<bool> deletePermission(int id) async {
    String endpoint = "https://localhost:44302/api/Permission/Delete/$id";
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

  Future<bool> updatePermission(int permissionID, String permissionName) async {
    permissionName = Uri.encodeComponent(permissionName);
    String endpoint = "https://localhost:44302/api/Permission/Update?permissionID=$permissionID&permissionName=$permissionName";
    Response response = await put(Uri.parse(endpoint),headers: {
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
}