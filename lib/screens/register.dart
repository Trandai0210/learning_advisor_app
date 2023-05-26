import 'dart:developer';

import 'package:date_field/date_field.dart';
import 'package:edubot/screens/forgot_password.dart';
import 'package:edubot/screens/login.dart';
import 'package:edubot/user/user_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  String dob = "Date/Time";

  void signUp() async {
    showDialog(
        context: context,
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
    );
    try{
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
      );
      String token = SharedPreferences.getInstance().then((SharedPreferences value) => value.getString('token').toString()) as String;
      await UserRepository(token).addUser(
        nameController.text, 
        emailController.text, 
        phoneController.text, 
        "",
        dob
      );
      Navigator.pop(context);
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => const LoginScreen()),
      );
      MotionToast.success(description: Text("Đăng ký thành công!",)).show(context);
    } on FirebaseAuthException catch(e){
      Navigator.pop(context);
      MotionToast.error(description: Text("Lỗi: "+e.toString()),).show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/icon_add_user.png',
                  width: 100,
                ),
                const Text(
                  'Đăng Ký',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextField(
                  controller: emailController,
                  obscureText: false,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Email',
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Confirm Password',
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextField(
                  controller: nameController,
                  obscureText: false,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Họ tên',
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextField(
                  controller: phoneController,
                  obscureText: false,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Số điện thoại',
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                DateTimeFormField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Ngày sinh',
                  ),
                  mode: DateTimeFieldPickerMode.dateAndTime,
                  onDateSelected: (DateTime? value){
                    dob = value.toString();
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () async {
                          if(!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(emailController.text)){
                            MotionToast.error(description: Text("Email chưa đúng định dạng!")).show(context);
                          }else if(passwordController.text.isEmpty){
                            MotionToast.error(description: Text("Mật khẩu không được để trống!")).show(context);
                          }else if(passwordController.text.length < 8 || passwordController.text.length > 15){
                            MotionToast.error(description: Text("Mật khẩu phải từ 8 đến 15 ký tự")).show(context);
                          }else if(passwordController.text != confirmPasswordController.text){
                            MotionToast.error(description: Text("Confirm Password chưa chính xác!")).show(context);
                          }else if(nameController.text.isEmpty){
                            MotionToast.error(description: Text("Họ tên không được để trống!")).show(context);
                          }else if(phoneController.text.isEmpty){
                            MotionToast.error(description: Text("Số điện thoại không được để trống!")).show(context);
                          }else if(dob == "Date/Time"){
                            MotionToast.error(description: Text("Bạn chưa nhập ngày sinh!")).show(context);
                          } else {
                            signUp();
                          }
                          
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 15),
                          child: Text('ĐĂNG KÝ'),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                const Text('or'),
                const SizedBox(height: 5),
                TextButton(
                  onPressed: (){
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                    );
                  },
                  child: const Text(
                    'Đăng nhập ngay',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
