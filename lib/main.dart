import 'package:flutter/material.dart';
import 'network_log.dart';
import 'api_service.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => NetworkLogger(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'プロキシ通信履歴',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ProxyMonitorPage(),
    );
  }
}

class ProxyMonitorPage extends StatelessWidget {
  final ApiService apiService;

  ProxyMonitorPage({Key? key})
      : apiService = ApiService(NetworkLogger()),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final logger = Provider.of<NetworkLogger>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('プロキシ通信履歴'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              await apiService.fetchData('https://jsonplaceholder.typicode.com/posts/1');
            },
            child: Text('データを取得'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: logger.logs.length,
              itemBuilder: (context, index) {
                final log = logger.logs[index];
                return ListTile(
                  title: Text(log.url),
                  subtitle: Text('Method: ${log.method}\nResponse: ${log.response}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
