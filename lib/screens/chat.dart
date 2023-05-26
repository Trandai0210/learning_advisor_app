import 'package:edubot/components/chat_component.dart';
import 'package:edubot/components/drawer_component.dart';
import 'package:edubot/constants/constants.dart';
import 'package:edubot/providers/chat_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool _isTyping = false;
  late TextEditingController textEditingController;
  late ScrollController listScrollController;
  late FocusNode focusNode;

  @override
  void initState() {
    listScrollController = ScrollController();
    textEditingController = TextEditingController();
    focusNode = FocusNode(); 
    super.initState();
  }

  @override
  void dispose() {
    listScrollController.dispose();
    textEditingController.dispose();
    focusNode.dispose();
    super.dispose();
  }
  void logOut(){
    FirebaseAuth.instance.signOut();
  }
  
  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme:  ThemeData(
        scaffoldBackgroundColor: BACKGROUND_COLOR,
        appBarTheme: AppBarTheme(
          color: CART_COLOR,
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          elevation: 2,
          title: const Text(
            'Cố vấn ChatGPT',
            style: TextStyle(
                fontSize: 16,
                color: Colors.white),
          ),
          actions: [
            IconButton(
                onPressed: logOut,
                icon: Icon(Icons.logout),
            ),
          ],
        ),
        drawer: const ClientDrawer(),
        body: SafeArea(
          child: Column(
            children: <Widget>[
              Flexible(
                child: ListView.builder(
                  controller: listScrollController,
                  itemCount: chatProvider.Chats.length,
                  itemBuilder: (context,index) => ChatComponent(
                      message: chatProvider.Chats[index].message,
                      chatIndex: chatProvider.Chats[index].chatIndex
                  ),
                ),
              ),
              if(_isTyping)
                const SpinKitWave(
                  color: Colors.white,
                  size: 16,
                ),
              const SizedBox(
                height: 15,
              ),
              Material(
                color: CART_COLOR,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                          child: TextField(
                            focusNode: focusNode,
                            style: const TextStyle(
                                color: Colors.white
                            ),
                            controller:  textEditingController,
                            onSubmitted: (value) async {
                              await sendMessage(chatProvider);
                            },
                            decoration: const InputDecoration.collapsed(
                                hintText: "Câu hỏi",
                                hintStyle: TextStyle(color: Colors.grey),
                            ),
                          )
                      ),
                      IconButton(
                          onPressed: () async {
                            await sendMessage(chatProvider);
                          },
                          icon: const Icon(
                            Icons.send,
                            color: Colors.white,
                          ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void scrollListToEnd(){
    listScrollController.animateTo(
        listScrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 2),
        curve: Curves.easeOut
    );
  }

  Future<void> sendMessage(ChatProvider chatProvider) async {
    if(_isTyping) {
      MotionToast.error(description: Text("Bạn không thể gửi nhiều tin nhắn cùng một lúc!")).show(context);
      return;
    }
    if(textEditingController.text.isEmpty) {
      MotionToast.error(description: Text("Bạn chưa nhập câu hỏi!")).show(context);
      return;
    } else {
      try {
        String message = textEditingController.text;
        setState(() {
          _isTyping = true;
          chatProvider.addUserMessage(message);
          textEditingController.clear();
          focusNode.unfocus();
        });
        await chatProvider.sendMessageAndGetAnswers(message);
      } catch (error){
        MotionToast.error(description: Text(error.toString())).show(context);
      } finally {
        setState(() {
          scrollListToEnd();
          _isTyping = false;
        });
      }
    }
  }
}
