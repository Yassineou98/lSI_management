// ignore_for_file: non_constant_identifier_names

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class IsIsecurity {
  final Storage = const FlutterSecureStorage();

  Future<String?> readUserName() async {
    String? val = await Storage.read(key: 'username');
    return val;
  }

  Future<String?> readPassword() async {
    String? val = await Storage.read(key: 'password');
    return val;
  }

  Future<void> writeUserName(String val) async {
    await Storage.write(key: 'username', value: val);
  }

  Future<void> writePassword(String val) async {
    await Storage.write(key: 'password', value: val);
  }
}
