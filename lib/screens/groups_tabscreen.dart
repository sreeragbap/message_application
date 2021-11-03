import 'package:flutter/material.dart';
import 'package:messageapp/handlers/datas_tore.dart';
import 'package:messageapp/mqtt_connection.dart';
import 'package:provider/provider.dart';

class GroupsTabScreen extends StatefulWidget {
  const GroupsTabScreen({Key key}) : super(key: key);

  @override
  _GroupsTabScreenState createState() => _GroupsTabScreenState();
}

MQTTClientWrapper m = MQTTClientWrapper();

class _GroupsTabScreenState extends State<GroupsTabScreen> {
  @override
  Widget build(BuildContext context) {
    m = Provider.of<MQTTClientWrapper>(context);
    List users = m.users;
    List members = users.map((user) {
      return Employee(
          dept: user.dept,
          name: user.name,
          empNo: user.empNo,
          isSelected: false);
    }).toList();
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.of(context)
              .pushNamed('newgroupscreen', arguments: {'members': members});
        },
      ),
      body: Column(),
    );
  }
}
