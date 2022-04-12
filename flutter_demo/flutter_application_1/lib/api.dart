import 'package:http/http.dart' as http;

Future getPath(url) async {
  http.Response pathRes = await http.get(url);
}
