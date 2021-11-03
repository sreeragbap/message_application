import 'package:flutter/material.dart';
import 'package:messageapp/mqtt_connection.dart';
import 'package:provider/provider.dart';

class MembersTabScreen extends StatefulWidget {
  const MembersTabScreen({Key key}) : super(key: key);

  @override
  _MembersTabScreenState createState() => _MembersTabScreenState();
}

MQTTClientWrapper m = MQTTClientWrapper();

class _MembersTabScreenState extends State<MembersTabScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      m.prepareMqttClient();
    });
  }

  @override
  Widget build(BuildContext context) {
    m = Provider.of<MQTTClientWrapper>(context);
    List users = m.users;

    return Scaffold(
      bottomNavigationBar: OutlinedButton(
        child: const Text("connect"),
        onPressed: () async {
          m.connectClient();
          Future.delayed(const Duration(seconds: 2), () {
            m.subscribeToAlertTopic();
          });
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          m.prepareMqttClient();
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          children: users.map((user) {
            return ListTile(
              leading: const CircleAvatar(
                  child: Icon(Icons.person_outline_outlined)),
              title: user.name == null ? const Text('null') : Text(user.name),
              onTap: () {
                Navigator.of(context).pushNamed(
                  'chatscreen',
                  arguments: {'empno': user.empNo, 'username': user.name},
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
