import 'package:flutter/foundation.dart';

class NetworkLog {
  final String url;
  final String method;
  final String response;

  NetworkLog({required this.url, required this.method, required this.response});
}

class NetworkLogger with ChangeNotifier {
  final List<NetworkLog> _logs = [];

  List<NetworkLog> get logs => _logs;

  void addLog(NetworkLog log) {
    _logs.add(log);
    notifyListeners();
  }
}
