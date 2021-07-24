import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flash_chat/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



final _fireStore = FirebaseFirestore.instance;
User loggedInUser;


class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';

  @override
  _ChatScreenState createState() => _ChatScreenState();

}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;

  String messages;
  final textController = TextEditingController();


  @override
  void initState() {

    getCurrent();
    super.initState();

  }

  void getCurrent() async {
    try {
      final user =  _auth.currentUser;
      if (user!=null){
        loggedInUser = user;
        print('it\'s me '+loggedInUser.email);
      }

    }
    catch (e){
    print(e);
    }

  }


  void messageStream() async{

    _fireStore.collection('messages').snapshots().listen((event) {
      event.docs.forEach((element) {
        print(element.data());
      });
    });

    // await for(var snapshot in _fireStore.collection('messages'))

    // _fireStore.collection('messages').get().then((value) {
    //   value.docs.forEach((element) {
    //     print(element.data());
    //   });
    // });

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                Navigator.pushNamed(context, LoginScreen.id);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[

            MessageStream(),

            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: textController,
                      onChanged: (value) {
                        messages = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      textController.clear();
                      _fireStore.collection('messages').add({
                        'text':messages,
                        'sender': loggedInUser.email,
                      });
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
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



class MessageStream extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _fireStore.collection('messages').snapshots(),
      builder: (context, snapshot){

        if(!snapshot.hasData){
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlue,
            ),
          );
        }
        final messages = snapshot.data.docs.reversed;
        List<MessageBubble> messageWidgets = [];

        for(var message in messages){
          final messageText = message['text'];
          final messageSender = message['sender'];
          final currentUser = loggedInUser.email;


            final messageWidget = MessageBubble(messageSender, messageText, currentUser  == messageSender);
            messageWidgets.add(messageWidget);


        }
        return Expanded(
          child: ListView(
            reverse: true,
            children: [
              Column(
                children: messageWidgets,
              ),
            ],
          ),
        );

      },
    );

  }
}




class MessageBubble extends StatelessWidget {
  MessageBubble(this.sender, this.text, this.isMe);
  final String sender;
  final String text;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
        child: Align(
          alignment: isMe ? Alignment.topRight : Alignment.topLeft,
          child: Column(
            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(sender, style: TextStyle(fontSize: 14, color:  isMe ? Colors.white : Colors.lightBlueAccent),),
              Material(
                borderRadius: isMe ? BorderRadius.only(
                  topLeft:Radius.circular(30) ,
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ) : BorderRadius.only(
                  topRight:Radius.circular(30) ,
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                color: isMe ? Colors.lightBlueAccent : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: Text('$text ', style: TextStyle(fontSize: 24),),
                ),
              ),
            ],

          ),
        ),
    );
  }
}
