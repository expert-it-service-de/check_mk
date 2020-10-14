import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:package_info/package_info.dart';
import 'package:device_identifier/device_identifier.dart';
import 'package:flutter/services.dart';
import 'package:check_mk/models/todo-item.dart';
import 'package:check_mk/services/db.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DB.init();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Check_MK',
      home: MyCustomForm(),
    );
  }
}

// Define a custom Form widget.
class MyCustomForm extends StatefulWidget {
  @override
  _MyCustomFormState createState() => _MyCustomFormState();
}

// Define a corresponding State class.
// This class holds the data related to the Form.
class _MyCustomFormState extends State<MyCustomForm> {


  String postDataSelvice = 'is_service_acknowledged=0&view_name=svcproblems';
  String postDataAllhost = 'is_host_acknowledged=0&view_name=allhosts';
  String posDataEvents = '&view_name=events_dash';

  MaterialColor color = Colors.grey;
  String serverstatus = "Check";
  bool serverstatusboll = false;

  int _indexonTap = 0;
  String watoText = 'WATO';
  String downtimelistText = 'Dowmtime';
  String commentslistText = 'Comments';
  MaterialColor watoColor = Colors.grey;

  MaterialColor color2 = Colors.grey;
  String serverstatus2 = "Check";
  bool serverstatusboll2 = false;

  double iconSize = 40;


  final checkmkurl = TextEditingController();
  final key = TextEditingController();
  final user = TextEditingController();

  final key2 = TextEditingController();
  final user2 = TextEditingController();



  final downtimecomment = TextEditingController();

  final searchHost = TextEditingController();

  var refreshKey = GlobalKey<RefreshIndicatorState>();

  bool isSwitched = false;

  String deviceid = '';
  String appName = '';
  String packageName = '';
  String version = '';
  String buildNumber = '';

  List<String> commentsOFservice = [];
  List<String> getdowtimeOFservice = [];

  List<TodoService> _allServiceInfo = [];
  List<TodoService> _singleHostServiceInfo = [];
  List<TodoLastEvent> _lastEventInfo = [];
  List<TodoAllHost> _allHostInfo = [];
  List<TodoService> _serviceCheck = [];
  List<TodoAllHost> _allHostCheck = [];


  List<SetupApp> _appSetupCheck = [];

  String httpData;

  List<Widget> get _allServiceWidgetList =>
      _allServiceInfo.map((item) => allService_format(item)).toList();

  List<Widget> get _allHostWidgetList =>
      _allHostInfo.map((item) => allHost_format(item)).toList();

  List<Widget> get _singleHostServiceWidgetList => _singleHostServiceInfo
      .map((item) => singleHostService_format(item))
      .toList();

  List<Widget> get _lastEventWidgetList =>
      _lastEventInfo.map((item) => lastEvent_format(item)).toList();

  final Duration timeLimit = new Duration(seconds: 3);

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void dispose() {
    checkmkurl.dispose();
    key.dispose();
    user.dispose();
    key2.dispose();
    user2.dispose();
    super.dispose();
  }

  @override
  void initState() {
    setcontrol();
    getinfo();
    onerun();
    timerloop();

    super.initState();
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    var android = new AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOS = new IOSInitializationSettings();
    var initSetttings = new InitializationSettings(android, iOS);

    flutterLocalNotificationsPlugin.initialize(initSetttings,
        onSelectNotification: onSelectNotification);
  }

// disign

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Check MK app'),
      ),
      body: Container(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: new Column(
            children: <Widget>[
              new Center(
                child: Container(
                  child: new FlatButton.icon(
                      color: Colors.blue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: EdgeInsets.all(20.0),
                      //onPressed: showNotification,
                      onPressed: getlistservice,
                      icon: Icon(Icons.bug_report, color: Colors.white),
                      label: Text("Untreated services problems",
                          style: new TextStyle(
                              fontSize: 17.0, color: Colors.white))),
                  padding: const EdgeInsets.all(10.0),
                ),
              ),
              new Center(
                child: Container(
                  child: new FlatButton.icon(
                      color: Colors.blue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: EdgeInsets.all(20.0),
                      onPressed: () {
                        getlisthosts("");
                      },
                      icon: Icon(Icons.view_list, color: Colors.white),
                      label: Text("All hosts status overview",
                          style: new TextStyle(
                              fontSize: 17.0, color: Colors.white))),
                  padding: const EdgeInsets.all(10.0),
                ),
              ),
              new Center(
                child: Container(
                  child: new FlatButton.icon(
                      color: Colors.blue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: EdgeInsets.all(20.0),
                      onPressed: () {
                        getlistservice4();
                      },
                      icon: Icon(Icons.notification_important,
                          color: Colors.white),
                      label: Text("Events of the last 4 hours",
                          style: new TextStyle(
                              fontSize: 17.0, color: Colors.white))),
                  padding: const EdgeInsets.all(10.0),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: new BottomNavigationBar(
          unselectedFontSize: 17.0,
          selectedFontSize: 17.0,
          showUnselectedLabels: true,
          showSelectedLabels: true,
          items: [
            new BottomNavigationBarItem(
              icon: new Icon(Icons.public, color: color),
              title: new Text("Internet: " + serverstatus,
                  style: TextStyle(fontSize: 17.0, color: color)),
            ),
            new BottomNavigationBarItem(
              icon: new Icon(Icons.sync, color: color2),
              title: new Text("Check MK: " + serverstatus2,
                  style: TextStyle(fontSize: 17.0, color: color2)),
            )
          ]),
      floatingActionButton: new FloatingActionButton.extended(
        onPressed: () {
          getsetings();
        },
        icon: Icon(Icons.settings),
        label: Text("Settings"),
      ),
    );
  }

  Future onSelectNotification(
    String payload,
  ) {
    //debugPrint("payload : $payload");
    showDialog(
      context: context,
      builder: (_) => new AlertDialog(
        title: new Text('Notification'),
        content: new Text('$payload'),
      ),
    );
    //return Future.value(true);
  }

  Future<void> getlistservice() async {
    await deleteold();
    await refreshdb();
    showDialog(
      context: context,
      builder: (context) {
        return Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: AppBar(
            title: Text('Untreated services problems'),
            actions: <Widget>[
              Row(
                children: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () async {
                      await getDataService();
                      await Future.delayed(Duration(seconds: 1));
                      Navigator.pop(context);
                      getlistservice();
                    },
                  ),
                ],
              ),
            ],
          ),
          body: Container(
            child: ListView(children: _allServiceWidgetList),
          ),
        );
      },
    );
  }

  void getlisthosts(String host) async {
    if (host.isEmpty) {
      await deleteold2();
      await refreshdb2();
    } else {
      await refreshdb2h(host);
    }
    showDialog(
      context: context,
      builder: (context) {
        return Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: AppBar(
            title: Text('All hosts status overview'),
            actions: <Widget>[
              Row(
                children: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      searchhost();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () async {
                      await getDataAllHost();
                      await Future.delayed(Duration(seconds: 1));
                      Navigator.pop(context);
                      getlisthosts("");
                    },
                  ),
                ],
              ),
            ],
          ),
          body: Container(
            child: ListView(children: _allHostWidgetList),
          ),
        );
      },
    );
  }

  void getsetings() {
    showDialog(
      context: context,
      builder: (context) {
        return Scaffold(
          //backgroundColor:  Colors.grey[200],
          appBar: AppBar(title: Text('Settings')),
          body: Center(
            child: SingleChildScrollView(
              child: Column(children: <Widget>[
                TextField(
                    autofocus: true,
                    controller: checkmkurl,
                    style: new TextStyle(fontSize: 16.0, color: Colors.black),
                    keyboardType: TextInputType.url,
                    inputFormatters: <TextInputFormatter>[
                      // LengthLimitingTextInputFormatter(10),
                      // WhitelistingTextInputFormatter.digitsOnly,
                      // BlacklistingTextInputFormatter
                      //  .singleLineFormatter,
                    ],
                    decoration: new InputDecoration(
                        labelText: 'URL',
                        hintText: 'http://my-check-mk.com/observer/',
                        contentPadding: EdgeInsets.all(14))),
                Text(
                  "Automation Check_mk user",
                  style: TextStyle(
                    height: 2,
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
                TextField(
                    autofocus: true,
                    controller: user,
                    style: new TextStyle(fontSize: 16.0, color: Colors.black),
                    // keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      // LengthLimitingTextInputFormatter(6),
                      // WhitelistingTextInputFormatter.digitsOnly,
                      // BlacklistingTextInputFormatter
                      // .singleLineFormatter,
                    ],
                    decoration: new InputDecoration(
                        labelText: 'Username',
                        hintText: 'username',
                        contentPadding: EdgeInsets.all(14))),
                TextField(
                    autofocus: true,
                    controller: key,
                    style: new TextStyle(fontSize: 16.0, color: Colors.black),
                    // keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      // LengthLimitingTextInputFormatter(6),
                      // WhitelistingTextInputFormatter.digitsOnly,
                      //BlacklistingTextInputFormatter
                      // .singleLineFormatter,
                    ],
                    decoration: new InputDecoration(
                        labelText: 'Automation secret for machine accounts',
                        hintText: 'CGVIWSFSO@1TRKEOY4@Y',
                        contentPadding: EdgeInsets.all(15))),
                Text(
                  "Base HTTP",
                  style: TextStyle(
                    height: 2,
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
                TextField(
                    autofocus: true,
                    controller: user2,
                    style: new TextStyle(fontSize: 16.0, color: Colors.black),
                    // keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      // LengthLimitingTextInputFormatter(6),
                      // WhitelistingTextInputFormatter.digitsOnly,
                      //BlacklistingTextInputFormatter
                      // .singleLineFormatter,
                    ],
                    decoration: new InputDecoration(
                        labelText: 'Base HTTP user',
                        hintText: 'username',
                        contentPadding: EdgeInsets.all(14))),
                TextField(
                    autofocus: true,
                    controller: key2,
                    style: new TextStyle(fontSize: 16.0, color: Colors.black),
                    // keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      // LengthLimitingTextInputFormatter(6),
                      // WhitelistingTextInputFormatter.digitsOnly,
                      //BlacklistingTextInputFormatter
                      //.singleLineFormatter,
                    ],
                    decoration: new InputDecoration(
                        labelText: 'Base HTTP password',
                        hintText: 'tr54Tqaw3Rg1!',
                        contentPadding: EdgeInsets.all(15))),
                                MaterialButton(
                  //onPressed: showNotification,
                  onPressed: savesetup,
                  child: new Text("Save",
                      style:
                          new TextStyle(fontSize: 17.0, color: Colors.white)),
                  color: Colors.blue,
                  // padding: const EdgeInsets.all(15.0),
                ),
                Text(
                  "Version: " + version + " Build " + buildNumber,
                  style: TextStyle(
                    height: 2,
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  "ID: " + deviceid,
                  style: TextStyle(
                    height: 1,
                    fontSize: 6,
                    color: Colors.grey,
                  ),
                ),
              ]),
            ),
          ),
        );
      },
    );
  }

  Widget lastEvent_format(TodoLastEvent item) {
    MaterialColor eventcolor;
    if (item.state == "CRIT") {
      eventcolor = Colors.red;
    }
    if (item.state == "WARN") {
      eventcolor = Colors.amber;
    }
    if (item.state == "UNKN") {
      eventcolor = Colors.orange;
    }
    if (item.state == "OK") {
      eventcolor = Colors.green;
    }
    if (item.state == "NOTIF") {
      eventcolor = Colors.grey;
    }

    return Table(
      //child: Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: {
        0: FractionColumnWidth(.37),
        1: FractionColumnWidth(.22),
        2: FractionColumnWidth(.31),
        3: FractionColumnWidth(.1)
      },
      //  columnWidths: { 3: FractionColumnWidth(.1)},
      //  key: Key(item.id.toString()),
      border: TableBorder.all(),
      children: [
        TableRow(
            //  key: Key(item.id.toString()),
            children: [
              item.id != 1
                  ? Column(children: [
                      Text(
                        item.state.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          height: 1,
                          fontSize: 17,
                          color: eventcolor,
                        ),
                      ),
                      Text(
                        item.log_time.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          height: 1,
                          fontSize: 17,
                        ),
                      ),
                    ])
                  : Column(children: [
                      Text("Status/Time",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            height: 1.5,
                            fontSize: 17,
                          ))
                    ]),
              item.id != 1
                  ? Column(children: [Text(item.host.toString())])
                  : Column(children: [
                      Text("Host",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            height: 1.5,
                            fontSize: 17,
                          ))
                    ]),
              item.id != 1
                  ? Column(
                      children: [Text(item.service_description.toString())])
                  : Column(children: [
                      Text("Service",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            height: 1.5,
                            fontSize: 17,
                          ))
                    ]),
              item.id != 1
                  ? Column(children: [
                      IconButton(
                        icon: const Icon(
                          Icons.info,
                          color: Colors.blueAccent,
                        ),
                        onPressed: () async {
                          info(
                              item.host.toString(),
                              item.service_description.toString(),
                              item.log_plugin_output.toString(),
                              eventcolor,
                              item.state.toString());
                        },
                      ),
                    ])
                  : Column(children: [
                      Text(
                        "Info",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          height: 1.5,
                          fontSize: 17,
                        ),
                      )
                    ]),
            ]),
      ],
      //),
    );
  }

  void _onItemTapped(int index, String host, String service,
      String log_plugin_output, Color eventcolor, String state) {
    if (index == 0) {
      info(host, service, log_plugin_output, eventcolor, state);
    }
    if (index == 1) {
      wato(host, service, log_plugin_output, eventcolor, state);
    }
    if (index == 2) {
      watocoment(host, service, log_plugin_output, eventcolor, state);
    }
    if (index == 3) {
      watogetdowntime(host, service, log_plugin_output, eventcolor, state);
    }
  }

  Widget allService_format(TodoService item) {
    MaterialColor eventcolor;
    if (item.service_state == "CRIT") {
      eventcolor = Colors.red;
    }
    if (item.service_state == "WARN") {
      eventcolor = Colors.amber;
    }
    if (item.service_state == "UNKN") {
      eventcolor = Colors.orange;
    }
    if (item.service_state == "OK") {
      eventcolor = Colors.green;
    }
    if (item.service_state == "PEND") {
      eventcolor = Colors.grey;
    }
    return Container(
      child: Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        columnWidths: {
          0: FractionColumnWidth(.37),
          1: FractionColumnWidth(.22),
          2: FractionColumnWidth(.31),
          3: FractionColumnWidth(.1)
        },
        //  columnWidths: { 3: FractionColumnWidth(.1)},
        key: Key(item.id.toString()),
        border: TableBorder.all(),
        children: [
          TableRow(children: [
            item.id != 1
                ? Column(children: [
                    Text(
                      item.service_state.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        height: 1,
                        fontSize: 17,
                        color: eventcolor,
                      ),
                    ),
                    Text(item.svc_state_age.toString())
                  ])
                : Column(children: [
                    Text("Status",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          height: 1.5,
                          fontSize: 17,
                        ))
                  ]),
            item.id != 1
                ? Column(children: [Text(item.host.toString())])
                : Column(children: [
                    Text("Host",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          height: 1.5,
                          fontSize: 17,
                        ))
                  ]),
            item.id != 1
                ? Column(children: [Text(item.service_description.toString())])
                : Column(children: [
                    Text("Service",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          height: 1.5,
                          fontSize: 17,
                        ))
                  ]),
            item.id != 1
                ? Column(children: [
                    IconButton(
                      icon: const Icon(
                        Icons.info,
                        color: Colors.blueAccent,
                      ),
                      onPressed: () async {
                        info(
                            item.host.toString(),
                            item.service_description.toString(),
                            item.svc_plugin_output.toString(),
                            eventcolor,
                            item.service_state.toString());
                      },
                    ),
                  ])
                : Column(children: [
                    Text(
                      "Info",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        height: 1.5,
                        fontSize: 17,
                      ),
                    )
                  ]),
          ]),
        ],
      ),
    );
  }

  Widget singleHostService_format(TodoService item) {
    MaterialColor eventcolor;
    if (item.service_state == "CRIT") {
      eventcolor = Colors.red;
    }
    if (item.service_state == "WARN") {
      eventcolor = Colors.amber;
    }
    if (item.service_state == "UNKN") {
      eventcolor = Colors.orange;
    }
    if (item.service_state == "OK") {
      eventcolor = Colors.green;
    }
    if (item.service_state == "PEND") {
      eventcolor = Colors.grey;
    }

    return Container(
      child: Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        columnWidths: {
          0: FractionColumnWidth(.37),
          1: FractionColumnWidth(.41),
          2: FractionColumnWidth(.1)
        },
        //  columnWidths: { 3: FractionColumnWidth(.1)},
        key: Key(item.id.toString()),
        border: TableBorder.all(),
        children: [
          TableRow(children: [
            item.id != 1
                ? Column(children: [
                    Text(
                      item.service_state.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        height: 1,
                        fontSize: 17,
                        color: eventcolor,
                      ),
                    ),
                    Text(item.svc_state_age.toString()),
                  ])
                : Column(children: [
                    Text("Status",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          height: 1.5,
                          fontSize: 17,
                        ))
                  ]),
            item.id != 1
                ? Column(children: [Text(item.service_description.toString())])
                : Column(children: [
                    Text("Service",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          height: 1.5,
                          fontSize: 17,
                        ))
                  ]),
            item.id != 1
                ? Column(children: [
                    IconButton(
                      icon: const Icon(
                        Icons.info,
                        color: Colors.blueAccent,
                      ),
                      onPressed: () async {
                        info(
                            item.host.toString(),
                            item.service_description.toString(),
                            item.svc_plugin_output.toString(),
                            eventcolor,
                            item.service_state.toString());
                      },
                    ),
                  ])
                : Column(children: [
                    Text(
                      "Info",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        height: 1.5,
                        fontSize: 17,
                      ),
                    )
                  ]),
          ]),
        ],
      ),
    );
  }

  Widget allHost_format(TodoAllHost item) {
    MaterialColor eventcolor;
    if (item.host_state == "DOWN") {
      eventcolor = Colors.red;
    }
    if (item.host_state == "UP") {
      eventcolor = Colors.green;
    }
    return Container(
      child: Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        columnWidths: {
          0: FractionColumnWidth(.13),
          1: FractionColumnWidth(.20),
          2: FractionColumnWidth(.1),
          3: FractionColumnWidth(.12),
          4: FractionColumnWidth(.12),
          5: FractionColumnWidth(.11),
          6: FractionColumnWidth(.11),
          7: FractionColumnWidth(.1)
        },
        //columnWidths: {7: FractionColumnWidth(.1)},

        key: Key(item.id.toString()),
        border: TableBorder.all(),
        children: [
          TableRow(children: [
            item.id != 1
                ? Column(children: [
                    Text(
                      item.host_state.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        height: 1.5,
                        fontSize: 16,
                        color: eventcolor,
                      ),
                    )
                  ])
                : Column(children: [
                    Text(
                      "Status",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        height: 1.5,
                        fontSize: 15,
                      ),
                    )
                  ]),
            item.id != 1
                ? Column(children: [Text(item.host.toString())])
                : Column(children: [
                    Text(
                      "Host",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        height: 1.5,
                        fontSize: 15,
                      ),
                    )
                  ]),
            item.id != 1
                ? Column(children: [
                    Text(
                      item.num_services_ok.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        height: 1,
                        fontSize: 16,
                        color: Colors.green,
                      ),
                    )
                  ])
                : Column(children: [
                    Text(
                      "OK",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        height: 1.5,
                        fontSize: 15,
                      ),
                    )
                  ]),
            item.id != 1
                ? Column(children: [
                    Text(
                      item.num_services_warn.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        height: 1,
                        fontSize: 16,
                        color: Colors.amber,
                      ),
                    )
                  ])
                : Column(children: [
                    Text(
                      "WARN",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        height: 1.5,
                        fontSize: 15,
                      ),
                    )
                  ]),
            item.id != 1
                ? Column(children: [
                    Text(
                      item.num_services_unknown.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        height: 1,
                        fontSize: 16,
                        color: Colors.orange,
                      ),
                    )
                  ])
                : Column(children: [
                    Text(
                      "UNKN",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        height: 1.5,
                        fontSize: 15,
                      ),
                    )
                  ]),
            item.id != 1
                ? Column(children: [
                    Text(
                      item.num_services_crit.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        height: 1,
                        fontSize: 16,
                        color: Colors.red,
                      ),
                    )
                  ])
                : Column(children: [
                    Text(
                      "CRIT",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        height: 1.5,
                        fontSize: 15,
                      ),
                    )
                  ]),
            item.id != 1
                ? Column(children: [
                    Text(
                      item.num_services_pending.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        height: 1,
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    )
                  ])
                : Column(children: [
                    Text(
                      "PEND",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        height: 1.5,
                        fontSize: 15,
                      ),
                    )
                  ]),
            item.id != 1
                ? Column(children: [
                    IconButton(
                      icon: const Icon(
                        Icons.info,
                        color: Colors.blueAccent,
                      ),
                      onPressed: () async {
                        await hostinfo(item.host.toString());
                        getlistservice2(item.host.toString());
                      },
                    ),
                  ])
                : Column(children: [
                    Text(
                      "Info",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        height: 1.5,
                        fontSize: 15,
                      ),
                    )
                  ]),
          ]),
        ],
      ),
      //),
    );
  }

  void getlistservice4() async {
    //await getDataEvent();
    await refreshdb4();
    showDialog(
      context: context,
      builder: (context) {
        return Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: AppBar(
            //leading:  Icon(Icons.notification_important,color: Colors.white),

            title: Text("Events of the last 4 hours"),

            actions: <Widget>[
              Row(
                children: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () async {
                      await getDataEvent();
                      await Future.delayed(Duration(seconds: 1));
                      Navigator.pop(context);
                      getlistservice4();
                    },
                  ),
                ],
              ),
            ],
          ),
          body: Container(
            child: ListView(children: _lastEventWidgetList),
            // child: ListView(  shrinkWrap: true,
            //padding: const EdgeInsets.all(20.0),children: _lastEventWidgetList),
          ),
        );
      },
    );
  }

  void watocoment(String host, String service, String log_plugin_output,
      Color eventcolor, String state) async {
    await getcommetts(host, service);
    showDialog(
      context: context,
      builder: (context) {
        return Scaffold(
          //backgroundColor:  Colors.grey[200],
          appBar: AppBar(
              backgroundColor: eventcolor, title: Text(host + ":" + service)),
          body: new ListView.builder(
              itemCount: commentsOFservice.length,
              itemBuilder: (context, index) {
                return new ListTile(
                  title: new Text('${commentsOFservice[index]}'),
                );
              }),
          bottomNavigationBar: new BottomNavigationBar(
              onTap: (newIndex) => {
                    setState(() => _indexonTap = newIndex),
                    _onItemTapped(_indexonTap, host, service, log_plugin_output,
                        eventcolor, state)
                  },
              currentIndex: _indexonTap,
              type: BottomNavigationBarType.fixed,
              unselectedFontSize: 12.0,
              selectedFontSize: 15.0,
              showUnselectedLabels: true,
              showSelectedLabels: true,
              items: [
                new BottomNavigationBarItem(
                  icon: new Icon(Icons.info, color: watoColor),
                  title: new Text("Info",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black)),
                ),
                new BottomNavigationBarItem(
                  icon: new Icon(Icons.gavel, color: watoColor),

                  title: new Text(watoText,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black)),
                ),
                new BottomNavigationBarItem(
                  icon: new Icon(Icons.comment, color: watoColor),
                  title: new Text(commentslistText,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black)),
                ),
                new BottomNavigationBarItem(
                  icon: new Icon(Icons.pause_circle_filled, color: watoColor),
                  title: new Text(downtimelistText,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black)),
                )
              ]),
        );
      },
    );
  }

  void watogetdowntime(String host, String service, String log_plugin_output,
      Color eventcolor, String state) async {
    await getdowtime(host, service);
    showDialog(
      context: context,
      builder: (context) {
        return Scaffold(
          //backgroundColor:  Colors.grey[200],
          appBar: AppBar(
              backgroundColor: eventcolor, title: Text(host + ":" + service)),

          body: new ListView.builder(
              itemCount: getdowtimeOFservice.length,
              itemBuilder: (context, index) {
                return new ListTile(
                  title: new Text('${getdowtimeOFservice[index]}'),
                );
              }),
          bottomNavigationBar: new BottomNavigationBar(
              onTap: (newIndex) => {
                    setState(() => _indexonTap = newIndex),
                    _onItemTapped(_indexonTap, host, service, log_plugin_output,
                        eventcolor, state)
                  },
              currentIndex: _indexonTap,
              type: BottomNavigationBarType.fixed,
              unselectedFontSize: 12.0,
              selectedFontSize: 15.0,
              showUnselectedLabels: true,
              showSelectedLabels: true,
              items: [
                new BottomNavigationBarItem(
                  icon: new Icon(Icons.info, color: watoColor),
                  title: new Text("Info",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black)),
                ),
                new BottomNavigationBarItem(
                  icon: new Icon(Icons.gavel, color: watoColor),
                  title: new Text(watoText,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black)),
                ),
                new BottomNavigationBarItem(
                  icon: new Icon(Icons.comment, color: watoColor),
                  title: new Text(commentslistText,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black)),
                ),
                new BottomNavigationBarItem(
                  icon: new Icon(Icons.pause_circle_filled, color: watoColor),
                  title: new Text(downtimelistText,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black)),
                )
              ]),
        );
      },
    );
  }

  //
  void info(
    String host,
    String service,
    String log_plugin_output,
    Color eventcolor,
    String state,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: eventcolor,
            title: Text(host.toString() + " " + state.toString()),
          ),
          body: Container(
            child: SingleChildScrollView(
              child: Column(children: <Widget>[
                Text(
                  service.toString(),
                  style: TextStyle(
                    height: 3,
                    fontSize: 17,
                    color: eventcolor,
                  ),
                ),
                Text(
                  log_plugin_output.toString(),
                  style: TextStyle(
                    height: 1.5,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ]),
            ),
          ),
          bottomNavigationBar: new BottomNavigationBar(
              onTap: (newIndex) => {
                    setState(() => _indexonTap = newIndex),
                    _onItemTapped(
                        _indexonTap,
                        host.toString(),
                        service.toString(),
                        log_plugin_output.toString(),
                        eventcolor,
                        state.toString())
                  },
              currentIndex: _indexonTap,
              type: BottomNavigationBarType.fixed,
              unselectedFontSize: 12.0,
              selectedFontSize: 15.0,
              showUnselectedLabels: true,
              showSelectedLabels: true,
              items: [
                new BottomNavigationBarItem(
                  icon: new Icon(Icons.info, color: watoColor),
                  title: new Text("Info",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black)),
                ),
                new BottomNavigationBarItem(
                  icon: new Icon(Icons.gavel, color: watoColor),
                  title: new Text(watoText,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black)),
                ),
                new BottomNavigationBarItem(
                  icon: new Icon(Icons.comment, color: watoColor),
                  title: new Text(commentslistText,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black)),
                ),
                new BottomNavigationBarItem(
                  icon: new Icon(Icons.pause_circle_filled, color: watoColor),
                  title: new Text(downtimelistText,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black)),
                )
              ]),
        );
      },
    );
  }

  //

  void wato(String host, String service, String log_plugin_output,
      Color eventcolor, String state) {
    getcommetts(host, service);
    showDialog(
      context: context,
      builder: (context) {
        return Scaffold(
          //backgroundColor:  Colors.grey[200],
          appBar: AppBar(
            backgroundColor: eventcolor,
            title: Text('WATO'),
          ),
          body: Container(
            child: Center(
              child: SingleChildScrollView(
                child: Column(children: <Widget>[
                  Text(
                    "Host: " + host,
                    style: TextStyle(
                      height: 2,
                      fontSize: 19,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    "Service: " + service,
                    style: TextStyle(
                      height: 2,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  TextField(
                      autofocus: false,
                      controller: downtimecomment,
                      style: new TextStyle(fontSize: 16.0, color: Colors.black),
                      // keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        // LengthLimitingTextInputFormatter(6),
                        // WhitelistingTextInputFormatter.digitsOnly,
                        // BlacklistingTextInputFormatter
                        // .singleLineFormatter,
                      ],
                      decoration: new InputDecoration(
                          labelText: 'comment',
                          hintText: 'comment',
                          contentPadding: EdgeInsets.all(14))),
                  new Center(
                    child: Container(
                      child: new FlatButton.icon(
                          color: Colors.blue,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding: EdgeInsets.all(12.0),
                          onPressed: () async {
                            setdowntime(host, service, downtimecomment.text,
                                '&_downrange__7200=2+hours', '2 h');
                          },
                          icon: Icon(Icons.notifications_paused,
                              color: Colors.white),
                          label: Text("Downtime 2h",
                              style: new TextStyle(
                                  fontSize: 17.0, color: Colors.white))),
                      padding: const EdgeInsets.all(10.0),
                    ),
                  ),
                  new Center(
                    child: Container(
                      child: new FlatButton.icon(
                          color: Colors.blue,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding: EdgeInsets.all(12.0),
                          onPressed: () async {
                            setdowntime(host, service, downtimecomment.text,
                                '&_downrange__next_day=Today', 'Today');
                          },
                          icon: Icon(Icons.notifications_paused,
                              color: Colors.white),
                          label: Text("Downtime today",
                              style: new TextStyle(
                                  fontSize: 17.0, color: Colors.white))),
                      padding: const EdgeInsets.all(10.0),
                    ),
                  ),
                  new Center(
                    child: Container(
                      child: new FlatButton.icon(
                          color: Colors.blue,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding: EdgeInsets.all(12.0),
                          onPressed: () async {
                            setdowntime(
                                host,
                                service,
                                downtimecomment.text,
                                '&_downrange__next_week=This week',
                                'This week');
                          },
                          icon: Icon(Icons.notifications_paused,
                              color: Colors.white),
                          label: Text("Downtime this week",
                              style: new TextStyle(
                                  fontSize: 17.0, color: Colors.white))),
                      padding: const EdgeInsets.all(10.0),
                    ),
                  ),
                  new Center(
                    child: Container(
                      child: new FlatButton.icon(
                          color: Colors.blue,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding: EdgeInsets.all(12.0),
                          onPressed: () async {
                            setcomment(
                              host,
                              service,
                              downtimecomment.text,
                            );
                          },
                          icon: Icon(Icons.add_comment, color: Colors.white),
                          label: Text("Comment",
                              style: new TextStyle(
                                  fontSize: 17.0, color: Colors.white))),
                      padding: const EdgeInsets.all(10.0),
                    ),
                  ),
                  new Center(
                    child: Container(
                      child: new Text(
                        log_plugin_output,
                        style: TextStyle(
                          height: 2,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      padding: const EdgeInsets.all(10.0),
                    ),
                  ),
                ]),
              ),
            ),
          ),
          bottomNavigationBar: new BottomNavigationBar(
              onTap: (newIndex) => {
                    setState(() => _indexonTap = newIndex),
                    _onItemTapped(_indexonTap, host, service, log_plugin_output,
                        eventcolor, state)
                  },
              currentIndex: _indexonTap,
              type: BottomNavigationBarType.fixed,
              unselectedFontSize: 12.0,
              selectedFontSize: 15.0,
              showUnselectedLabels: true,
              showSelectedLabels: true,
              items: [
                new BottomNavigationBarItem(
                  icon: new Icon(Icons.info, color: watoColor),
                  title: new Text("Info",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black)),
                ),
                new BottomNavigationBarItem(
                  icon: new Icon(Icons.gavel, color: watoColor),
                  title: new Text(watoText,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black)),
                ),
                new BottomNavigationBarItem(
                  icon: new Icon(Icons.comment, color: watoColor),
                  title: new Text(commentslistText,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black)),
                ),
                new BottomNavigationBarItem(
                  icon: new Icon(Icons.pause_circle_filled, color: watoColor),
                  title: new Text(downtimelistText,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black)),
                )
              ]
          ),
        );
      },
    );
  }

  void getlistservice2(host) async {
    showDialog(
      context: context,
      builder: (context) {
        return Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: AppBar(
            title: Text(host),
            actions: <Widget>[
              Row(
                children: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () async {
                      await hostinfo(host);
                      await Future.delayed(Duration(seconds: 1));
                      Navigator.pop(context);
                      getlistservice2(host);
                    },
                  ),
                ],
              ),
            ],
          ),
          body: Container(
            child: ListView(children: _singleHostServiceWidgetList),
          ),
        );
      },
    );
  }

  void searchhost() {
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Search host'),
          actions: <Widget>[
            FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Cancel')),
          ],
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                    autofocus: false,
                    controller: searchHost,
                    style: new TextStyle(fontSize: 16.0, color: Colors.black),
                    // keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      // LengthLimitingTextInputFormatter(6),
                      // WhitelistingTextInputFormatter.digitsOnly,
                      // BlacklistingTextInputFormatter
                      // .singleLineFormatter,
                    ],
                    decoration: new InputDecoration(
                        labelText: 'host',
                        hintText: 'host',
                        contentPadding: EdgeInsets.all(14))),
                new Center(
                  child: Container(
                    child: new FlatButton.icon(
                        color: Colors.blue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: EdgeInsets.all(12.0),
                        onPressed: () async {
                          Navigator.of(context).pop(false);
                          //refreshdb2h(searchHost.text);
                          //await Future.delayed(Duration(seconds: 1));
                          getlisthosts(searchHost.text);
                        },
                        icon: Icon(Icons.search, color: Colors.white),
                        label: Text("Search hours",
                            style: new TextStyle(
                                fontSize: 17.0, color: Colors.white))),
                    padding: const EdgeInsets.all(10.0),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

//funkcions

  void timerloop() async {
    Timer.periodic(Duration(seconds: 60), (timer) async {
      onerun();
    });
  }

  void onerun() async {
    await getonlinestatus();
    await getDataService();
    await getDataAllHost();
    await getDataEvent();
  }

  void getonlinestatusloop() async {
    Timer.periodic(Duration(seconds: 30), (timer) async {
      getonlinestatus();
    });
  }

  //sava setup
  void savesetup() async {
    SetupApp item = SetupApp(
      url: checkmkurl.text,
      user: user.text,
      key: key.text,
      user2: user2.text,
      key2: key2.text,
    );
    await setupcheck();
    if (_appSetupCheck.isNotEmpty) {
      await DB.update2(SetupApp.table, item);
    } else {
      await DB.insert(SetupApp.table, item);
    }
    getDataService();
    getDataAllHost();
    getDataEvent();
  }

  void setcontrol() async {
    await setupcheck();
    if (_appSetupCheck.isNotEmpty) {
      checkmkurl.text = _appSetupCheck.first.url;
      key.text = _appSetupCheck.first.key;
      user.text = _appSetupCheck.first.user;
      key2.text = _appSetupCheck.first.key2;
      user2.text = _appSetupCheck.first.user2;

    }
  }

  Future<void> setupcheck() async {
    List<Map<String, dynamic>> _results = await DB.check2(SetupApp.table);
    _appSetupCheck =
        _results.map((itemchecks) => SetupApp.fromMap(itemchecks)).toList();
    setState(() {});
  }

//

// save and update events

  Future<void> uidheck(String uid) async {
    List<Map<String, dynamic>> _results =
        await DB.check(TodoService.table, uid);
    _serviceCheck =
        _results.map((itemchecks) => TodoService.fromMap(itemchecks)).toList();
    setState(() {});
  }

  Future<void> uidheck2(String uid) async {
    List<Map<String, dynamic>> _results =
        await DB.check(TodoAllHost.table, uid);
    _allHostCheck =
        _results.map((itemchecks) => TodoAllHost.fromMap(itemchecks)).toList();
    setState(() {});
  }

  ///

  // refres

  Future<void> hostinfo(String host) async {
    await getDataSingleHostService(host);

    List<Map<String, dynamic>> _results =
        await DB.queryhost(TodoService.table, host);
    _singleHostServiceInfo =
        _results.map((item) => TodoService.fromMap(item)).toList();

    setState(() {});
  }

  Future<void> refreshdb() async {
    // await getDataService();

    List<Map<String, dynamic>> _results = await DB.query(TodoService.table);
    _allServiceInfo =
        _results.map((item) => TodoService.fromMap(item)).toList();

    setState(() {});
  }

  Future<void> refreshdb2() async {
    //await getDataAllHost();

    List<Map<String, dynamic>> _results = await DB.query(TodoAllHost.table);
    _allHostInfo = _results.map((item) => TodoAllHost.fromMap(item)).toList();
    setState(() {});
  }

  Future<void> refreshdb2h(String host) async {
    //await getDataAllHost();

    List<Map<String, dynamic>> _results =
        await DB.queryhost(TodoAllHost.table, host);
    _allHostInfo = _results.map((item) => TodoAllHost.fromMap(item)).toList();
    setState(() {});
  }

  Future<void> refreshdb4() async {
    //  await getDataEvent();

    // await getDataService();

    List<Map<String, dynamic>> _results = await DB.query(TodoLastEvent.table);
    _lastEventInfo =
        _results.map((item) => TodoLastEvent.fromMap(item)).toList();

    setState(() {});
  }

  Future<Null> refreshdb3() async {
    refreshKey.currentState?.show(atTop: false);

    getDataAllHost();
    await Future.delayed(Duration(seconds: 2));
    List<Map<String, dynamic>> _results = await DB.query(TodoAllHost.table);
    _allHostInfo = _results.map((item) => TodoAllHost.fromMap(item)).toList();
    setState(() {});
  }

  ///

//sustem

  void getinfo() async {
    deviceid = await DeviceIdentifier.deviceId;
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    appName = packageInfo.appName;
    packageName = packageInfo.packageName;
    version = packageInfo.version;
    buildNumber = packageInfo.buildNumber;
  }

//

  // chek online

  Future<void> getonlinestatus() async {
    // Timer.periodic(Duration(seconds: 30), (timer)  async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        // print('connected');
        setState(() => this.serverstatus = 'Online');
        setState(() => this.color = Colors.green);
        setState(() => this.serverstatusboll = true);
      }
    } on SocketException catch (_) {
      setState(() => this.serverstatus = 'Offline');
      setState(() => this.color = Colors.red);
      setState(() => this.serverstatusboll = false);

      setState(() => this.serverstatus2 = 'Offline');
      setState(() => this.color2 = Colors.red);
      setState(() => this.serverstatusboll2 = false);
    }
    return Future.value(true);
  }

//

  // events

  Future<void> deleteold() async {
    //  Timer.periodic(Duration(seconds: 5), (timer)  async {
    await setupcheck();
    if (_appSetupCheck.isNotEmpty && serverstatusboll == true) {
      int TimeNowMius1Min = new DateTime.now().millisecondsSinceEpoch - 120000;
      DB.delete(TodoService.table, TimeNowMius1Min);
    }
    //   });
  }

  Future<void> deleteold2() async {
    //  Timer.periodic(Duration(seconds: 5), (timer)  async {
    await setupcheck();
    if (_appSetupCheck.isNotEmpty && serverstatusboll == true) {
      int TimeNowMius1Min = new DateTime.now().millisecondsSinceEpoch - 120000;
      DB.delete(TodoAllHost.table, TimeNowMius1Min);
    }
    //   });
  }





  Future<void> dataconnect(String postData) async {
    await setupcheck();
    if (_appSetupCheck.isNotEmpty) {
      var apiUrl = Uri.parse(
        _appSetupCheck.first.url + 'check_mk/view.py',
      );
      var client = HttpClient();
      client.badCertificateCallback = ((X509Certificate cert, String host, int port) => true);
      client.addCredentials(
          Uri.parse(apiUrl.toString()),
          'realm',
          new HttpClientBasicCredentials(
              _appSetupCheck.first.user2, _appSetupCheck.first.key2));
      HttpClientRequest request = await client.postUrl(apiUrl);
      request.headers.contentType = new ContentType(
          "application", "x-www-form-urlencoded",
          charset: "utf-8");

      var postdata = postData +
          "&output_format=json&_username=" +
          _appSetupCheck.first.user +
          "&_secret=" +
          _appSetupCheck.first.key;

      request.write(postdata);
      HttpClientResponse response = await request.close();
      final contentAsString = await utf8.decodeStream(response);
      httpData = contentAsString;
      // ERROR: Invalid automation secret for user app1
      if (response.statusCode == 200 &&
          response.headers.contentType.toString() ==
              'application/json; charset=utf-8') {
        setState(() => this.color2 = Colors.green);
        setState(() => this.serverstatus2 = "Connect");
        setState(() => this.serverstatusboll2 = true);

        deleteold();
      }
      if (httpData.contains("Invalid automation secret for user")) {
        setState(() => this.color2 = Colors.red);
        setState(() => this.serverstatus2 = "Error autch");
        setState(() => this.serverstatusboll2 = false);
      }
    } else {
      setState(() => this.color2 = Colors.red);
      setState(() => this.serverstatus2 = "Settings null");
      setState(() => this.serverstatusboll2 = false);
    }
    setState(() {});

    return [httpData];
  }

  Future<void> getDataService() async {
    await setupcheck();
    if (_appSetupCheck.isNotEmpty) {
      await dataconnect(postDataSelvice);

      List<dynamic> events = json.decode(httpData);
      for (var x = 0; x < events.length; x++) {

        Digest md5uid =
        md5.convert(utf8.encode(events[x][0] + events[x][1] + events[x][2]));
        int sort = 0;
        if (events[x][0] == "CRIT") {
          sort = 1;
        }
        if (events[x][0] == "WARN") {
          sort = 3;
        }
        if (events[x][0] == "UNKN") {
          sort = 2;
        }

        TodoService item = TodoService(
            uid: md5uid.toString(),
            updatedate: new DateTime.now().millisecondsSinceEpoch,
            service_state: events[x][0],
            host: events[x][1],
            service_description: events[x][2],
            service_icons: events[x][3],
            svc_plugin_output: events[x][4],
            svc_state_age: events[x][5],
            svc_check_age: events[x][6],
            perfometer: events[x][7],
            sort: sort,
            sorce: 1);

        await uidheck(md5uid.toString());
        if (_serviceCheck.isNotEmpty) {
          await DB.update(TodoService.table, item, item.uid);
        } else {
          await DB.insert(TodoService.table, item);

          _showNotificationWithDefaultSound(
              item.service_state,
              item.host,
              item.service_description,
              item.svc_plugin_output,
              md5uid.toString());
        }
      }
      return Future.value(true);
    }
  }

  Future<void> getDataAllHost() async {
    await setupcheck();
    if (_appSetupCheck.isNotEmpty) {
      await dataconnect(postDataAllhost);

      List<dynamic> events = json.decode(httpData);
      for (var x = 0; x < events.length; x++) {

        Digest md5uid =
        md5.convert(utf8.encode(events[x][0] + events[x][1] + events[x][2]));
        int sort = 0;
        if (events[x][0] == "DOWN") {
          sort = 1;
        }
        if (events[x][0] == "UP") {
          sort = 3;
        }


        TodoAllHost item = TodoAllHost(
            uid: md5uid.toString(),
            updatedate: new DateTime.now().millisecondsSinceEpoch,
            host_state: events[x][0],
            host: events[x][1],
            host_icons: events[x][2],
            num_services_ok: events[x][3],
            num_services_warn: events[x][4],
            num_services_unknown: events[x][5],
            num_services_crit: events[x][6],
            num_services_pending: events[x][7],
            sort: sort,
            sorce: 1);

        await uidheck2(md5uid.toString());
        if (_allHostCheck.isNotEmpty) {
          await DB.update(TodoAllHost.table, item, item.uid);
        } else {
          await DB.insert(TodoAllHost.table, item);
          _showNotificationWithDefaultSound2(
              item.host_state, item.host, md5uid.toString());
        }
      }
      return Future.value(true);
    }
  }

  Future<void> getDataSingleHostService(String host) async {
    await setupcheck();
    if (_appSetupCheck.isNotEmpty) {


    await dataconnect("host=" + host + "&view_name=host");
    List<dynamic> events = json.decode(httpData);
    for (var x = 1; x < events.length; x++) {
      Digest md5uid =
          md5.convert(utf8.encode(events[x][0] + host + events[x][1]));
      int sort = 0;
      if (events[x][0] == "CRIT") {
        sort = 1;
      }
      if (events[x][0] == "WARN") {
        sort = 3;
      }
      if (events[x][0] == "UNKN") {
        sort = 2;
      }
      if (events[x][0] == "OK") {
        sort = 4;
      }

      TodoService item = TodoService(
          uid: md5uid.toString(),
          updatedate: new DateTime.now().millisecondsSinceEpoch,
          service_state: events[x][0],
          host: host,
          service_description: events[x][1],
          service_icons: events[x][2],
          svc_plugin_output: events[x][3],
          svc_state_age: events[x][4],
          svc_check_age: events[x][5],
          perfometer: events[x][6],
          sort: sort,
          sorce: 2);

      await uidheck(md5uid.toString());
      if (_serviceCheck.isNotEmpty) {
        await DB.update(TodoService.table, item, item.uid);
      } else {
        await DB.insert(TodoService.table, item);
      }
    }
    return Future.value(true);
    }
  }

  Future<void> getDataEvent() async {
    await setupcheck();
    if (_appSetupCheck.isNotEmpty) {
      await dataconnect(posDataEvents);

      List<dynamic> events = json.decode(httpData);

      int TimeNowMius1Min = new DateTime.now().millisecondsSinceEpoch;
      await DB.deleteall(TodoLastEvent.table, TimeNowMius1Min);

      for (var x = 0; x < events.length; x++) {
        //var bytes = utf8.encode(events[x][0]+events[x][1]+events[x][2]);
        var arrlog_plugin_output = events[x][4].split('-');
        var state = arrlog_plugin_output.first.trim();

        Digest md5uid =
        md5.convert(utf8.encode(state + events[x][2] + events[x][3]));
        //   print(events[x][0] + " " + events[x][1]);
        //print(state);
        int sort = x;
        if (state.toString() != "OK" &&
            state.toString() != "CRIT" &&
            state.toString() != "WARN" &&
            state.toString() != "UNKN") {
          state = "NOTIF";
        }

        TodoLastEvent item = TodoLastEvent(
            uid: md5uid.toString(),
            updatedate: new DateTime.now().millisecondsSinceEpoch,
            state: state,
            host: events[x][2],
            service_description: events[x][3],
            log_icon: events[x][0],
            log_plugin_output: events[x][4],
            log_time: events[x][1],
            sort: sort,
            sorce: 1);
        await DB.insert(TodoLastEvent.table, item);
      }
      return Future.value(true);
    }
  }

  Future<void> getdowtime(String host, String service) async {
    await dataconnect("service=" +
        service +
        "&"
            "host=" +
        host +
        "&"
            "view_name=downtimes_of_service");
    List<dynamic> events = json.decode(httpData);

    getdowtimeOFservice = [];
    for (var x = 1; x < events.length; x++) {
      getdowtimeOFservice.add(events[x].toString());
    }
    setState(() {});
  }

  Future<void> getcommetts(String host, String service) async {
    await dataconnect("service=" +
        service +
        "&"
            "host=" +
        host +
        "&"
            "view_name=comments_of_service");
    List<dynamic> events = json.decode(httpData);

    commentsOFservice = [];
    for (var x = 1; x < events.length; x++) {
      commentsOFservice.add(events[x].toString());
    }
    setState(() {});
  }

  // notif
  _showNotificationWithDefaultSound(status, host, service, info, md5uid) async {
    var android = new AndroidNotificationDetails(md5uid, status, host,
        priority: Priority.High, importance: Importance.Max);
    var iOS = new IOSNotificationDetails();
    var platform = new NotificationDetails(android, iOS);
    await flutterLocalNotificationsPlugin.show(
        0, host + ":" + status, service, platform,
        payload: host + " " + service + " " + info);
  }

  _showNotificationWithDefaultSound2(status, host, md5uid) async {
    var android = new AndroidNotificationDetails(md5uid, status, host,
        priority: Priority.High, importance: Importance.Max);
    var iOS = new IOSNotificationDetails();
    var platform = new NotificationDetails(android, iOS);
    await flutterLocalNotificationsPlugin.show(0, host, ":" + status, platform,
        payload: host + " " + status);
  }

//

  void setdowntime(String host, String service, String downtimecomment,
      String tupe, String info) async {
    if (downtimecomment.isEmpty) {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Downtime set'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Comment Err'),
                ],
              ),
            ),
          );
        },
      );
    } else {
      await dataconnect(
          "_do_confirm=Yes&_transid=-1&_do_actions=yes&actions=yes&actions=yes&"
                  "service=" +
              service +
              "&"
                  "host=" +
              host +
              "&"
                  "view_name=service&"
                  "_down_comment=" +
              downtimecomment +
              tupe +
              "&_do_actions=Yes");
      if (httpData.contains("Successfully sent 1 commands")) {
        return showDialog<void>(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Downtime set'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text('Successfully sent 1 commands'),
                    Text(host + " " + service + "downtime " + info),
                  ],
                ),
              ),
            );
          },
        );
      }
    }
  }

  void setcomment(String host, String service, String downtimecomment) async {
    if (downtimecomment.isEmpty) {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Downtime set'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Comment Err'),
                ],
              ),
            ),
          );
        },
      );
    } else {
      await dataconnect(
          "_do_confirm=Yes&_transid=-1&_do_actions=yes&actions=yes&actions=yes&"
                  "service=" +
              service +
              "&"
                  "host=" +
              host +
              "&"
                  "view_name=service&"
                  "&_acknowledge=Acknowledge&_ack_sticky=on&_ack_notify=on&_ack_expire_days=0&_ack_expire_hours=0&_ack_expire_minutes=0&"
                  "_ack_comment=" +
              downtimecomment +
              "&_do_actions=Yes");
      //  print(contentAsString);
      if (httpData.contains("Successfully sent 1 commands")) {
        return showDialog<void>(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Comment set'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text('Successfully sent 1 commands'),
                    Text(host + " " + service + "comments"),
                  ],
                ),
              ),
            );
          },
        );
      }
    }
  }
}
