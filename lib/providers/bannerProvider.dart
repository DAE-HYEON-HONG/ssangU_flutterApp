import 'package:flutter/material.dart';
import 'package:share_product_v2/model/banner.dart';
import 'package:share_product_v2/services/bannerService.dart';

class BannerProvider extends ChangeNotifier {
  final BannerService bannerService = BannerService();

  List<BannerModel> banners = [];
  List<BannerModel> categoryBanner = [];

  Future<void> getBanners() async {
    print('배너 시작');
    List<BannerModel> list = await bannerService.getBanners();
    this.categoryBanner = list;
    notifyListeners();
    this.banners = list;
    notifyListeners();
  }
}
