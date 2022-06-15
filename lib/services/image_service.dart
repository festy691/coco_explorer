import 'package:coco_explorer/models/api_response_model.dart';
import 'package:coco_explorer/services/network_service.dart';
import 'package:coco_explorer/services/url_config.dart';

class ImageService {
  NetworkService _networkService;
  ImageService({required NetworkService networkService})
      : _networkService = networkService;

  void updateNetworkService() =>
      _networkService = NetworkService(baseUrl: UrlConfig.baseUrl);

  Future<APIResponse> fetchImageByCategory({required String queryType, required List<int> categoryIds}) async {
    try {
      final response = await _networkService.call(UrlConfig.baseUrl + UrlConfig.cocoDatasetEndpoint, RequestMethod.post, data: {"category_ids": categoryIds, "querytype": queryType});

      return APIResponse(responseCode: response.statusCode!, message: response.statusMessage, data: response.data, isSuccessful: response.statusCode == 200 || response.statusCode == 201);
    } catch (e) {
      rethrow;
    }
  }

  Future<APIResponse> fetchImageData({required String queryType, required List<int> imagesIds}) async {
    try {
      final response = await _networkService.call(UrlConfig.baseUrl + UrlConfig.cocoDatasetEndpoint, RequestMethod.post, data: {"image_ids": imagesIds, "querytype": queryType});

      return APIResponse(responseCode: response.statusCode!, message: response.statusMessage, data: response.data, isSuccessful: response.statusCode == 200 || response.statusCode == 201);
    } catch (e) {
      rethrow;
    }
  }

}