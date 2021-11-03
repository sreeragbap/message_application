import 'package:flutter/material.dart';
import 'package:messageapp/mqtt_connection.dart';
import 'package:messageapp/screens/alert_tabscreen.dart';
import 'package:messageapp/screens/groups_tabscreen.dart';
import 'package:messageapp/screens/members_tabscreen.dart';
import 'package:messageapp/screens/popupmenu_button.dart';
import 'package:provider/provider.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key}) : super(key: key);
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

dynamic userId;
MQTTClientWrapper m = MQTTClientWrapper();
TextEditingController mycontroller = TextEditingController();
bool isTrue = false;

class _MyHomePageState extends State<MyHomePage> {
  TabController tabController;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    m = Provider.of<MQTTClientWrapper>(context);
    List<String> menuItems = ['select', 'search', 'unselect'];
    return DefaultTabController(
      initialIndex: 0,
      length: isTrue == false ? 3 : 4,
      child: Scaffold(
        appBar: AppBar(
          actions: [
            Checkbox(
                value: isTrue,
                onChanged: (value) {
                  setState(() {
                    isTrue = !isTrue;
                  });
                }),
            PopupmenuButton(
              menuItems: menuItems,
              onselected: (item) {},
            ),
          ],
          title: const Text("MessageApp"),
          bottom: TabBar(
            onTap: (index) {},
            controller: tabController,
            tabs: isTrue == false
                ? const [
                    Tab(
                      text: 'Members',
                      // icon: Icon(Icons.people),
                    ),
                    Tab(
                      text: 'Groups',
                      // icon: Icon(Icons.groups),
                    ),
                    Tab(
                      text: 'Alert',
                      // icon: Icon(Icons.warning),
                    )
                  ]
                : const [
                    Tab(text: 'Members'),
                    Tab(text: 'Groups'),
                    Tab(text: 'Alert'),
                    Tab(
                      text: 'Debug',
                    )
                  ],
          ),
        ),
        body: Column(children: <Widget>[
          Expanded(
            child: isTrue == false
                ? const TabBarView(children: [
                    MembersTabScreen(),
                    GroupsTabScreen(),
                    AlertTabScreen(),
                  ])
                : TabBarView(children: [
                    MembersTabScreen(),
                    GroupsTabScreen(),
                    AlertTabScreen(),
                    Container(),
                  ]),
          )
        ]),
      ),
    );
  }
}
