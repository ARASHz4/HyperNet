import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class BaseHttpClient {
  Dio? _dio;

  Future<Dio> dio() async {
    if (_dio == null) {
      _dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 40),
        receiveTimeout: const Duration(seconds: 60),
      ));

      if (kDebugMode) {
        _dio?.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
      }

      _dio?.interceptors.add(InterceptorsWrapper(
        onResponse: (response, handler) {
          handler.next(response);
        },
        onError: (error, handler) async {
          switch (error.type) {
            case DioExceptionType.badResponse:

              if (error.response != null) {
                handler.resolve(error.response!);
              }
              else {
                handler.next(error);
              }
              break;

            case DioExceptionType.connectionTimeout:
            case DioExceptionType.sendTimeout:
            case DioExceptionType.receiveTimeout:
            case DioExceptionType.cancel:
            case DioExceptionType.connectionError:
            case DioExceptionType.badCertificate:
            case DioExceptionType.transformTimeout:
            case DioExceptionType.unknown:
              handler.resolve(Response(
                statusCode: 1000,
                requestOptions: error.requestOptions,
                data: error.type,
              ));
              break;
          }
        },
      ));
    }

    return _dio!;
  }
}
