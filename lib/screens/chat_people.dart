import 'package:edubot/components/drawer_component.dart';
import 'package:edubot/constants/constants.dart';
import 'package:edubot/message/message_model.dart';
import 'package:edubot/message/message_repository.dart';
import 'package:flutter/material.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signalr_netcore/hub_connection.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';

class ChatPeopleScreen extends StatefulWidget {
  final int facultyId;
  const ChatPeopleScreen({super.key, required this.facultyId});

  @override
  State<ChatPeopleScreen> createState() => _ChatPeopleScreenState();
}

class _ChatPeopleScreenState extends State<ChatPeopleScreen> {
  final hubConnection = HubConnectionBuilder().withUrl("https://localhost:44302/chatHub").build();
  String userEmail = "";
  String token = "";
  TextEditingController chatMsgTextController = TextEditingController();
  String reset = "";
  int falcultyId = 2;
  

  @override
  void initState() {
    super.initState();
    mapState();
  }

  void mapState() async {
    await hubConnection.start();
    String? presf_email = await SharedPreferences.getInstance().then((value) => value.getString('email'));
    String? presf_token = await SharedPreferences.getInstance().then((value) => value.getString('token'));
    setState(() {
      userEmail = presf_email ?? "";
      token = presf_token ?? ""; 
    });
    falcultyId = widget.facultyId;
  }
  
  @override
  void dispose() {
    super.dispose();
    hubConnection.stop();
  }

  @override
  Widget build(BuildContext context) {
    hubConnection.onclose(({error}) {
      MotionToast.error(
        title: Text("Lỗi"),
        description: Text("Mất kết nối!")
      ).show(context);
    });
    hubConnection.on("ReceiveMessage",((arguments) {
      setState(() {
        reset = "";
      });
    }));
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
          iconTheme: IconThemeData(color: Colors.white),
          elevation: 0,
          backgroundColor: Colors.white10,
          title: const Text(
            'Cố vấn online',
            style: TextStyle(
                fontSize: 16,
                color: Colors.white),
          ),
        ),
        drawer: const ClientDrawer(),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            FutureBuilder(
              future: MessageRepository(token).getMessagesByFacultyId(falcultyId),
              builder: (context, snapshot) {
                if(snapshot.hasData){
                  List<Message> messages = snapshot.data ?? [];
                  List<Widget> messageWidgets = [];
                  for(Message message in messages){
                    final msgBubble = MessageBuble(
                      msgText: message.content, 
                      msgSender: message.userName, 
                      user: message.gmail == userEmail 
                    );
                    final avartar = CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(message.userImage),
                    );
                    messageWidgets.add(Row(
                      mainAxisAlignment: message.gmail == userEmail ? MainAxisAlignment.end : MainAxisAlignment.start,
                      children:  message.gmail == userEmail ? [msgBubble,avartar] : [avartar,msgBubble],
                    ));
                    //messageWidgets.add(msgBubble);
                  }
                  return Expanded(
                    child: ListView(
                      reverse: true,
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                      children: messageWidgets,
                    ),
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              }
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical:10,horizontal: 10),
              decoration: BoxDecoration(),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Material(
                      borderRadius: BorderRadius.circular(50),
                      color: CART_COLOR,
                      elevation:5,
                      child: Padding(
                        padding: const EdgeInsets.only(left:8.0,top:2,bottom: 2),
                        child: TextField(
                          onChanged: (value) {
    
                          },
                          controller: chatMsgTextController,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                            hintText: 'Tin nhắn',
                            hintStyle: TextStyle(fontFamily: 'Poppins',fontSize: 14,color: Colors.grey),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                  MaterialButton(
                    shape: const CircleBorder(),
                    color: Colors.blue,
                    onPressed: () async {
                      String? pref_userid =  await SharedPreferences.getInstance().then((value) => value.getString("userid"));
                      String? pref_facultyid =  await SharedPreferences.getInstance().then((value) => value.getString("facultyid"));
                      await hubConnection.invoke(
                        "SendMessage", 
                        args: <Object>[int.parse(pref_userid ?? "2"),falcultyId,chatMsgTextController.text]
                      );
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ChatPeopleScreen(facultyId: falcultyId),
                      ));
                      chatMsgTextController.clear();
                    },
                    child:Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Icon(Icons.send,color: Colors.white,),
                    ) 
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageBuble extends StatelessWidget {
  final String msgText;
  final String msgSender;
  final bool user;
  const MessageBuble({super.key, required this.msgText, required this.msgSender, required this.user});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment:
              user ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                msgSender,
                style: const TextStyle(
                    fontSize: 13, fontFamily: 'Poppins', color: Colors.grey),
              ),
            ),
            Material(
              borderRadius: BorderRadius.all(Radius.circular(40)),
              color: user ? Colors.blue : CART_COLOR,
              elevation: 5,
              child: Container(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: SizedBox(
                    //width: MediaQuery.of(context).size.width > 1200 ? 100,
                    child: Tooltip(
                      message: "sos",
                      child: Text(
                        msgText,
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Poppins',
                          fontSize: 15,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 10,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}