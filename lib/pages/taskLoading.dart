// ignore_for_file: must_call_super

import 'dart:convert';
import 'dart:io';

import 'package:digital_isi/utils/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart';

import '../utils/loadingToTask.dart';
import '../utils/task.dart';

class TaskLoading extends StatefulWidget {
  const TaskLoading({Key? key}) : super(key: key);

  @override
  State<TaskLoading> createState() => _TaskLoadingState();
}

class _TaskLoadingState extends State<TaskLoading> {
  IsIsecurity secureStorage = IsIsecurity();
  String authHeader = '';

  String ecodeCredentials(String username, String pass) {
    String credentials = '$username:$pass';
    Codec<String, String> stringToBase64;
    stringToBase64 = utf8.fuse(base64);
    String encoded = stringToBase64.encode(credentials);
    return encoded;
  }

  Future<void> getTaskList() async {
    String name = await secureStorage.readUserName() ?? '';
    String pas = await secureStorage.readPassword() ?? '';
    String authHeader = ecodeCredentials(name, pas);
    Response responce = await get(
      Uri.parse(
          '${dotenv.env['BASE_URL']}/${dotenv.env['TASK_API']}?unassigned=true'),
      // Send authorization headers to the backend.
      headers: {
        HttpHeaders.authorizationHeader: 'Basic $authHeader',
      },
    );
    List data = jsonDecode(responce.body);
    List<Task> processes = [];
    for (int i = 0; i < data.length; i++) {
      String date = data[i]['created'].substring(0, 10);
      String time = data[i]['created'].substring(11, 16);
      processes.add(Task(
          id: data[i]['id'], name: data[i]['name'], date: date, time: time));
    }
    Navigator.pushReplacementNamed(context, '/tasksList',
        arguments: LoadingToTask(nbTask: processes.length, tasks: processes));
  }

  @override
  void initState() {
    getTaskList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 22, 99, 187),
        body: Center(
          child: SpinKitFadingCircle(
            color: Color.fromARGB(255, 241, 241, 241),
            size: 80.0,
          ),
        ));
  }
}
