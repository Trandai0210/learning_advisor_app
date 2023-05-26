import 'package:edubot/screens/chat.dart';
import 'package:edubot/screens/dashboard.dart';
import 'package:edubot/screens/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<String> getToken(String email) async {
    email = Uri.encodeComponent(email);
    String endpoint = "https://localhost:44302/api/Auth/GetToken?email=$email";
    Response response = await post(Uri.parse(endpoint));
    if(response.statusCode == 200){
      return response.body.toString();
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if(snapshot.hasData){
            return Scaffold(
              body: FutureBuilder(
                future: getToken(snapshot.data!.email.toString()),
                builder: (context, snapshot) {
                  if(snapshot.hasData){
                    String token = snapshot.data.toString();
                    Map<String, dynamic> decodedToken = JwtDecoder.decode(snapshot.data.toString());
                    return FutureBuilder(
                      future: _prefs,
                      builder: (context,snapshot){
                        if(snapshot.hasData){
                          SharedPreferences? pref = snapshot.data;
                          pref!.setString("token", token);
                          pref.setString("userid", decodedToken['userid']);
                          pref.setString("name", decodedToken['name']);
                          pref.setString("image", decodedToken['image']);
                          if(decodedToken['status'] == "True"){
                            if(decodedToken['role'] == "admin"){
                              return const DashBoardScreen();
                            } else {
                              return const ChatScreen();
                            }
                          } else {
                            return AlertDialog(
                              title: const Text("Thông báo!"),
                              content: Container(
                                child: const Text("Không thể đăng nhập. Bạn đã bị chặn bởi ứng dụng!"),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () async {
                                    FirebaseAuth.instance.signOut();
                                  },
                                  child: const Text("OK"),
                                ),
                              ],
                            );
                          }
                        }
                        return Container();
                      }
                    );
                  } else {
                    return Center(child: const CircularProgressIndicator());
                  }
                }
              )
            );
          }
          else{
            return const LoginScreen();
          }
        },
      ),
    );
  }
}
