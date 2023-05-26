import 'package:edubot/faculty/faculty_model.dart';
import 'package:edubot/faculty/faculty_repository.dart';
import 'package:edubot/message/message_repository.dart';
import 'package:edubot/screens/answer.dart';
import 'package:edubot/screens/chat.dart';
import 'package:edubot/screens/chat_people.dart';
import 'package:edubot/screens/dashboard.dart';
import 'package:edubot/screens/edit_profile.dart';
import 'package:edubot/screens/faculty.dart';
import 'package:edubot/screens/login.dart';
import 'package:edubot/screens/message.dart';
import 'package:edubot/screens/permission.dart';
import 'package:edubot/screens/question.dart';
import 'package:edubot/screens/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminDrawer extends StatelessWidget {
  const AdminDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if(snapshot.hasData){
          SharedPreferences? pref = snapshot.data;
          String username = pref!.getString('name') ?? "";
          String email = pref.getString('email') ?? "";
          String imageURL = pref.getString('image') ?? "";
          String userId = pref.getString('userid') ?? "";
          return Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                UserAccountsDrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.deepPurple[900],
                  ),
                  accountName: Text(username),
                  accountEmail: Text(email),
                  currentAccountPicture: CircleAvatar(
                    backgroundImage: NetworkImage(
                        imageURL),
                  ),
                  arrowColor: Colors.red,
                  onDetailsPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => EditProfileScreen(userId: int.parse(userId))),
                    );
                  },
                ),
                ListTile(
                  title: const Text('Dashboard'),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const DashBoardScreen()),
                    );
                  },
                ),
                ListTile(
                  title: const Text('Quản lý câu trả lời'),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const AnswerPage()),
                    );
                  },
                ),
                ListTile(
                  title: const Text('Quản lý Khoa'),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const FacultyListView()),
                    );
                  },
                ),
                ListTile(
                  title: const Text('Quản lý quyền'),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const PermissionListView()),
                    );
                  },
                ),
                ListTile(
                  title: const Text('Quản lý câu hỏi'),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const QuestionListView()),
                    );
                  },
                ),
                ListTile(
                  title: const Text('Quản lý tin nhắn'),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const MessageListView()),
                    );
                  },
                ),
                ListTile(
                  title: const Text('Quản lý người dùng'),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const UserListView()),
                    );
                  },
                ),
                ListTile(
                  title: const Text('Chuyển hướng người dùng'),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const ChatScreen()),
                    );
                  },
                ),
                ListTile(
                  title: const Text('Đăng xuất'),
                  onTap: () {
                    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
                      builder: (context) => const LoginScreen()), (route) => true);
                    FirebaseAuth.instance.signOut();
                  },
                ),
              ],
            ),
          );
        }
        return Center(child: const CircularProgressIndicator());
      }
    );
  }
}

class ClientDrawer extends StatelessWidget {
  const ClientDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if(snapshot.hasData){
          SharedPreferences? pref = snapshot.data;
          String username = pref!.getString('name') ?? "";
          String email = pref.getString('email') ?? "";
          String imageURL = pref.getString('image') ?? "";
          String userId = pref.getString('userid') ?? "";
          String token = pref.getString('token') ?? "";
          return Drawer(
            child: ListView(
              children: [
                UserAccountsDrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.deepPurple[900],
                  ),
                  accountName: Text(username),
                  accountEmail: Text(email),
                  currentAccountPicture: CircleAvatar(
                    backgroundImage: NetworkImage(
                        imageURL),
                  ),
                  arrowColor: Colors.red,
                  onDetailsPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => EditProfileScreen(userId: int.parse(userId))),
                    );
                  },
                  
                ),
                ListTile(
                  leading: Icon(Icons.exit_to_app),
                  title: Text("Cố vấn ChatGPT"),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const ChatScreen()),
                    );
                  },
                ),
                FutureBuilder(
                  future: FacultyRepository(token).getFaculties(),
                  builder: ((context, snapshot) {
                    if(snapshot.hasData){
                      List<Faculty> faculties = snapshot.data ?? [];
                      List<Widget> listTilesWidget = [];
                      for(Faculty faculty in faculties){
                        final item = ListTile(
                          leading: Icon(Icons.exit_to_app),
                          title: Text("Cố vấn Khoa " + faculty.name),
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>  ChatPeopleScreen(facultyId: faculty.facultyId,)),
                            );
                          },
                        );
                        listTilesWidget.add(item);
                      }
                      return Column(children: listTilesWidget,);
                    }
                    return Center(child: const CircularProgressIndicator(),);
                  })
                ),
                ListTile(
                  leading: Icon(Icons.exit_to_app),
                  title: Text("Đăng xuất"),
                  onTap: () {
                    FirebaseAuth.instance.signOut();
                  },
                ),
              ],
            ),
        );
        }
        return Center(child: CircularProgressIndicator());
      }
    );
  }
}