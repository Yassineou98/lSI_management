import 'dart:convert';
import 'dart:io';

import 'package:digital_isi/utils/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';

import '../utils/task.dart';
import '../utils/process.dart';

class Mytasks extends StatefulWidget {
  const Mytasks({Key? key}) : super(key: key);

  @override
  State<Mytasks> createState() => _MytasksState();
}

class _MytasksState extends State<Mytasks> {
  IsIsecurity secureStorage = IsIsecurity();
  int nbTasks = 0;
  List<Task> tasks = [];
  String id = '';

  onPressCard(String id, String name) {
    Navigator.pushReplacementNamed(context, '/completetask',
        arguments: Process(id: id, name: name));
  }

  myTaskOnPress() {}
  String ecodeCredentials(String username, String pass) {
    String credentials = '$username:$pass';
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    String encoded = stringToBase64.encode(credentials);
    return encoded;
  }

  Future<void> getMyTasks(String id) async {
    String name = await secureStorage.readUserName() ?? '';
    String pas = await secureStorage.readPassword() ?? '';
    String authHeader = ecodeCredentials(name, pas);
    Response response = await get(
        Uri.parse(
            '${dotenv.env['BASE_URL']}/${dotenv.env['TASK_API']}?assignee=$name'),
        headers: <String, String>{
          HttpHeaders.authorizationHeader: 'Basic $authHeader',
        });
    List data = jsonDecode(response.body);
    List<Task> mytasks = [];
    for (int i = 0; i < data.length; i++) {
      String date = data[i]['created'].substring(0, 10);
      String time = data[i]['created'].substring(11, 16);
      mytasks.add(Task(
          id: data[i]['id'], name: data[i]['name'], date: date, time: time));
    }

    setState(() {
      nbTasks = mytasks.length;
      tasks = mytasks;
    });
  }

  @override
  void initState() {
    getMyTasks(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Color.fromARGB(255, 22, 99, 187),
            title: Text("My Tasks ($nbTasks)"),
            centerTitle: true,
            elevation: 0.0,
            automaticallyImplyLeading: false,
            actions: <Widget>[
              // button logout
              IconButton(
                icon: Icon(Icons.exit_to_app_sharp),
                onPressed: () =>
                    {Navigator.pushReplacementNamed(context, '/login')},
              ),
            ]),
        body: ListView.builder(
          itemCount: nbTasks,
          itemBuilder: (context, index) {
            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6.0),
              child: Card(
                child: ListTile(
                  onTap: () => onPressCard(tasks[index].id, tasks[index].name),
                  leading: Text(tasks[index].name),
                  title: Text('${tasks[index].date} - ${tasks[index].time}',
                      style: TextStyle(fontSize: 11)),
                ),
              ),
            );
          },
        ));
  }
}
