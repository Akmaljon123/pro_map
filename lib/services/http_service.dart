import 'dart:developer';

import 'package:dio/dio.dart';

class DioService {
  static final BaseOptions _option = BaseOptions(
    connectTimeout: const Duration(seconds: 100),
    receiveTimeout: const Duration(seconds: 100),
    sendTimeout: const Duration(seconds: 100),
    baseUrl: "https://suggest-maps.yandex.ru",
    validateStatus: (statusCode) => statusCode! < 500, // Allow up to 499 to catch client and server errors
    receiveDataWhenStatusError: true,
  );

  static final dio = Dio(_option);
  static String? sessionId;

  static Future<String?> sendRequest(Map<String, dynamic> param) async {
    try {
      Response response = await dio.post("/v1/suggest", queryParameters: param);

      log('Response data: ${response.data}');
      log('Response status code: ${response.statusCode}');

      if (response.statusCode! <= 201) {
        return response.data;
      } else {
        log('Request failed with status: ${response.statusCode}');
        return null;
      }
    } on DioException catch (e) {
      if (e.response != null) {
        log('Dio error response data: ${e.response!.data}');
        log('Dio error response status code: ${e.response!.statusCode}');
      } else {
        log('Dio error: $e');
      }
      return null;
    } catch (e) {
      log('General error: $e');
      return null;
    }
  }
}