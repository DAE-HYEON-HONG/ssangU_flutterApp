class BannerModel {
  int id;
  String title;
  String url;
  // String bannerType;
  // BannerFile bannerFile;
  String bannerFile;

  BannerModel.fromJson(Map<String, dynamic> json)
      : id = json["banner_id"],
        title = json["title"],
        url = json["url"],
        // bannerType = json["bannerType"],
        bannerFile = json['path'];
}

// class BannerFile {
//   String path;

//   BannerFile.fromJson(Map<String, dynamic> json) : path = json['path'];
// }

enum BannerType {
  MAIN, // 메인 화면
  // 카테고리 별 배너
  DAILY, // 생활용품
  TRIP, // 여행
  OUTDOOR, // 스포츠/레저
  BABY, // 육아
  PAT, // 반려동물
  TECH, // 가전제품
  FASHION, // 의류/잡화
  FURNITURE, // 가구/인테리어
  VEHICLE, // 자동차 용품
  ETC // 기타
}

extension ParseToString on BannerType {
  String toShortString() {
    return this.toString().split('.').last;
  }
}
