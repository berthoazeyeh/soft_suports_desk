import 'package:dio/dio.dart';
import 'package:soft_support_decktop/constants/string.dart';

class DioClient {
  static Dio getDioClient() {
    final dio = Dio();
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        options.headers['token'] = Strings.token;
        options.headers['api-key'] = Strings.apiKeys;
        return handler.next(options);
      },
    ));

    return dio;
  }
}
