import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_api_calling/home/bloc/home_bloc.dart';
import 'package:flutter_bloc_api_calling/utils/colors.dart';
import 'package:flutter_bloc_api_calling/utils/common_utils.dart';
import 'package:flutter_bloc_api_calling/utils/common_widget.dart';
import 'package:flutter_bloc_api_calling/utils/constants.dart';
import 'package:flutter_bloc_api_calling/utils/decorations.dart';
import 'package:flutter_bloc_api_calling/utils/dimens.dart';
import 'package:flutter_bloc_api_calling/utils/text_utils.dart';
import 'package:flutter_gallery/utils/colors.dart';
import 'package:flutter_gallery/utils/constants.dart';
import 'package:flutter_gallery/utils/dimens.dart';
import 'package:flutter_svg/svg.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share_plus/share_plus.dart';
import 'services/connectivityService.dart';
import 'services/picsumPhotosService.dart';

class HomePage extends StatelessWidget {
  //final PicsumPhotosActivity? picsumPhotos;
  HomePage({Key? key}) : super(key: key);

  final _controller = PicsumPhotosService();

  // @override
  // void initState() {
  //   super.initState();
  //   WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
  //     //_controller.getPicsumPhotosList();
  //     _controller.getPicsumPhotosActivity();
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    PicsumPhotosActivity? picsumPhotos;

    const String url = 'https://picsum.photos/id/';
    const String size = '200/300.jpg';

    return BlocProvider(
      create: (context) => HomeBloc(
        RepositoryProvider.of<PicsumPhotosService>(context),
        RepositoryProvider.of<ConnectivityService>(context),
      )..add(LoadApiEvent()),
      child: Scaffold(
        backgroundColor: kCommonBackgroundColor.withOpacity(.99),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: const Text('Picsum Photo Gallery'),
        ),
        body: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is HomeLoadingState) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (state is HomeLoadedState) {
              return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child:
                  _picsumPhotosItemList(context, state.picsumPhotosList));
              // Expanded(
              //   child: RefreshIndicator(
              //     onRefresh: _controller.getData,
              //     child: SingleChildScrollView(
              //         padding: const EdgeInsets.all(15),
              //         child: Column(
              //           children: [
              //             _picsumPhotosItemList(context, state.picsumPhotosList)
              //           ],
              //         )),
              //   ),
              // );

              ///works with single data
              // return Center(
              //   child: Stack(
              //     children: [
              //       Container(
              //           height: 250,
              //           margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              //           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              //           decoration: getRoundCornerWithShadow(),
              //           child: GestureDetector(
              //               onTap: () {
              //                 showModalSheetFullScreenForGallery(
              //                     context, picsumPhotos!);
              //               },
              //               child: Column(
              //                   mainAxisAlignment: MainAxisAlignment.spaceAround,
              //                   crossAxisAlignment: CrossAxisAlignment.center,
              //                   children: [
              //                     Expanded(
              //                       flex: 4,
              //                       child: ClipRRect(
              //                         borderRadius: const BorderRadius.all(
              //                             Radius.circular(dp7)),
              //                         child: state.downloadUrl.isNotEmpty
              //                             ? Hero(
              //                                     tag: 'imageHero',
              //                                     child: CachedNetworkImage(
              //                                         fit: BoxFit.cover,
              //                                         imageUrl: stringNullCheck(state.downloadUrl),
              //                                         placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
              //                                         errorWidget: (context, url, error) => const Icon(Icons.error)),
              //                                   )
              //                             : Image.asset(
              //                                 AssetConstants.imgNotAvailable,
              //                                 width: dp100,
              //                                 height: dp100,
              //                                 fit: BoxFit.cover),
              //                       ),
              //                     ),
              //                     Expanded(
              //                         flex: 1,
              //                         child: Center(
              //                           child: textSpanForGallery(
              //                               title: 'Author: ',
              //                               subTitle:
              //                                   stringNullCheck(state.author),
              //                               textAlign: TextAlign.center,
              //                               maxLines: 2),
              //                         )),
              //                   ]))),
              //       Positioned(
              //           bottom: 15,
              //           right: 15,
              //           child: InkWell(
              //               child: const Icon(Icons.share_outlined, size: 20),
              //               onTap: () {
              //                 WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
              //                   Share.share(stringNullCheck(state.downloadUrl));
              //                 });
              //               })),
              //       // Text(state.id),
              //       // Text(state.author),
              //       // Text(state.downloadUrl.toString()),
              //       // ElevatedButton(
              //       //     onPressed: () => BlocProvider.of<HomeBloc>(context).add(LoadApiEvent()),
              //       //     child: const Text('LOAD NEXT'))
              //     ],
              //   ),
              // );
            }
            if (state is HomeNoInternetState) {
              return const Center(
                  child: Text(
                    'No Internet :( \n Please check your internet connection!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ));
            }
            return Container();
          },
        ),
      ),
    );
  }

  String message = "Picsum Photo gallery images will appear here.";

  Widget _picsumPhotosItemList(
      BuildContext context, List<PicsumPhotosActivity> list) {
    return list.isEmpty
        ? handleEmptyViewWithLoading(_controller.isDataLoaded, message: message)
        : GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: 0.99,
          crossAxisCount: 2,
          mainAxisSpacing: 10.0,
          crossAxisSpacing: 10.0),
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemBuilder: (BuildContext context, int index) {
        if (index == list.length - 1) {
          _controller.getPicsumPhotosActivity();
          return const Center(child: CircularProgressIndicator());
        }
        return picsumPhotosListItemView(context, list[index]);
      },
      itemCount: list.length,
    );

    // Column(
    //         children: List.generate(list.length,
    //             (index) => picsumPhotosListItemView(context, list[index])),
    //       );
  }

  Widget _picsumPhotosItemList2(BuildContext context) {
    return _controller.picsumPhotosList.isEmpty
        ? handleEmptyViewWithLoading(_controller.isDataLoaded, message: message)
        : SizedBox(
        height: MediaQuery.of(context).size.height - (kToolbarHeight + 100),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: 0.99,
              crossAxisCount: 2,
              mainAxisSpacing: 10.0,
              crossAxisSpacing: 10.0),
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          itemBuilder: (BuildContext context, int index) {
            if (index == _controller.picsumPhotosList.length - 1) {
              _controller.getPicsumPhotosActivity();
              return const Center(child: CircularProgressIndicator());
            }
            return picsumPhotosListItemView(
                context, _controller.picsumPhotosList[index]);
          },
          itemCount: _controller.picsumPhotosList.length,
        ));
  }

  Widget picsumPhotosListItemView(
      BuildContext context, PicsumPhotosActivity picsumPhotos) {
    const String url = 'https://picsum.photos/id/';
    const String size = '/300/200.jpg';
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: Stack(
        children: [
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: getRoundCornerWithShadow(),
              child: GestureDetector(
                  onTap: () {
                    showModalSheetFullScreenForGallery(context, picsumPhotos);
                  },
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 4,
                          child: ClipRRect(
                            borderRadius:
                            const BorderRadius.all(Radius.circular(dp7)),
                            child: picsumPhotos.downloadUrl.isNotEmpty
                                ? Hero(
                              tag: 'imageHero',
                              child: CachedNetworkImage(
                                  fit: BoxFit.cover,
                                  //imageUrl: stringNullCheck(picsumPhotos.downloadUrl),
                                  imageUrl: stringNullCheck(url + picsumPhotos.id + size),
                                  placeholder: (context, url) =>
                                  const Center(
                                      child:
                                      CircularProgressIndicator()),
                                  errorWidget: (context, url, error) =>
                                  const Icon(Icons.error)),
                            )
                                : Image.asset(AssetConstants.imgNotAvailable,
                                width: dp100,
                                height: dp100,
                                fit: BoxFit.cover),
                          ),
                        ),
                        Expanded(
                            flex: 1,
                            child: Center(
                              child: textSpanForGallery(
                                  title: 'Author: ',
                                  subTitle:
                                  stringNullCheck(picsumPhotos.author),
                                  textAlign: TextAlign.center,
                                  maxLines: 2),
                            ))
                      ]))),
          Positioned(
              bottom: 5,
              right: 5,
              child: InkWell(
                  child: const Icon(Icons.share_outlined, size: 20),
                  onTap: () {
                    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
                      Share.share(stringNullCheck(picsumPhotos.downloadUrl));
                    });
                  }))
        ],
      ),
    );
  }

  void showModalSheetFullScreenForGallery(
      BuildContext context, PicsumPhotosActivity picsumPhotos) {

    const String url = 'https://picsum.photos/id/';
    const String size = '/300/200.jpg';
    showModalBottomSheet(
        enableDrag: false,
        isScrollControlled: true,
        backgroundColor: Colors.black.withOpacity(0.7),
        context: context,
        builder: (context) {
          return Container(
              alignment: Alignment.center,
              height: MediaQuery.of(context).size.height,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              child: Stack(children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: Hero(
                    tag: 'imageHero',
                    child: ClipRRect(
                      borderRadius:
                      const BorderRadius.all(Radius.circular(dp7)),
                      child: PhotoView(
                        backgroundDecoration: const BoxDecoration(color: Colors.transparent),
                        //imageProvider: CachedNetworkImageProvider(stringNullCheck(picsumPhotos.downloadUrl),
                        imageProvider: CachedNetworkImageProvider(stringNullCheck(url + picsumPhotos.id + size),
                          // maxHeight: 500,
                          // maxWidth: 400,
                        ),

                      ),
                    ),
                  ),
                ),
                Positioned(
                    top: 40,
                    right: 10,
                    child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: SvgPicture.asset(
                          AssetConstants.ic_close_box,
                          width: dp20,
                          height: dp20,
                          color: kCoinBox1,
                        )))
              ]));
        });
  }
}
