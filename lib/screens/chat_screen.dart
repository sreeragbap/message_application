import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:messageapp/mqtt_connection.dart';
import 'package:messageapp/screens/popupmenu_button.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  final BuildContext context;
  const ChatScreen({Key key, this.context}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

MQTTClientWrapper m = MQTTClientWrapper();
TextEditingController mycontroller = TextEditingController();
ScrollController scrollController = ScrollController(keepScrollOffset: true);
String userId;
String userName;
void _onPressed() {
  if (mycontroller.text != null && mycontroller.text != "") {
    m.sendMessage(mycontroller, userId, userName);
  }
  mycontroller.clear();
}

scrollToBottom() {
  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    if (scrollController.hasClients) {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    }
  });
}

void refresh() {
  // Future.delayed(const Duration(seconds: 1), () {
  //   m.prepareMqttClient();
  // });
  Future.delayed(const Duration(seconds: 5), () {
    refresh();
  });
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    m = Provider.of<MQTTClientWrapper>(context);

    var focusNode = FocusNode();

    final routeArgs =
        ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
    final empNo = routeArgs['empno'];
    final user = routeArgs['username'];
    setState(() {
      userId = empNo;
      userName = user;
    });

    //filtering messages intividually..
    List filterTheMessages(List messages) {
      List filteredMessages = [];
      messages.map((message) {
        if (message.sendTo == userId && message.user == m.userDetails[0].myId ||
            message.sendTo == m.userDetails[0].myId && message.user == userId) {
          filteredMessages.add(message);
        }
      }).toList();
      return filteredMessages;
    }

    List<String> menuItems = ['select', 'search', 'unselect'];
    scrollToBottom();
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const CircleAvatar(child: Icon(Icons.person_outline_outlined)),
            const SizedBox(
              width: 10,
            ),
            Expanded(child: Text(userName)),
          ],
        ),
        leading: const BackButton(),
        actions: [
          PopupmenuButton(
            menuItems: menuItems,
            onselected: (item) {
              print(item);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Text(userId),
            Expanded(
                flex: 1,
                child: Container(
                  color: Colors.grey[200],
                  width: MediaQuery.of(context).size.width < 600
                      ? double.infinity
                      : MediaQuery.of(context).size.width * 0.6,
                  child: ListView.builder(
                      controller: scrollController,
                      shrinkWrap: true,
                      itemCount: filterTheMessages(m.messages).length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          focusColor:
                              filterTheMessages(m.messages)[index].user ==
                                      m.userDetails[0].myId
                                  ? const Color(0xffDBF9DB)
                                  : Colors.blue[100],
                          title: Container(
                            padding: const EdgeInsets.only(
                                left: 10, right: 10, top: 5, bottom: 5),
                            child: Align(
                              alignment:
                                  filterTheMessages(m.messages)[index].user ==
                                          m.userDetails[0].myId
                                      ? Alignment.topRight
                                      : Alignment.topLeft,
                              child: Container(
                                // width: MediaQuery.of(context).size.width * 0.4,
                                decoration: BoxDecoration(
                                    color: filterTheMessages(m.messages)[index]
                                                .user ==
                                            m.userDetails[0].myId
                                        ? const Color(0xffDBF9DB)
                                        : Colors.blue[100],
                                    borderRadius: BorderRadius.circular(25)),
                                padding: const EdgeInsets.all(8),
                                child: filterTheMessages(m.messages)[index]
                                            .contents
                                            .body ==
                                        null
                                    ? const SizedBox()
                                    : Text(
                                        filterTheMessages(m.messages)[index]
                                            .contents
                                            .body,
                                      ),
                              ),
                            ),
                          ),
                        );
                      }),
                )),
            Container(
              margin: const EdgeInsets.all(3),
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Row(
                children: [
                  Expanded(
                    child: RawKeyboardListener(
                      focusNode: focusNode,
                      onKey: (event) {
                        if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
                          _onPressed();
                        }
                      },
                      child: TextField(
                        controller: mycontroller,
                        decoration: const InputDecoration(
                          hintText: "Type a message",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(25.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  const FloatingActionButton(
                    onPressed: _onPressed,
                    child: Icon(Icons.send),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
