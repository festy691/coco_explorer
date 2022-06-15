import 'package:cached_network_image/cached_network_image.dart';
import 'package:coco_explorer/core/extended_build_context.dart';
import 'package:coco_explorer/core/image_property.dart';
import 'package:coco_explorer/core/suggestions.dart';
import 'package:coco_explorer/models/image_model.dart';
import 'package:coco_explorer/models/suggestion_model.dart';
import 'package:coco_explorer/state_managers/image_provider.dart';
import 'package:coco_explorer/widget/empty_screen.dart';
import 'package:coco_explorer/widget/loading_widget.dart';
import 'package:coco_explorer/widget/segmentation_painter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with ImageProperties{
  late ImageDataProvider _imageProvider;
  bool _isLoading = false;

  List<int> _categoryIds = [];

  setLoadingState(bool loading){
    _isLoading = loading;
    if (mounted) {
      setState(() {

      });
    }
  }

  showLoadingWidget ({bool loading = false}){
    loading ? EasyLoading.show(status: 'loading...') : EasyLoading.dismiss();
  }

  _loadInitialData () async {
    setLoadingState(true);
    showLoadingWidget(loading: true);
    //_categoryIds = [32];
    _imageProvider.fetchImagesByCategories(categoryIds: _categoryIds).then((value){
      setLoadingState(false);
      showLoadingWidget();
    }).onError((error, stackTrace){
      setLoadingState(false);
      showLoadingWidget();
    });
  }

  List<String> items = ["1", "2", "3", "4", "5", "6", "7", "8"];
  RefreshController _refreshController =
  RefreshController(initialRefresh: false);

  int page = 1;

  void _onRefresh() async{
    // monitor network fetch
    page = 1;
    await _loadInitialData();
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async{
    // monitor network fetch
    page = page + 1;
    await _imageProvider.fetchMoreCategoryData();
    if(mounted) {
      setState(() {});
    }
    _refreshController.loadComplete();
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _imageProvider = context.provideOnce<ImageDataProvider>();
    //_loadInitialData();
  }
  @override
  Widget build(BuildContext context) {
    ImageDataProvider dataProvider = Provider.of<ImageDataProvider>(context);
    double _width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CachedNetworkImage(
              imageUrl: 'https://cocodataset.org/images/coco-logo.png',
            ),

            const SizedBox(height: 24,),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: [
                  SizedBox(
                    width: _width - 100,
                    child: TypeAheadField(
                      textFieldConfiguration: TextFieldConfiguration(
                          autofocus: false,
                          style: DefaultTextStyle.of(context).style.copyWith(
                              fontStyle: FontStyle.italic
                          ),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'What object are you looking for?',
                            hintStyle: TextStyle(
                              color: Colors.grey,
                            ),

                          )
                      ),
                      suggestionsCallback: (pattern) {
                        return suggestionList;
                      },
                      itemBuilder: (context, SuggestionModel suggestion) {
                        return ListTile(
                          title: Text(suggestion.title),
                        );
                      },
                      onSuggestionSelected: (SuggestionModel suggestion) {
                        _categoryIds.add(suggestion.id);

                        int position = _chipList.length;
                        _chipList.add(BuildChip(
                          label: suggestion.title, id: suggestion.id,
                            onClose: (id, index){
                              _chipList.removeAt(index);
                              _categoryIds.removeWhere((element) => element == id);
                              if (mounted) {
                                setState(() {

                                });
                              }
                            }, position: position,
                          )
                        );
                      },
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      _loadInitialData();
                    },
                    icon: const Icon(Icons.search, color: Colors.black,)),
                ],
              ),
            ),

            chipWidgetList(),

            const SizedBox(height: 24,),

            _imageListWidget(context),
          ],
        ),
      ),
    );
  }

  Widget _imageListWidget(BuildContext context){
    double _width = MediaQuery.of(context).size.width;
    List<ImageModel> _imageList = _imageProvider.imageList;
    print(_imageList.length);
    return _isLoading ?
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Center(child: EmptyScreen(title: "Loading", subtitle: "We are trying to load results for your search, please wait...")),
    )
    :
    _imageList.isEmpty ?
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Center(child: EmptyScreen(title: "Search", subtitle: "Enter the name of the object let CoCo help you identify it")),
    )
      :
    Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: SmartRefresher(
          enablePullDown: true,
          enablePullUp: true,
          header: const WaterDropHeader(),
          footer: CustomFooter(
            builder: (context, mode){
              Widget body ;
              if(mode==LoadStatus.idle){
                body =  const Text("pull up load");
              } else if(mode==LoadStatus.loading){
                body = const CupertinoActivityIndicator();
              }
              else if(mode == LoadStatus.failed){
                body = const Text("Load Failed!Click retry!");
              }
              else if(mode == LoadStatus.canLoading){
                body = const Text("release to load more");
              } else{
                body = const Text("No more Data");
              }
              return SizedBox(
                height: 55.0,
                child: Center(child:body),
              );
            },
          ),
          controller: _refreshController,
          onRefresh: _onRefresh,
          onLoading: _onLoading,
          child: ListView.builder(
            itemCount: _imageList.length,
            itemBuilder: (BuildContext context, int index){
            ImageModel model = _imageList[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: SizedBox(
                width: _width - 48,
                child: _NetworkImageWidget(url: model.coco_url, width: _width - 48, height: _width * 0.7, imageId: model.id, categoryIds: _categoryIds),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _NetworkImageWidget({required String url, double width = 160, double height = 80, required int imageId, required List<int> categoryIds}){
    //print(_imageProvider.filterSegmentation(imageId: imageId)[0].segmentation);
    return FutureBuilder<SizedImage>(
      future: getImageOriginalSize(url),
      builder: (context, snapshot) {
        return Column(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: snapshot.data == null ||
                      !snapshot.hasData
                      ? const ItemLoadingView()
                      : CustomPaint(
                    foregroundPainter: SegmentationsPainter(
                      segmentations: _imageProvider.filterSegmentation(imageId: imageId, categoryIds: categoryIds),
                      originalSize:
                      snapshot.data?.originalSize,
                    ),
                    child:
                    Image(image: snapshot.data!.image),
                  ),
                ),
                //if (snapshot.data == null || !snapshot.hasData)
                  //_buildSegmentationLoadingView(context),
                //if (snapshot.hasError)
                 // _buildLoadingImageSizeFailedView(),
              ],
            ),
            /*if (_total == _loadedImages.length &&
                index == _loadedImages.length - 1)
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  'No more images',
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            if (_total == _loadedImages.length &&
                index == _loadedImages.length - 1)
              const SizedBox(height: 30),*/
          ],
        );
      },
    );
  }

  List<Widget> _chipList = [];

  chipWidgetList() {
    return Wrap(
      spacing: 6.0,
      runSpacing: 6.0,
      children: _chipList,
    );
  }

}

typedef OnClose = Function(int id, int index);

class BuildChip extends StatelessWidget {
  String label;
  int id;
  OnClose? onClose;
  int position;
  BuildChip({Key? key, required this.id,  required this.position, required this.label, this.onClose}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Chip(
      labelPadding: const EdgeInsets.all(2.0),
      onDeleted: (){
        onClose!(id, position);
      },
      avatar: CircleAvatar(
        backgroundColor: Colors.white70,
        child: Text(label[0].toUpperCase()),
      ),
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
        ),
      ),
      backgroundColor: const Color(0xFFff6666),
      elevation: 6.0,
      shadowColor: Colors.grey[60],
      padding: const EdgeInsets.all(8.0),
      deleteIcon: const Icon(Icons.close, color: Colors.white,),
    );
  }
}

