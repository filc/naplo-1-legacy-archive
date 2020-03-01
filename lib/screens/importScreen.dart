import 'dart:convert' show json;
import 'dart:io';
import 'dart:ui';

import 'package:filcnaplo/screens/Screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:filcnaplo/Datas/User.dart';
import 'package:filcnaplo/Helpers/DBHelper.dart';
import 'package:filcnaplo/globals.dart' as globals;

void main() {
  runApp(MaterialApp(home: ImportScreen()));
}

class ImportScreen extends StatefulWidget {
  @override
  ImportScreenState createState() => ImportScreenState();
}

class ImportScreenState extends State<ImportScreen> {
  @override
  void initState() {
    super.initState();
    setState(() {
      initPath();
    });
    _showDialog();
  }

  void _showDialog() async {
    await Future.delayed(Duration(milliseconds: 50));
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Figyelem"),
          content: Text("Ez kitöröl minden meglévő felhasználót! (ha van)"),
          actions: <Widget>[
            FlatButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void initPath() async {
    path = (await getExternalStorageDirectory()).path + "/users.json";
    controller.text = path;
  }

  TextEditingController controller = TextEditingController();
  String path = "";

  @override
  Widget build(BuildContext context) {
    globals.context = context;
    return new Screen(
        new Text("Import"),
        new Center(
          child: Container(
            padding: EdgeInsets.all(20),
            child: new Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  new TextField(
                    onChanged: (text) {
                      path = text;
                    },
                    controller: controller,
                  ),
                  new Container(
                    child: new RaisedButton(
                      onPressed: () async {
                        PermissionHandler()
                            .requestPermissions([PermissionGroup.storage]).then(
                                (Map<PermissionGroup, PermissionStatus>
                                    permissions) async {
                          File importFile = new File(path);
                          List<Map<String, dynamic>> userMap = new List();
                          String data = importFile.readAsStringSync();
                          List<dynamic> userList = json.decode(data);
                          for (dynamic d in userList)
                            userMap.add(d as Map<String, dynamic>);

                          List<User> users = new List();
                          if (userMap.isNotEmpty)
                            for (Map<String, dynamic> m in userMap)
                              users.add(User.fromJson(m));
                          List<Color> colors = [
                            Colors.blue,
                            Colors.green,
                            Colors.red,
                            Colors.black,
                            Colors.brown,
                            Colors.orange
                          ];
                          Iterator<Color> cit = colors.iterator;
                          for (User u in users) {
                            cit.moveNext();
                            if (u.color.value == 0) u.color = cit.current;
                          }

                          DBHelper().saveUsersJson(users);

                          SystemChannels.platform
                              .invokeMethod('SystemNavigator.pop');
                        });
                      },
                      child: Text(
                        "Import",
                        style: TextStyle(color: Colors.white),
                      ),
                      color: Colors.green[700],
                    ),
                    color: Colors.green[700],
                  ),
                ]),
            margin: EdgeInsets.all(16),
          ),
        ),
        "/login",
        []);
  }
}
