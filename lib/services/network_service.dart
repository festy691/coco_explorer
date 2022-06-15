import 'package:coco_explorer/services/api_error.dart';
import 'package:coco_explorer/services/url_config.dart';
import 'package:dio/dio.dart';

/// description: A network provider class which manages network connections
/// between the app and external services. This is a wrapper around [Dio].
///
/// Using this class automatically handle, token management, logging, global

void printWrapped(String text) {
  final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
  pattern.allMatches(text).forEach((match) => print(match.group(0)));
}

/// A top level function to print dio logs
void printDioLogs(Object object) {
  printWrapped(object.toString());
}

class NetworkService {
  static const int CONNECT_TIME_OUT = 60000;
  static const int RECEIVE_TIME_OUT = 60000;
  Dio? dio;
  String? baseUrl, authToken;

  NetworkService({String? baseUrl, String? authToken}) {
    this.baseUrl = baseUrl;
    this.authToken = authToken;
    _initialiseDio();
  }

  /// Initialize essential class properties
  void _initialiseDio() {
    dio = Dio(BaseOptions(
      connectTimeout: CONNECT_TIME_OUT,
      receiveTimeout: RECEIVE_TIME_OUT,
      baseUrl: baseUrl ?? UrlConfig.baseUrl,
    ));
    dio!.interceptors
      .add(LogInterceptor(requestBody: true, logPrint: printDioLogs));
  }

  addInterceptor() {}

  Options getOption({responseType}) {
    return Options(responseType: responseType, headers: {
      "Content-Type": 'application/json',
    });
  }

  /// Factory constructor used mainly for injecting an instance of [Dio] mock
  NetworkService.test(this.dio);

  Future<Response> call(
      String path,
      RequestMethod method, {
        Map<String, dynamic>? queryParams,
        data,
        FormData? formData,
        ResponseType responseType = ResponseType.json,
        classTag = '',
      }) async {
    _initialiseDio();
    Response response;
    var params = queryParams ?? {};
    if (params.keys.contains("searchTerm")) {
      params["searchTerm"] = Uri.encodeQueryComponent(params["searchTerm"]);
    }
    try {
      switch (method) {
        case RequestMethod.post:
          response = await dio!.post(path,
              queryParameters: params,
              data: data,
              options: getOption(responseType: responseType));
          break;
        case RequestMethod.get:
          response = await dio!
              .get(path, queryParameters: params, options: getOption());
          break;
        case RequestMethod.patch:
          response = await dio!.patch(path,
              queryParameters: params, data: data, options: getOption());
          break;
        case RequestMethod.put:
          response = await dio!.put(path,
              queryParameters: params, data: data, options: getOption());
          break;
        case RequestMethod.delete:
          response = await dio!.delete(path,
              queryParameters: params, data: data, options: getOption());
          break;
        case RequestMethod.upload:
          response = await dio!.post(path,
              data: formData,
              queryParameters: params,
              options: Options(headers: {
                "Content-Disposition": "form-data",
                "Content-Type": "multipart/form-data",
              }), onSendProgress: (sent, total) {
                // eventBus
                //     .fire(
                //     FileUploadProgressEvent(FileUploadProgress(sent, total, tag: classTag)));
              });
          break;
      }
      return response;
    } catch (error, stackTrace) {
      var apiError = ApiError.fromDio(error);
      return Future.error(apiError, stackTrace);
    }
  }
}

enum RequestMethod { post, get, put, delete, upload, patch }