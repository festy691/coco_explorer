import 'package:coco_explorer/core/global_initialization.dart';
import 'package:coco_explorer/state_managers/image_provider.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class Providers {
  static List<SingleChildWidget> getProviders = [
    ChangeNotifierProvider<ImageDataProvider>(create: (_) => ImageDataProvider(sl())),
  ];
}