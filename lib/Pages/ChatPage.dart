import 'package:chatapp/CustomUI/CustomCard.dart';
import 'package:chatapp/Model/ChatModel.dart';
import 'package:chatapp/Model/MessageModel.dart';
import 'package:chatapp/Screens/SelectContact.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatPage extends StatefulWidget {
  ChatPage({Key key, this.chatmodels, this.sourchat}) : super(key: key);
  final List<ChatModel> chatmodels;
  final ChatModel sourchat;

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {


  IO.Socket socket;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    connect();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (builder) => SelectContact()));
        },
        child: Icon(
          Icons.chat,
          color: Colors.white,
        ),
      ),
      body: ListView.builder(
        itemCount: widget.chatmodels.length,
        itemBuilder: (contex, index) {
          print(widget.chatmodels[index].id);
          print(widget.chatmodels[index].messageList);
          return  CustomCard(
            chatModel: widget.chatmodels[index],
            sourchat: widget.sourchat,
          );
        },
      ),
    );
  }


  void connect() {
    // MessageModel messageModel = MessageModel(sourceId: widget.sourceChat.id.toString(),targetId: );
    socket = IO.io("http://192.168.1.109:5000", <String, dynamic>{
      "transports": ["websocket"],
      "autoConnect": false,
    });
    socket.connect();
    socket.emit("signin", widget.sourchat.id);
    socket.onConnect((data) {
      print("Connected");
      print(data);
      socket.on("message", (msg) {
        print("MESAJ = $msg");
        setMessage("destination", msg["message"],msg["sourceId"]);
      });
    });
  }


  void setMessage(String type, String message,int targetId) {
    print("setmessage");
    MessageModel messageModel = MessageModel(
        type: type,
        message: message,
        time: DateTime.now().toString().substring(10, 16));
    print(messageModel.type);
    print(messageModel.message);
    for(var data in widget.chatmodels){
      print("dataid= ${data.id}");
      print("targetId = $targetId");
      if(data.id == targetId) {
        print("eklendi");
        data.messageList.add(messageModel);
        data.currentMessage = message;
      }
    }
    setState(() {
    });
  }

}
