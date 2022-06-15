import 'package:coco_explorer/services/image_service.dart';
import 'package:coco_explorer/services/network_service.dart';
import 'package:coco_explorer/services/url_config.dart';
import 'package:coco_explorer/state_managers/image_provider.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> init() async {
  initProviders();
  await initServices();
}

void initProviders() {
  sl.registerFactory(() => ImageDataProvider(sl()));
}

Future<void> initServices() async {
  sl.registerFactory<NetworkService>(
          () => NetworkService(baseUrl: UrlConfig.baseUrl));
  sl.registerLazySingleton<ImageService>(() => ImageService(networkService: sl()));
}
