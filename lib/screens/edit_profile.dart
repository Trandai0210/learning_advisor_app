import 'dart:io';

import 'package:date_field/date_field.dart';
import 'package:edubot/user/user_model.dart';
import 'package:edubot/user/user_repository.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfileScreen extends StatefulWidget {
  final int userId;
  const EditProfileScreen({super.key, required this.userId});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  String token = "";
  String name = "";
  String email = "";
  String phone = "";
  String imageURL = "";
  String dob = "Date/Time";
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  
  void mapState() async {
    String? presf_token = await SharedPreferences.getInstance().then((value) => value.getString('token'));
    setState(() {
      token = presf_token ?? ""; 
    });
  }

  // void upLoadImage(int id, String token) async {
  //   FilePickerResult? result = await FilePicker.platform.pickFiles();
  //   if(result != null){
  //     final metadata = SettableMetadata(contentType: "image/jpeg");
  //     Uint8List fileBytes = result.files.first.bytes!;
  //     String fileName = result.files.first.name;
  //     print("File name: $fileName");

  //     final firestore = FirebaseStorage.instanceFor(bucket: "gs://cloud-storage-6d4a9.appspot.com");
  //     print("FireStore: $firestore");
  //     //File file = File.fromRawPath(fileBytes);
  //     final uploadTask = firestore.ref('images/$fileName').putData(fileBytes);
  //     uploadTask.snapshotEvents.listen((event) {
  //       switch(event.state){
  //         case TaskState.success:{
  //           print("done!");
            
  //         }break;
  //       }});
        
  //     //await firestore.ref('images/$fileName').putFile(file, metadata);
  //   }
  // }

  @override
  void initState() {
    super.initState();
    mapState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: UserRepository(token).getUserById(widget.userId),
      builder: (context, snapshot) {
        if(snapshot.hasData){
          User user = snapshot.data ?? User(userId: 1, name: "name", gmail: "gmail", phone: "phone", image: "image", dob: "dob", status: false, permissionId: 2, permissionName: "permissionName");
          nameController.text = user.name;
          phoneController.text = user.phone;
          emailController.text = user.gmail;
          dob = user.dob;
          phone = user.phone;
          return Scaffold(
            appBar: AppBar(title: const Text("Thông tin người dùng")),
            body: Container(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Column(children: [
                    const SizedBox(height: 20,),
                    InkWell(
                      child: Container(
                        padding: EdgeInsets.all(3),
                        decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        child: ClipOval(
                          child: SizedBox.fromSize(
                            size: Size.fromRadius(48),
                            child: Image.network(user.image, fit: BoxFit.cover,),
                          ),
                        ),
                      ),
                      onTap: () async {
                        print("edit");
                        //upLoadImage(user.userId,token);
                      },
                    ),
                    Row(children: [
                       Text("Email: ", style: TextStyle(color: Colors.white),),
                    ]),
                    const SizedBox(height: 1,),
                    TextField(
                      controller: emailController,
                      enabled: false,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(fillColor: Colors.grey, filled: true),
                      onChanged: ((value) {
                        name = name.isEmpty ? value : name.toString()+value;
                      }),
                    ),
                    const SizedBox(height: 10),
                    Row(children: [
                       Text("Họ tên: ", style: TextStyle(color: Colors.white),),
                    ]),
                    const SizedBox(height: 1,),
                    TextField(
                      controller: nameController,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(fillColor: Colors.white, filled: true),
                      onChanged: ((value) {
                        name = name.isEmpty ? value : name.toString()+value;
                      }),
                    ),
                    const SizedBox(height: 10,),
                    Row(children: [
                       Text("Điện thoại: ", style: TextStyle(color: Colors.white),),
                    ]),
                    const SizedBox(height: 1,),
                    TextField(
                      controller: phoneController,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(fillColor: Colors.white, filled: true),
                      onChanged: ((value) {
                        phone = phone.isEmpty ? value : phone.toString()+value;
                      }),
                    ),
                    const SizedBox(height: 10,),
                    Row(children: [
                       Text("Ngày sinh: ", style: TextStyle(color: Colors.white),),
                    ]),
                    const SizedBox(height: 1,),
                    DateTimeFormField(
                      initialValue: DateTime.parse(dob),
                      decoration: InputDecoration(fillColor: Colors.white, filled: true),
                      mode: DateTimeFieldPickerMode.dateAndTime,
                      onDateSelected: (DateTime? value){
                        dob = value.toString();
                      },
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        await UserRepository(token).updateUser(user.userId, name, user.gmail, phone, imageURL, dob);
                        MotionToast.success(description: Text("Cập nhật thành công. Vui lòng khởi động lại ứng dụng")).show(context);
                        SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
                        sharedPreferences.clear();
                        firebase_auth.FirebaseAuth.instance.signOut();
                      }, 
                      child: Text("Cập nhật")
                    )
                  ]),
                ),
              ),
            ),
          );
        }
        return Center(child: CircularProgressIndicator(),);
      }
    );
  }
}

