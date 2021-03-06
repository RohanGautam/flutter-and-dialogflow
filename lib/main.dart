import 'package:flutter/material.dart';
// external package imports
import 'package:flutter_dialogflow/dialogflow_v2.dart';
import 'package:dash_chat/dash_chat.dart';
import 'package:uuid/uuid.dart';
import 'package:loading/loading.dart';
import 'package:loading/indicator/line_scale_indicator.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Talk to dialogflow',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Talk to dialogflow ⚡'),
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

  ChatUser user = ChatUser(
    name: "User",
    uid: Uuid().v4(),
  );

  final ChatUser otherUser = ChatUser(
    name: "Customer support",
    uid: Uuid().v4(),
    avatar: "https://www.wrappixel.com/ampleadmin/assets/images/users/4.jpg",
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
    setState(() {
      dialogflow =
          Dialogflow(authGoogle: authGoogle, language: Language.english);
    });
    // print(await sendMessage("beans"));
  }

  Widget getLoadingScreen() {
    return Center(
      child: Loading(
          indicator: LineScaleIndicator(),
          color: Theme.of(context).accentColor,
          size: 100.0),
    );
  }

  void sendMessage(ChatMessage message) async {
    // show the users message
    setState(() {
      messages.add(message);
    });
    print(message.toJson()); // for debugging
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
        title: Text(widget.title),
      ),
      body: dialogflow == null
          ? getLoadingScreen()
          : Padding(
              // padding: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(8),
              child: DashChat(
                key: _chatViewKey,
                inverted: false,
                onSend: sendMessage,
                sendOnEnter: true,
                user: user,
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
                alwaysShowSend: true,
                // format how the messages look
                messageDecorationBuilder: (_, isUser) {
                  return BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: isUser
                          ? Theme.of(context).accentColor
                          : Colors.grey[200]);
                },
                // input configurations
                textInputAction: TextInputAction.send,
                inputMaxLines: 5,
                inputDecoration:
                    InputDecoration.collapsed(hintText: "Add message here..."),
                inputTextStyle: TextStyle(fontSize: 16.0),
                inputContainerStyle: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: Colors.grey[300],
                ),
              ),
            ),
    );
  }
}
