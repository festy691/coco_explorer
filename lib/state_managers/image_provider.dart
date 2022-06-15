import 'package:coco_explorer/models/api_response_model.dart';
import 'package:coco_explorer/models/image_model.dart';
import 'package:coco_explorer/services/image_service.dart';
import 'package:flutter/material.dart';

class ImageDataProvider with ChangeNotifier {
  ImageService _imageService;
  ImageDataProvider(ImageService imageService) : _imageService = imageService;

  final _loadingKey = GlobalKey<State>();

  List<dynamic> _allImageIds = [];
  List<ImageModel> _imageList = [];
  List<SegmentationModel> _segmentationList = [];
  List<CaptionModel> _captionList = [];

  int page = 1;
  int totalPages = 1;

  void clearData () {
    _imageList = [];
    _segmentationList = [];
    _captionList = [];
    notifyListeners();
  }

  setImageList(List<ImageModel> list){
    _imageList = list;
    notifyListeners();
  }

  setSegmentationList(List<SegmentationModel> list){
    _segmentationList = list;
    notifyListeners();
  }

  setCaptionList(List<CaptionModel> list){
    _captionList = list;
    notifyListeners();
  }

  List<ImageModel> get imageList {
    return _imageList;
  }

  List<SegmentationModel> get segmentationList {
    return _segmentationList;
  }

  List<CaptionModel> get captionList {
    return _captionList;
  }

  List<SegmentationModel> filterSegmentation ({required int imageId, required List<int> categoryIds}){
    List<SegmentationModel> list = [];
    for (int i=0; i<categoryIds.length; i++){
      list.addAll(_segmentationList.where((element) => element.image_id == imageId && element.category_id == categoryIds[i]).toList());
    }
    return list;
  }

  List<CaptionModel> filterCaption ({required int imageId}){
    return _captionList.where((element) => element.image_id == imageId).toList();
  }

  Future<APIResponse> fetchImagesByCategories({String queryType = "getImagesByCats", required List<int> categoryIds}) async {
    try {
      APIResponse response = await _imageService.fetchImageByCategory(queryType: queryType, categoryIds: categoryIds);
      if (response.isSuccessful && response.data != null && response.data.length > 0){
        _allImageIds = response.data;
        loadPaginationData(imagesIds: getNextItems());
      }
      return response;
    } catch (e, stacktrace){
      print(e);
      clearData();
      return APIResponse(message: e.toString());
    }
  }

  List<int> getNextItems ({int length = 10, int thisPage = 1}){
    print("all ${_allImageIds.length}");
    List<int> ids = [];
    int stop = (length * thisPage) > _allImageIds.length ? _allImageIds.length : length * thisPage;
    int start = ((length * thisPage) - length);
    print("page $thisPage");
    print("start $start");
    print("stop $stop");
    for (int i = start; i < stop; i++){
      ids.add(_allImageIds[i]);
    }
    return ids;
  }

  fetchMoreCategoryData() async {
    try {
      List<int> ids = getNextItems(thisPage: page + 1);
      if (ids.isEmpty) return;
      await loadPaginationData(imagesIds: ids);
      page = page + 1;
    } catch (e, stacktrace){
      print(e);
    }
  }

  Future loadPaginationData ({required List<int> imagesIds}) async{
    await Future.wait(
      [
        fetchImagesDetails(imagesIds: imagesIds),
        fetchImagesSegmentations(imagesIds: imagesIds),
        fetchImagesCaptions(imagesIds: imagesIds)
      ]
    );
  }

  Future<APIResponse> fetchImagesDetails({String queryType = "getImages", required List<int> imagesIds}) async {
    try {
      APIResponse response = await _imageService.fetchImageData(queryType: queryType, imagesIds: imagesIds);
      if (response.isSuccessful){
        List<ImageModel> _list = [];
        if (page > 1) _list.addAll(_imageList);
        for (var data in response.data){
          _list.add(ImageModel.fromJson(data));
        }
        setImageList(_list);
      }
      return response;
    } catch (e, stacktrace){
      return APIResponse(message: e.toString());
    }
  }

  Future<APIResponse> fetchImagesSegmentations({String queryType = "getInstances", required List<int> imagesIds}) async {
    try {
      APIResponse response = await _imageService.fetchImageData(queryType: queryType, imagesIds: imagesIds);
      if (response.isSuccessful){
        List<SegmentationModel> _list = [];
        if (page > 1) _list.addAll(_segmentationList);
        for (var data in response.data){
          _list.add(SegmentationModel.fromJson(data));
        }
        setSegmentationList(_list);
      }
      return response;
    } catch (e, stacktrace){
      return APIResponse(message: e.toString());
    }
  }

  Future<APIResponse> fetchImagesCaptions({String queryType = "getCaptions", required List<int> imagesIds}) async {
    try {
      APIResponse response = await _imageService.fetchImageData(queryType: queryType, imagesIds: imagesIds);
      if (response.isSuccessful){
        List<CaptionModel> _list = [];
        if (page > 1) _list.addAll(_captionList);
        for (var data in response.data){
          _list.add(CaptionModel.fromJson(data));
        }
        setCaptionList(_list);
      }
      return response;
    } catch (e, stacktrace){
      return APIResponse(message: e.toString());
    }
  }
}