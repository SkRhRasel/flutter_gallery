import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gallery/utils/colors.dart';
import 'package:flutter_gallery/utils/common_utils.dart';
import 'package:flutter_gallery/utils/common_widget.dart';
import 'package:flutter_gallery/utils/constants.dart';
import 'package:flutter_gallery/utils/decorations.dart';
import 'package:flutter_gallery/utils/dimens.dart';
import 'package:flutter_gallery/utils/text_utils.dart';
import 'package:flutter_svg/svg.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share_plus/share_plus.dart';
import 'bloc/home_bloc.dart';
import 'services/connectivityService.dart';
import 'services/picsumPhotosService.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  final _controller = PicsumPhotosService();

  @override
  Widget build(BuildContext context) {
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
              return picsumPhotosListItemView(context, list[index]);
            },
            itemCount: list.length,
          );
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
                                        imageUrl: stringNullCheck(
                                            url + picsumPhotos.id + size),
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
                            child: textSpanForGallery(
                                title: 'Author: ',
                                subTitle:
                                    stringNullCheck(picsumPhotos.author),
                                textAlign: TextAlign.center,
                                maxLines: 2))
                      ]))),
          Positioned(
              bottom: 5,
              right: 5,
              child: InkWell(
                  child: const Icon(Icons.share_outlined, size: 20,color: razzleDazzleRose),
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
                        backgroundDecoration:
                            const BoxDecoration(color: Colors.transparent),
                        imageProvider: CachedNetworkImageProvider(
                          stringNullCheck(url + picsumPhotos.id + size),
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
