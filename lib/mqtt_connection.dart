import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:messageapp/handlers/datas_tore.dart';
import 'package:messageapp/handlers/message_parsers.dart';
import 'package:messageapp/screens/login_screen.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:uuid/uuid.dart';
import 'handlers/processor.dart';

class MQTTClientWrapper extends ChangeNotifier {
  var uuid = Uuid();
  MqttServerClient client =
      MqttServerClient.withPort('115.249.0.206', Uuid().v4(), 1883);
  MqttCurrentConnectionState connectionState = MqttCurrentConnectionState.IDLE;
  MqttSubscriptionState subscriptionState = MqttSubscriptionState.IDLE;
  Handler processor;
  BuildContext context;
  AppContext _appContext = AppContext();
  List<Employee> users = [];
  List<AlertPayload> alerts = [];
  List messages = [];

  MQTTClientWrapper() {
    processor = ProcessorFactory.buildProcessor();
  }

  void setUser(String myId) {
    _appContext.setValue(
        AppContext.ACTIVE_USER, userDetails.isEmpty ? '' : myId);
  }

  List<SetupUserdetails> userDetails = [];
  void storeUserDetails(SetupUserdetails user) {
    userDetails.add(SetupUserdetails(
        myname: user.myname,
        mynickname: user.mynickname,
        mydept: user.mydept,
        myId: user.myId,
        myemailid: user.myemailid));
    notifyListeners();
  }

  void setupMqttClient() {
    client.logging(on: true);
    client.keepAlivePeriod = 6000;
    client.onConnected = _onConnected;
    client.onDisconnected = _onDisconnected;
    client.onSubscribed = _onSubscribed;
    final connMessage = MqttConnectMessage()
        .withClientIdentifier(Uuid().v4())
        .withWillQos(MqttQos.exactlyOnce);
    client.connectionMessage = connMessage;
    client.autoReconnect = true;
  }

  Future<void> connectClient() async {
    try {
      print('MQTTClientWrapper::Mosquitto client connecting....');
      connectionState = MqttCurrentConnectionState.CONNECTING;
      print("connecting -try block- $connectionState");
      await client.connect();
    } on Exception catch (e) {
      print('MQTTClientWrapper::client exception - $e');
      connectionState = MqttCurrentConnectionState.ERROR_WHEN_CONNECTING;
      print("connecting -catch block- $connectionState");
      client.disconnect();
    }
    if (client.connectionStatus.state == MqttConnectionState.connected) {
      connectionState = MqttCurrentConnectionState.CONNECTED;
      print("connecting -checking connected- $connectionState");
      print('MQTTClientWrapper::Mosquitto client connected$connectionState');
    } else {
      print(
          'MQTTClientWrapper::ERROR Mosquitto client connection failed - disconnecting, status is ${client.connectionStatus}');
      connectionState = MqttCurrentConnectionState.ERROR_WHEN_CONNECTING;
      client.disconnect();
    }
  }

  //upadting appcontext
  AppContext updateAppContext(AppContext context, MQMessage message) {
    HandlerResponse processResponse = processor.process(_appContext, message);
    _appContext = processResponse.context;
    return _appContext;
  }

  //subcribing to topics and listening..
  void subscribeToTopic(String topicName) {
    print('MQTTClientWrapper::Subscribing to the $topicName topic');
    client.subscribe(topicName, MqttQos.exactlyOnce);
    print(client.updates.isEmpty);
    client.updates.listen(
        (List<MqttReceivedMessage<MqttMessage>> mqttRecievedMessage) {
      final recMess = mqttRecievedMessage[0].payload as MqttPublishMessage;
      final topic = mqttRecievedMessage[0].topic;
      final mqttMessage =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      users = updateAppContext(_appContext, MQMessage(topic, mqttMessage))
          .appData
          .contacts;
      notifyListeners();
      alerts = updateAppContext(_appContext, MQMessage(topic, mqttMessage))
          .appData
          .alertMessages;
      notifyListeners();
      messages = updateAppContext(_appContext, MQMessage(topic, mqttMessage))
          .appData
          .dialogue;
      notifyListeners();
      print("MQTTClientWrapper::GOT A NEW MESSAGE $mqttMessage");
    }, onDone: () {
      client.connect();
    });
  }

  void _onConnected() {
    connectionState = MqttCurrentConnectionState.CONNECTED;
  }

  void _onDisconnected() {
    print(
        'MQTTClientWrapper::OnDisconnected client callback - Client disconnection');
    if (client.connectionStatus.returnCode ==
        MqttConnectReturnCode.noneSpecified) {
      print(
          'MQTTClientWrapper::OnDisconnected callback is solicited, this is correct');
    }
    connectionState = MqttCurrentConnectionState.DISCONNECTED;
    notifyListeners();
  }

  void _onSubscribed(String topic) {
    print('MQTTClientWrapper::Subscription confirmed for topic $topic');
    subscriptionState = MqttSubscriptionState.SUBSCRIBED;
    notifyListeners();
  }

  //preparing mqttclient..
  void prepareMqttClient() async {
    setupMqttClient();
    await connectClient();
    subscribeWelcome();
    subscribeRegister();
    subscribeToMyTopic();
    subscribeToAlertTopic();
    publishRegister();
    notifyListeners();
  }

  //publishing
  void publishMessage(String topic, String message) {
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(message);

    if (client.connectionStatus.state == MqttConnectionState.disconnected) {
      connectClient();
      Future.delayed(
        const Duration(seconds: 2),
        () =>
            client.publishMessage(topic, MqttQos.exactlyOnce, builder.payload),
      );
    } else {
      client.publishMessage(
        topic,
        MqttQos.exactlyOnce,
        builder.payload,
      );
    }
  }

  void sendRegisterMessage(String topic, dynamic paylod) {
    publishMessage(topic, paylod);
  }

  void subscribeWelcome() {
    subscribeToTopic('/JABBERWOCKEY/MACOM/TALK/WELCOME');
  }

  void subscribeRegister() {
    subscribeToTopic('/JABBERWOCKEY/MACOM/TALK/REGISTER');
  }

  void subscribeToMyTopic() {
    subscribeToTopic('/JABBERWOCKEY/MACOM/TALK/MESSAGE/${userDetails[0].myId}');
  }

  void subscribeToAlertTopic() {
    subscribeToTopic("/HPV/MACOM/ASHIRVAD/Health/1002");
  }

  void publishRegister() {
    print(uuid.v1());
    print(uuid.v4());
    PayloadRegister payload = PayloadRegister(
        payloadType: "RQRV1",
        iD: uuid.v1(),
        timeStamp: "2021-09-02T14:34:30.8019109\u002B05:30",
        user: userDetails[0].myId,
        name: userDetails[0].myname,
        dept: userDetails[0].mydept,
        callSign: userDetails[0].mynickname,
        status: "Online",
        platform: "WinX",
        content: "Registration Request");

    String topic = '/JABBERWOCKEY/MACOM/TALK/REGISTER';

    sendRegisterMessage(topic, payload.toString());
  }

  void sendMessage(
      TextEditingController message, String userid, String userName) {
    var uuid = Uuid();
    String topic = '/JABBERWOCKEY/MACOM/TALK/MESSAGE/$userid';
    Message messagePayload = Message(
        payloadType: "RQMV1",
        iD: uuid.v1(),
        timeStamp: "2021-09-02T14:34:30.8019109\u002B05:30",
        user: userDetails[0].myId,
        sendTo: userid,
        replyTo: "",
        responseType: ResponseTypes.None,
        contents: Content.fromPayload(
            Content(cid: "1001", body: message.text, type: "text")),
        response: "",
        receivedTimeStamp: DateTime.now().toString(),
        readTimeStamp: "",
        respondedTimeStamp: "");
    if (userid != null) {
      publishMessage(topic, messagePayload.toString());
    }
    messages = updateAppContext(
            _appContext, MQMessage(topic, messagePayload.toString()))
        .appData
        .dialogue;
    notifyListeners();
  }
}

enum MqttCurrentConnectionState {
  IDLE,
  CONNECTING,
  CONNECTED,
  DISCONNECTED,
  ERROR_WHEN_CONNECTING
}
enum MqttSubscriptionState { IDLE, SUBSCRIBED }
