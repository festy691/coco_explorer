class ImageModel {
  final id;
  final coco_url;
  final flickr_url;
  dynamic segmentation;
  dynamic caption;

  ImageModel(
      {this.id,
      this.coco_url,
      this.flickr_url,
      this.segmentation,
      this.caption});

  factory ImageModel.fromJson(Map<String, dynamic> data){
    return ImageModel(
      id: data['id'],
      coco_url: data['coco_url'],
      flickr_url: data['flickr_url']
    );
  }
}

class SegmentationModel {
  final image_id;
  final segmentation;
  final category_id;

  SegmentationModel({this.image_id, this.segmentation, this.category_id});

  factory SegmentationModel.fromJson(Map<String, dynamic> data){
    return SegmentationModel(
      image_id: data['image_id'],
      segmentation: data['segmentation'],
      category_id: data['category_id']
    );
  }
}

class CaptionModel {
  final caption;
  final image_id;

  CaptionModel({this.image_id, this.caption});

  factory CaptionModel.fromJson(Map<String, dynamic> data){
    return CaptionModel(
      image_id: data['image_id'],
      caption: data['caption'],
    );
  }
}