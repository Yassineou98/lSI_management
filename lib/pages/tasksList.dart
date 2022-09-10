// ignore_for_file: unused_local_variable

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';

import '../utils/loadingToTask.dart';
import '../utils/storage.dart';
import '../utils/task.dart';

class TasksList extends StatefulWidget {
  const TasksList({Key? key}) : super(key: key);

  @override
  State<TasksList> createState() => _TasksListState();
}

class _TasksListState extends State<TasksList> {
  IsIsecurity secureStorage = IsIsecurity();

  void onPressCard(String id) {}

  void showSuccessToast() => Fluttertoast.showToast(
      msg: 'Task claimed successfully.',
      fontSize: 18,
      backgroundColor: Colors.green,
      gravity: ToastGravity.TOP_RIGHT);
  void showFailToast() => Fluttertoast.showToast(
      msg: 'Claim failed.',
      fontSize: 18,
      backgroundColor: Colors.red,
      gravity: ToastGravity.TOP_RIGHT);

  String ecodeCredentials(String username, String pass) {
    String credentials = '$username:$pass';
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    String encoded = stringToBase64.encode(credentials);
    return encoded;
  }

  void claim(String id) async {
    String name = await secureStorage.readUserName() ?? '';
    String pas = await secureStorage.readPassword() ?? '';
    String authHeader = ecodeCredentials(name, pas);
    Map body = {"userId": name};
    String b = jsonEncode(body);
    Response response = await post(
        Uri.parse(
            '${dotenv.env['BASE_URL']}/${dotenv.env['TASK_API']}/$id/${dotenv.env['CLAIM_TASK_API']}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          HttpHeaders.authorizationHeader: 'Basic $authHeader',
        },
        body: b);
    // show toast based on the result
    if (response.statusCode == 204) {
      showSuccessToast();
      Navigator.pushReplacementNamed(context, '/taskLoading');
    } else {
      showFailToast();
    }
  }

  myTaskOnPress() {
    Navigator.pushNamed(context, '/mytasks');
  }

  showAlertDialog(BuildContext context, String id) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Yes"),
      onPressed: () => claim(id),
    );
    Widget continueButton = TextButton(
      child: Text("No"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    AlertDialog alert = AlertDialog(
      title: Text("Confirm"),
      content: Text("Do you really want to claim this task ?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  onClaimPress(String id) {
    showAlertDialog(context, id);
  }

  @override
  Widget build(BuildContext context) {
    final data = ModalRoute.of(context)!.settings.arguments as LoadingToTask;
    List<Task> processes = data.tasks;
    int nbProcesses = data.nbTask;
    return Scaffold(
        appBar: AppBar(
          actions: [
            // Si on choisit notification button
            IconButton(
              icon: Icon(Icons.circle_notifications_outlined),
              onPressed: () => myTaskOnPress(),
            ),
            // Si on choisit logout button
            IconButton(
              icon: Icon(Icons.exit_to_app_sharp),
              onPressed: () => {
                Navigator.pushReplacementNamed(context, '/login')
              }, // The `_decrementCounter` function
            ),
          ],
          backgroundColor: Color.fromARGB(255, 22, 99, 187),
          title: Text("Tasks List (${nbProcesses}) "),
          centerTitle: true,
          elevation: 0.0,
        ),
        body: ListView.builder(
            itemCount: nbProcesses,
            itemBuilder: (context, index) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6.0),
                child: Card(
                  child: ListTile(
                    onTap: () => onPressCard(processes[index].id),
                    trailing: TextButton(
                        onPressed: () => onClaimPress(processes[index].id),
                        child: Text('Claim')),
                    leading: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(processes[index].name,
                              style: TextStyle(fontSize: 13)),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            '${processes[index].date}  ${processes[index].time}',
                            style: TextStyle(fontSize: 9),
                          ),
                        ]),
                  ),
                ),
              );
            }));
  }
}
