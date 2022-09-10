import 'package:flutter/material.dart';

class ProcessORtaskPage extends StatelessWidget {
  const ProcessORtaskPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 22, 99, 187),
          title: Text("ProcessORtask Page"),
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
      body: Column(children: [
        // Si on choisit process button
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/loadingProcessList');
            },
            child: Text('Process List',
                style: TextStyle(
                    color: Color.fromARGB(255, 233, 176, 19),
                    fontSize: 17,
                    decoration: TextDecoration.underline)),
          ),
        ),
        // Si on choisit task button
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/taskLoading');
            },
            child: Text(
              'Task List',
              style: TextStyle(
                  color: Color.fromARGB(255, 233, 176, 19),
                  fontSize: 17,
                  decoration: TextDecoration.underline),
            ),
          ),
        ),
      ]),
    );
  }
}
