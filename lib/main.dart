import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dialogflow/dialogflow_v2.dart';
import 'package:dash_chat/dash_chat.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Dialogflow dialogflow;
  final GlobalKey<DashChatState> _chatViewKey = GlobalKey<DashChatState>();

  final ChatUser user = ChatUser(
    name: "Fayeed",
    uid: "123456789",
    avatar: "https://www.wrappixel.com/ampleadmin/assets/images/users/4.jpg",
  );

  final ChatUser otherUser = ChatUser(
    name: "Mrfatty",
    uid: "25649654",
  );

  List<ChatMessage> messages = List<ChatMessage>();
  var m = List<ChatMessage>();

  initState() {
    super.initState();
    authenticateDialogflow();
  }

  authenticateDialogflow() async {
    AuthGoogle authGoogle = await AuthGoogle(
            fileJson: "assets/keys/playground-bgueyq-c6b2f206294a.json")
        .build();
    dialogflow = Dialogflow(authGoogle: authGoogle, language: Language.english);
    // print(await sendMessage("beans"));
  }

  void sendMessage(ChatMessage message) async {
    // show the users message
    setState(() {
      messages.add(message);
    });
    print(message.toJson());
    AIResponse response = await dialogflow.detectIntent(message.text);
    String resp = response.getMessage();
    // show the response message
    setState(() {
      messages.add(
          ChatMessage(text: resp, createdAt: DateTime.now(), user: otherUser));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: DashChat(
        key: _chatViewKey,
        inverted: false,
        onSend: sendMessage,
        sendOnEnter: true,
        textInputAction: TextInputAction.send,
        user: user,
        inputDecoration:
            InputDecoration.collapsed(hintText: "Add message here..."),
        dateFormat: DateFormat('yyyy-MMM-dd'),
        timeFormat: DateFormat('HH:mm'),
        messages: messages,
        showUserAvatar: false,
        showAvatarForEveryMessage: false,
        scrollToBottom: false,
        onPressAvatar: (ChatUser user) {
          print("OnPressAvatar: ${user.name}");
        },
        onLongPressAvatar: (ChatUser user) {
          print("OnLongPressAvatar: ${user.name}");
        },
        inputMaxLines: 5,
        messageContainerPadding: EdgeInsets.only(left: 5.0, right: 5.0),
        alwaysShowSend: true,
        inputTextStyle: TextStyle(fontSize: 16.0),
        inputContainerStyle: BoxDecoration(
          border: Border.all(width: 0.0),
          color: Colors.white,
        ),
        onQuickReply: (Reply reply) {
          setState(() {
            messages.add(ChatMessage(
                text: reply.value, createdAt: DateTime.now(), user: user));

            messages = [...messages];
          });

          Timer(Duration(milliseconds: 300), () {
            _chatViewKey.currentState.scrollController
              ..animateTo(
                _chatViewKey
                    .currentState.scrollController.position.maxScrollExtent,
                curve: Curves.easeOut,
                duration: const Duration(milliseconds: 300),
              );

            // if (i == 0) {
            //   systemMessage();
            //   Timer(Duration(milliseconds: 600), () {
            //     systemMessage();
            //   });
            // } else {
            //   systemMessage();
            // }
          });
        },
        onLoadEarlier: () {
          print("laoding...");
        },
        shouldShowLoadEarlier: false,
        showTraillingBeforeSend: true,
      ),
    );
  }
}
