import 'package:digital_isi/pages/completetask.dart';
import 'package:digital_isi/pages/generateform.dart';
import 'package:digital_isi/pages/processList.dart';
import 'package:digital_isi/pages/processORtaskPage.dart';
import 'package:digital_isi/pages/loadingProcessList.dart';
import 'package:digital_isi/pages/login.dart';
import 'package:digital_isi/pages/myTasks.dart';
import 'package:digital_isi/pages/taskLoading.dart';
import 'package:digital_isi/pages/tasksList.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future main() async {
  await dotenv.load(fileName: ".env");
  runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => Login(),
        '/loadingProcessList': (context) => LoadingProcessList(),
        '/processList': (context) => ProcessList(),
        '/generateform': (context) => Generateform(),
        '/processORtaskPage': (context) => ProcessORtaskPage(),
        '/taskLoading': (context) => TaskLoading(),
        '/tasksList': (context) => TasksList(),
        '/mytasks': (context) => Mytasks(),
        '/completetask': (context) => Completetask(),
      }));
}
