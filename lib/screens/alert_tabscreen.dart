import 'package:flutter/material.dart';
import 'package:messageapp/mqtt_connection.dart';
import 'package:provider/provider.dart';

class AlertTabScreen extends StatefulWidget {
  const AlertTabScreen({Key key}) : super(key: key);

  @override
  _AlertTabScreenState createState() => _AlertTabScreenState();
}

MQTTClientWrapper m = MQTTClientWrapper();

class _AlertTabScreenState extends State<AlertTabScreen> {
  @override
  Widget build(BuildContext context) {
    m = Provider.of<MQTTClientWrapper>(context);
    List alerts = m.alerts;
    List priorityList = [];
    dynamic biggestValue() {
      priorityList = alerts.map((alertMessage) {
        return alertMessage.priority;
      }).toList();
      return priorityList.reduce((curr, next) => curr > next ? curr : next);
    }

    return Scaffold(
      bottomNavigationBar: OutlinedButton(
        child: const Text("clear"),
        onPressed: () {
          setState(() {
            alerts.clear();
          });
        },
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          // alerts.map((alertMessage) {
          Container(
            color: Colors.grey[300],
            child: ListTile(
              leading: const Icon(Icons.add_alert_sharp),
              onTap: () {},
              trailing: alerts.isEmpty
                  ? const SizedBox()
                  : CircleAvatar(
                      backgroundColor: biggestValue() == 0
                          ? Colors.white
                          : biggestValue() < 3 && biggestValue() != 0
                              ? Colors.green
                              : biggestValue() < 6 && biggestValue() > 2
                                  ? Colors.orange
                                  : biggestValue() > 5
                                      ? Colors.red
                                      : Colors.transparent,
                      child: Text(alerts.length.toString()),
                      radius: 10,
                    ),
              title: alerts.isEmpty
                  ? const SizedBox()
                  : Align(
                      alignment: Alignment.center,
                      child: Text(alerts[0].sender)),
            ),
          )
        ]
            // }).toList()
            ),
      ),
    );
  }
}
