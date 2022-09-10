// ignore_for_file: prefer_const_constructors, must_call_super

import 'dart:convert';
import 'dart:io';

import 'package:digital_isi/utils/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';

import '../utils/variable.dart';

class Generateform extends StatefulWidget {
  const Generateform({Key? key}) : super(key: key);

  @override
  State<Generateform> createState() => _GenerateformState();
}

class _GenerateformState extends State<Generateform> {
  List<String> data = [];
  IsIsecurity secureStorage = IsIsecurity();
  String id = '';
  Map<String, TextEditingController> textEditingControllers = {};
  var textFields = <Widget>[];

  final _formKey = GlobalKey<FormState>();

  String ecodeCredentials(String username, String pass) {
    String credentials = '$username:$pass';
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    String encoded = stringToBase64.encode(credentials);
    return encoded;
  }

  Future<void> sendhttpRequest(String id) async {
    String name = await secureStorage.readUserName() ?? '';
    String pass = await secureStorage.readPassword() ?? '';
    String authHeader = ecodeCredentials(name, pass);
    final response = await get(
      Uri.parse(
          '${dotenv.env['BASE_URL']}/${dotenv.env['PROCESS_DEF_API']}/$id/${dotenv.env['FORM_VAR_API']}'),
      // Send authorization headers to the backend.
      headers: {
        HttpHeaders.authorizationHeader: 'Basic $authHeader',
      },
    );
    Map x = jsonDecode(response.body);
    List<String> feild = [];
    for (var key in x.keys) {
      feild.add(key);
    }

    //refresh build
    setState(() {
      data = feild;
    });
  }

  void showSuccessToast() => Fluttertoast.showToast(
      msg: 'From successfully sent',
      fontSize: 18,
      backgroundColor: Color.fromARGB(255, 9, 119, 13),
      gravity: ToastGravity.TOP_RIGHT);

  void showFailToast() => Fluttertoast.showToast(
      msg: 'Erreur while sending',
      fontSize: 18,
      backgroundColor: Color.fromARGB(255, 158, 28, 19),
      gravity: ToastGravity.TOP_RIGHT);

  Future<void> onSendpress(
      Map<String, TextEditingController> textEditingControllers,
      String id) async {
    String name = await secureStorage.readUserName() ?? '';
    String pass = await secureStorage.readPassword() ?? '';
    String authHeader = ecodeCredentials(name, pass);
//setup body
    Map<String, String> x = {};
    for (var str in data) {
      x.putIfAbsent(str, () => textEditingControllers[str]!.text);
    }
    Map z = {};
    x.forEach((key, val) {
      Variable a = Variable(
          name: key, value: {'value': val, 'type': 'String', 'valueInfo': {}});
      z.putIfAbsent(a.name, () => a.value);
    });
    Map body = {"variables": z};
    String b = jsonEncode(body);

    Response response = await post(
        Uri.parse(
            '${dotenv.env['BASE_URL']}/${dotenv.env['PROCESS_DEF_API']}/$id/${dotenv.env['SUBMIT_FORM_API']}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          HttpHeaders.authorizationHeader: 'Basic $authHeader',
        },
        body: b);
    if (response.statusCode == 200) {
      showSuccessToast();
      Navigator.pushNamed(context, '/loadingProcessList');
    } else {
      showFailToast();
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      id = ModalRoute.of(context)!.settings.arguments as String;
      sendhttpRequest(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    for (var str in data) {
      var textEditingController = TextEditingController();
      textEditingControllers.putIfAbsent(str, () => textEditingController);
      textFields.add(TextFormField(
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'veuillez remplir le champ vide';
            }
            return null;
          },
          controller: textEditingController,
          decoration: InputDecoration(
            hintText: 'Writing...',
            contentPadding:
                EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(32.0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: Color.fromARGB(255, 233, 176, 19), width: 1.0),
              borderRadius: BorderRadius.all(Radius.circular(32.0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: Color.fromARGB(255, 22, 99, 187), width: 2.0),
              borderRadius: BorderRadius.all(Radius.circular(32.0)),
            ),
            labelText: str,
          )));
    }
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 22, 99, 187),
          title: Text("Form Page"),
          centerTitle: true,
          elevation: 0.0,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 10),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Form(key: _formKey, child: Column(children: textFields)),
                SizedBox(height: 25),
                Material(
                    color: Color.fromARGB(255, 233, 176, 19),
                    borderRadius: BorderRadius.circular(30.0),
                    elevation: 5.0,
                    child: MaterialButton(
                      onPressed: () => {
                        if (_formKey.currentState!.validate())
                          {onSendpress(textEditingControllers, id)}
                        else
                          {showFailToast()}
                      },
                      minWidth: 200.0,
                      height: 42.0,
                      child: Text(
                        'Send',
                        style: TextStyle(color: Colors.white, fontSize: 25),
                      ),
                    )),
                SizedBox(
                  height: 150,
                ),
              ],
            ),
          ),
        ));
  }
}
