import 'package:coco_explorer/models/api_response_model.dart';
import 'package:dio/dio.dart';

/// Helper class for converting [DioError] into readable formats
class ApiError {
  int? errorType = 0;
  APIResponse? apiErrorModel;

  /// description of error generated this is similar to convention [Error.message]
  String? errorDescription;

  ApiError({this.errorDescription});

  ApiError.fromDio(Object dioError) {
    _handleError(dioError);
  }

  /// sets value of class properties from [error]
  void _handleError(Object error) {
    if (error is DioError) {
      DioError dioError = error; // as DioError;
      switch (dioError.type) {
        case DioErrorType.cancel:
          errorDescription = "Request to API server was cancelled";
          break;
        case DioErrorType.connectTimeout:
          errorDescription =
          "Connection timeout. Please check your internet connection and try again";
          break;
        case DioErrorType.other:
          errorDescription =
          'Something went wrong while processing your request';
          break;
        case DioErrorType.receiveTimeout:
          errorDescription =
          "Ouch! Seems like you’re offline. Please check your internet connection and try again";
          break;
        case DioErrorType.response:
          this.errorType = dioError.response?.statusCode;
          if (dioError.response?.statusCode == 401) {
            this.errorDescription =
            "Your session has timed out, please login again to proceed";
          } else if (dioError.response?.statusCode == 400) {
            print("error: ${dioError.response?.data}");
            if(dioError.response != null && dioError.response!.data != null){
              if (!dioError.response!.data.toString().startsWith("{") || !dioError.response!.data.toString().endsWith("}")){
                var data = {
                  "error": true,
                  "data": null,
                  "message": "Failed to process request"
                };
                dioError.response!.data = data;
              }
            }
            this.apiErrorModel =
                APIResponse.fromJson(dioError.response?.data);
            this.errorDescription =
                extractDescriptionFromResponse(error.response);
          } else if (dioError.response?.statusCode == 500) {
            this.errorDescription =
            'Something went wrong while processing your request';
          } else {
            this.errorDescription =
            "Oops! we could'nt make connections, please try again";
          }
          break;
        case DioErrorType.sendTimeout:
          errorDescription =
          "Ouch! Seems like you’re offline. Please check your internet connection and try again";
          break;
      }
    } else {
      errorDescription = "Oops an error occurred, we are fixing it";
    }
  }

  String extractDescriptionFromResponse(Response<dynamic>? response) {
    String message = "";
    try {
      if (response?.data != null && response?.data["message"] != null) {
        message = response?.data["message"];
      } else {
        message = response?.statusMessage ?? '';
      }
    } catch (error, stackTrace) {
      message = response?.statusMessage ?? error.toString();
    }
    return message;
  }

  @override
  String toString() => '$errorDescription';
}
