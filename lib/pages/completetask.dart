import 'dart:convert';
import 'dart:io';

import 'package:digital_isi/utils/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';

import '../utils/process.dart';
import '../utils/taskObject.dart';
import '../utils/variable.dart';

class Completetask extends StatefulWidget {
  const Completetask({Key? key}) : super(key: key);

  @override
  State<Completetask> createState() => _CompletetaskState();
}

class _CompletetaskState extends State<Completetask> {
  List<TaskObject> fields = [];
  Map<String, TextEditingController> textEditingControllers = {};
  Map<String, bool> boolVals = {};
  var form = <Widget>[];
  Process task = Process(id: '', name: '');
  IsIsecurity secureStorage = IsIsecurity();
  String ecodeCredentials(String username, String pass) {
    String credentials = '$username:$pass';
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    String encoded = stringToBase64.encode(credentials);
    return encoded;
  }

  Future<void> getTaskFormVars(String id) async {
    String name = await secureStorage.readUserName() ?? '';
    String pas = await secureStorage.readPassword() ?? '';
    String authHeader = ecodeCredentials(name, pas);
    Response response = await get(
        Uri.parse(
            '${dotenv.env['BASE_URL']}/${dotenv.env['TASK_API']}/$id/${dotenv.env['FORM_VAR_API']}'),
        headers: <String, String>{
          HttpHeaders.authorizationHeader: 'Basic $authHeader',
        });
    Map x = jsonDecode(response.body);
    List<TaskObject> l = [];
    x.forEach((key, val) {
      l.add(TaskObject(
          name: key, type: val['type'], value: val['value'].toString()));
    });

    setState(() {
      fields = l;
    });
  }

  bool StringToBool(String s) {
    if (s.toLowerCase() == 'true') {
      return true;
    } else {
      return false;
    }
  }

  void showSuccessToast() => Fluttertoast.showToast(
      msg: 'Task Completed successfully.',
      fontSize: 18,
      backgroundColor: Colors.green,
      gravity: ToastGravity.TOP_RIGHT);

  void showFailToast() => Fluttertoast.showToast(
      msg: 'Complete failed.',
      fontSize: 18,
      backgroundColor: Colors.red,
      gravity: ToastGravity.TOP_RIGHT);

  Future<void> onCompletePress(
      Map<String, TextEditingController> textEditingControllers,
      Map<String, bool> checks,
      String id) async {
    Map<String, TaskObject> x = {};
    String name = await secureStorage.readUserName() ?? '';
    String pas = await secureStorage.readPassword() ?? '';
    String authHeader = ecodeCredentials(name, pas);

    fields.forEach((str) {
      if (str.type == 'String') {
        x.putIfAbsent(
            str.name,
            () => TaskObject(
                name: str.name,
                type: str.type,
                value: textEditingControllers[str.name]!.text));
      } else {
        x.putIfAbsent(
            str.name,
            () => TaskObject(
                name: str.name,
                type: str.type,
                value: checks[str.name].toString()));
      }
    });
    List<Variable> r = [];

    x.forEach((key, val) {
      if (val.type == 'boolean') {
        Variable a = Variable(name: key, value: {
          'value': StringToBool(val.value),
          'type': val.type,
          'valueInfo': {}
        });
        r.add(a);
      } else {
        Variable a = Variable(
            name: key,
            value: {'value': val.value, 'type': val.type, 'valueInfo': {}});
        r.add(a);
      }
    });
    Map z = {};
    for (int i = 0; i < r.length; i++) {
      z.putIfAbsent(r[i].name, () => r[i].value);
    }
    Map body = {"variables": z};
    String b = jsonEncode(body);
    debugPrint(b);
    Response response = await post(
        Uri.parse(
            '${dotenv.env['BASE_URL']}/${dotenv.env['TASK_API']}/$id/${dotenv.env['COMPLETE_TASK_API']}'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          HttpHeaders.authorizationHeader: 'Basic $authHeader',
        },
        body: b);
    if (response.statusCode == 204) {
      showSuccessToast();
      Navigator.pushReplacementNamed(context, '/mytasks');
    } else {
      showFailToast();
    }
  }

  myTaskOnPress() {
    Navigator.pushReplacementNamed(context, '/mytasks');
  }

  @override
  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      task = ModalRoute.of(context)!.settings.arguments as Process;
      getTaskFormVars(task.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    for (int i = 0; i < fields.length; i++) {
      if (fields[i].type == 'String') {
        var textEditingController =
            TextEditingController(text: fields[i].value);
        textEditingControllers.putIfAbsent(
            fields[i].name, () => textEditingController);
        form.add(
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
                controller: textEditingController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: fields[i].name,
                )),
          ),
        );
      } else {
        var valid = StringToBool(fields[i].value);
        boolVals.putIfAbsent(fields[i].name, () => valid);
        form.add(
          ListTile(
            leading: Checkbox(
              value: boolVals[fields[i].name],
              onChanged: (x) {
                form = [];
                textEditingControllers = {};
                setState(() {
                  boolVals[fields[i].name] = x!;
                });
              },
            ),
            title: Text(fields[i].name),
          ),
        );
      }
    }
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 22, 99, 187),
          title: Text(task.name),
          centerTitle: true,
          elevation: 0.0,
          automaticallyImplyLeading: false,
          actions: [
            // Si on choisit notification button
            IconButton(
              icon: Icon(Icons.circle_notifications_outlined),
              onPressed: () => myTaskOnPress(),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 60),
          child: SingleChildScrollView(
              child: Column(
            children: <Widget>[
              Column(children: form),
              SizedBox(
                height: 25,
              ),
              Material(
                color: Color.fromARGB(255, 233, 176, 19),
                borderRadius: BorderRadius.circular(30.0),
                elevation: 5.0,
                child: MaterialButton(
                  onPressed: () => onCompletePress(
                      textEditingControllers, boolVals, task.id),
                  minWidth: 200.0,
                  height: 42.0,
                  child: Text(
                    'Complete task',
                    style: TextStyle(color: Colors.white, fontSize: 25),
                  ),
                ),
              ),
              SizedBox(
                height: 130,
              ),
            ],
          )),
        ));
  }
}
