import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();
  void resetPassword() async {
    showDialog(
        context: context,
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
    );
    try{
      await FirebaseAuth.instance.sendPasswordResetEmail(
          email: emailController.text,
      );
      Navigator.pop(context);
      showDialog(context: context, builder: (context){
        return const AlertDialog(
          title: Text(
              'Kiểm tra email của bạn!'
          ),
          backgroundColor: Colors.green,
        );
      });
    } on FirebaseAuthException catch (e){
      Navigator.pop(context);
      if(e.code == 'user-not-found'){
        showDialog(context: context, builder: (context){
          return const AlertDialog(
            title: Text(
                'Lỗi: Email này chưa tạo tài khoản.'
            ),
            backgroundColor: Colors.redAccent,
          );
        });
      } else if(e.code == 'invalid-email'){
        showDialog(context: context, builder: (context){
          return const AlertDialog(
            title: Text(
                'Lỗi: Email không đúng định dạng.'
            ),
            backgroundColor: Colors.redAccent,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Quên mật khẩu'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/reset_password.png',
                width: 120,
              ),
              SizedBox(height: 20,),
              const Text(
                'Nhập email thay đổi mật khẩu.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: TextField(
                    style: TextStyle(
                      color: Colors.white
                    ),
                    obscureText: false,
                    controller: emailController,
                    decoration: const InputDecoration(
                      border: null,
                      hintText: 'Email',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ))
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                      child: TextButton(
                        onPressed: resetPassword,
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.teal
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.mail_outline_rounded,
                                color: Colors.white,
                              ),
                              SizedBox(width: 4,),
                              Text(
                                'Đổi mật khẩu',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
