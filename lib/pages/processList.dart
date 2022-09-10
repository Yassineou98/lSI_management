import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../utils/loadingtoProcessList.dart';
import '../utils/process.dart';
import '../utils/storage.dart';

class ProcessList extends StatefulWidget {
  const ProcessList({Key? key}) : super(key: key);

  @override
  State<ProcessList> createState() => _ProcessListState();
}

class _ProcessListState extends State<ProcessList> {
  
  onPressCard(String id) {
    Navigator.pushReplacementNamed(context, '/generateform', arguments: id);
  }

  @override
  Widget build(BuildContext context) {
    //les données nécessaires au build
    final data =
        ModalRoute.of(context)!.settings.arguments as LoadingtoProcessList;
    List<Process> processes = data.processes;
    int nbProcesses = data.nbProcesses;

    return Scaffold(
        appBar: AppBar(
            backgroundColor: Color.fromARGB(255, 22, 99, 187),
            title: Text("Process List"),
            centerTitle: true,
            elevation: 0.0,
            automaticallyImplyLeading: false,
            actions: <Widget>[
              // button logout
              IconButton(
                icon: Icon(Icons.exit_to_app_sharp),
                onPressed: () => {
                  Navigator.pushReplacementNamed(context, '/login')
                }, // The `_decrementCounter` function
              ),
            ]),
        body: ListView.builder(
          itemCount: nbProcesses,
          itemBuilder: (context, index) {
            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6.0),
              child: Card(
                child: ListTile(
                    onTap: () => onPressCard(processes[index].id),
                    title: Text(processes[index].name)),
              ),
            );
          },
        ));
  }
}
