class APIResponse {
  bool isSuccessful;
  int responseCode;
  String? message;
  dynamic data;

  APIResponse({this.isSuccessful = false, this.responseCode = 400, this.message, this.data});

  factory APIResponse.fromJson(Map<String, dynamic> json) => APIResponse(
    message: json["message"],
    isSuccessful: json["status"],
  );
}