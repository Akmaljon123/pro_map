import 'dart:convert';
import 'dart:io';

class HttpService {
  static Future<String?> get(String text) async {
    HttpClient httpClient = HttpClient();

    try {
      Uri url = Uri.https("suggest-maps.yandex.ru", "/v1/suggest", {
        "text": text,
        "apikey": "f917c64e-c826-43b8-8deb-228f30d6a0ad",
        "lang": "uz"
      });
      HttpClientRequest request = await httpClient.getUrl(url);
      request.headers.set("Content-Type", "application/json");
      request.headers.set("Accept", "application/json");

      HttpClientResponse response = await request.close();
      if (response.statusCode == 200 || response.statusCode == 201) {
        String data = await response.transform(utf8.decoder).join();
        return data;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    } finally {
      httpClient.close();
    }
  }
}
