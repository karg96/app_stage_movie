import 'dart:io';

import 'package:app_stage_movie/core/utils/app_exceptions.dart';
import 'package:app_stage_movie/core/utils/constants.dart';
import 'package:dio/dio.dart';

class DioClient {
  final Dio dio;

  DioClient({required this.dio}) {
    dio.options.baseUrl = AppConstants.baseUrl;
    dio.options.connectTimeout = Duration(milliseconds: AppConstants.connectTimeout);
    dio.options.receiveTimeout = Duration(milliseconds: AppConstants.receiveTimeout);;
    dio.options.queryParameters = {'api_key': AppConstants.apiKey};
    dio.interceptors.add(LogInterceptor(responseBody: true));
  }

  Future<dynamic> get(String url, {Map<String, dynamic>? params}) async {
    try {
      final response = await dio.get(url, queryParameters: params);
      return response.data;
    } on DioException catch (e) {
      if (e.error is SocketException) {
        throw NoInternetException(message: AppConstants.noInternetMessage);
      }
      throw ServerException(message: e.response?.data['status_message'] ?? 'Server error');
    }
  }
}