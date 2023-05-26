import 'dart:developer';

import 'package:edubot/screens/forgot_password.dart';
import 'package:edubot/screens/register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isRemember = false;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late Future<String> _email;
  late Future<String> _password;

  Future<void> _saveData() async {
    final SharedPreferences prefs = await _prefs;
    final String email = emailController.value.text;
    final String password = passwordController.value.text;
    prefs.setString('email', email);
    prefs.setString('password', password);
  }

  Future<void> _getEmail() async {
    final SharedPreferences prefs = await _prefs;
    final String? email = await prefs.getString('email');
    log("email: $email");
  }

  @override
  void initState(){
    // TODO: implement initState
    super.initState();
    _email = _prefs.then(
            (SharedPreferences prefs) => prefs.getString('email').toString()
    );
    _password = _prefs.then(
            (SharedPreferences prefs) => prefs.getString('password').toString()
    );
    isRemember = true;
    log("load thành công email: $_email , password: $_password isRemember: $isRemember");
  }
  void signIn() async {
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
    );
    try{
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text
      );
      if(isRemember) {
        await _saveData();
      }
      Navigator.pop(context);
      MotionToast.success(description: Text("Đăng nhập thành công!")).show(context);
    } on FirebaseAuthException catch(e){
      Navigator.pop(context);
      MotionToast.error(description: Text(e.toString())).show(context);
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
                const Icon(
                  Icons.account_circle,
                  size: 100,
                ),
                const Text(
                  'Đăng Nhập',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                FutureBuilder<String>(
                    future: _email,
                    builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                      if(snapshot.hasData){
                        emailController.text = snapshot.data ?? '';
                        if(snapshot.data.toString() == "null"){
                          emailController.clear();
                        }
                        isRemember = true;
                        return TextField(
                          controller: emailController,
                          obscureText: false,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Email',
                          ),
                        );
                      }
                      return TextField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Email',
                        ),
                      );
                    }),

                const SizedBox(
                  height: 10,
                ),
                FutureBuilder<String>(
                    future: _password,
                    builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                      if(snapshot.hasData){
                        passwordController.text = snapshot.data ?? '';
                        if(snapshot.data.toString() == "null"){
                          passwordController.clear();
                        }
                        return TextField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Password',
                          ),
                        );
                      }
                      return TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Password',
                        ),
                      );
                    }),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                              value: isRemember,
                              onChanged: (bool? value){
                              setState(() {
                                isRemember = value!;
                                _email = _email;
                                _password = _password;
                              });
                            }
                          ),
                          const Text(
                              'Nhớ đăng nhập',
                              style: TextStyle(
                                color: Colors.black54,
                              )
                          )
                        ],
                      )
                      ,
                      TextButton(
                          onPressed: ()=> Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const ForgotPasswordScreen()),
                          ),
                          child: const Text(
                              'Quên mật khẩu?',
                            style: TextStyle(
                              color: Colors.black54,
                            ),
                          )
                      ),
                    ],
                  )
                ),

                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: (){
                          if(emailController.text.isEmpty){
                            MotionToast.error(description: Text("Bạn chưa nhập email!")).show(context);
                          } else if(!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(emailController.text)){
                            MotionToast.error(description: Text("Email chưa đúng định dạng!")).show(context);
                          } else if(passwordController.text.isEmpty){
                            MotionToast.error(description: Text("Bạn chưa nhập password!")).show(context);
                          } else {
                            signIn();
                          }
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.black,
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 15),
                          child: Text('ĐĂNG NHẬP'),
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
                          builder: (context) => const RegisterScreen()),
                      );
                    },
                    child: const Text(
                      'Đăng ký ngay',
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
