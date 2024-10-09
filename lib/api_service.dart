import 'package:http/http.dart' as http;
import 'network_log.dart';

class ApiService {
  final NetworkLogger logger;

  ApiService(this.logger);

  Future<void> fetchData(String url) async {
    final response = await http.get(Uri.parse(url));

    // 通信履歴を記録
    logger.addLog(NetworkLog(
      url: url,
      method: 'GET',
      response: response.body,
    ));
  }
}
