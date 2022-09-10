// ignore_for_file: must_call_super

import 'dart:io';

import 'package:digital_isi/utils/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:convert';

import 'package:http/http.dart';

import '../utils/loadingtoProcessList.dart';
import '../utils/process.dart';

class LoadingProcessList extends StatefulWidget {
  const LoadingProcessList({Key? key}) : super(key: key);

  @override
  State<LoadingProcessList> createState() => _LoadingProcessListState();
}

class _LoadingProcessListState extends State<LoadingProcessList> {
  String ecodeCredentials(String username, String pass) {
    String credentials = '$username:$pass';
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    String encoded = stringToBase64.encode(credentials);
    return encoded;
  }

  Future init() async {
    IsIsecurity storage = IsIsecurity();
    String name = await storage.readUserName() ?? '';
    String pass = await storage.readPassword() ?? '';
    String auth_cred = ecodeCredentials(name, pass);
    Response response = await get(
      Uri.parse(
          '${dotenv.env['BASE_URL']}/${dotenv.env['PROCESS_DEF_API']}?${dotenv.env['PROCESS_DEF_PRAM']}'),
      headers: {HttpHeaders.authorizationHeader: 'Basic $auth_cred'},
    );
    List data = jsonDecode(response.body);
    List<Process> listProcess = [];
    for (int i = 0; i < data.length; i++) {
      listProcess.add(Process(id: data[i]['id'], name: data[i]['name']));
    }
    Navigator.pushReplacementNamed(context, '/processList',
        arguments: LoadingtoProcessList(
            nbProcesses: listProcess.length, processes: listProcess));
  }

  @override
  void initState() {
    init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 24, 89, 141),
        body: Center(
          child: SpinKitFadingCircle(
            color: Colors.white,
            size: 80.0,
          ),
        ));
  }
}
