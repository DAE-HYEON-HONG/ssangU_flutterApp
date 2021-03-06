import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_product_v2/pages/history/history.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_product_v2/pages/home.dart';
import 'package:share_product_v2/pages/auth/myPage.dart';
import 'package:share_product_v2/providers/bannerProvider.dart';
import 'package:share_product_v2/providers/fcm_model.dart';
import 'package:share_product_v2/providers/productProvider.dart';
import 'package:share_product_v2/providers/userProvider.dart';
import 'package:share_product_v2/utils/APIUtil.dart';
import 'package:share_product_v2/widgets/CustomPopup.dart';
import 'package:share_product_v2/widgets/InputDoneView.dart';
import 'package:share_product_v2/widgets/customdialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      // SharedPreferences pref = await SharedPreferences.getInstance();
      // String token = pref.get("access_token");
      // print("token : $token");
      // if (token != null && token != "") {
      //   Provider.of<UserProvider>(context, listen: false).setAccessToken(token);
      //   Provider.of<UserProvider>(context, listen: false).me();
      // }
    });
    return MyStatefulWidget();
  }
}

class MyStatefulWidget extends StatefulWidget {
  MyStatefulWidget({Key key}) : super(key: key);

  @override
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  // final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  SharedPreferences pref;
  int _selectedIndex = 0;
  int page = 0;
  OverlayEntry overlayEntry;

  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    Text(
      '?????????',
      style: optionStyle,
    ),
    /**
     * NOTICE : ?????? ?????? ??? ?????? ????????? ????????? (?????? ?????????.)
     */
    History(),
    MyPage(),
    // NoticePage(),
  ];

  Future setAuthToken() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.get("access_token");
    String reToken = pref.get("refresh_token");
    print("token : $token");
    print("reToken : $reToken");
    if (token != null && token != "" && reToken != null && reToken != "") {
      await Provider.of<UserProvider>(context, listen: false)
          .refreshToken(reToken);
      await Provider.of<UserProvider>(context, listen: false).setAccessToken(token);
      await Provider.of<BannerProvider>(context, listen: false).getBanners();
      await Provider.of<ProductProvider>(context, listen: false)
          .changeUserPosition(
        Provider.of<UserProvider>(context, listen: false).userLocationY,
        Provider.of<UserProvider>(context, listen: false).userLocationX,

      );
    } else {
      return;
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      if (index == 0) {
        _selectedIndex = index;
        return;
      }
      if (index == 1) {
        if (!Provider.of<UserProvider>(context, listen: false).isLoggenIn) {
          _showDialog(context);
        } else {
          showModalBottomSheet(context: context, builder: buildBottomSheet);
        }
      }
      if (index == 2) {
        if (!Provider.of<UserProvider>(context, listen: false).isLoggenIn) {
          _showDialog(context);
        } else {
          _selectedIndex = index;
          return;
        }
      }
      if (index == 3) {
        _selectedIndex = index;
        return;
      }
      // showModalBottomSheet(context: context, builder: buildBottomSheet);
    });
  }

  @override
  Widget build(BuildContext context) {
    const TextStyle optionStyle =
        TextStyle(fontSize: 12, fontWeight: FontWeight.w100);

    return Consumer<UserProvider>(builder: (_, user, __) {
      return WillPopScope(
        onWillPop: () {
          if (_selectedIndex != 0) {
            setState(() {
              _selectedIndex = 0;
            });
            return Future(() => false);
          }
          return Future(() => true);
        },
        child: Scaffold(
          key: globalKey,
          body: Container(
            width: double.infinity,
            height: double.infinity,
            child: Center(
              child: _widgetOptions.elementAt(_selectedIndex),
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: ImageIcon(AssetImage("assets/icon/home.png"),
                    color: Color(0xff888888)),
                title: Text(
                  '???',
                  style: optionStyle,
                ),
              ),
              BottomNavigationBarItem(
                icon: ImageIcon(AssetImage("assets/icon/write.png"),
                    color: Color(0xff888888)),
                title: Text(
                  '?????????',
                  style: optionStyle,
                ),
              ),
              /**
               * NOTICE : ?????? ?????? ??? ?????? ????????? ????????? (?????? ?????????)
               */
              BottomNavigationBarItem(
                icon: ImageIcon(AssetImage("assets/icon/list.png"),
                    color: Color(0xff888888)),
                title: Text(
                  '????????????',
                  style: optionStyle,
                ),
              ),
              BottomNavigationBarItem(
                icon: ImageIcon(AssetImage("assets/icon/my.png"),
                    color: Color(0xff888888)),
                title: Text(
                  '???????????????',
                  style: optionStyle,
                ),
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Theme.of(context).primaryColor,
            unselectedItemColor: Color(0xff888888),
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
          ),
        ),
      );
    });
  }

  Widget buildBottomSheet(BuildContext context) {
    return Container(
        height: 150.h,
        child: SafeArea(
            child: Column(
          children: [
            InkWell(
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed("/product/applyOnerWhatever");
              },
              child: SizedBox(
                height: 72.h,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Icon(Icons.note_add),
                      SizedBox(
                        width: 16,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "?????? ?????? ??????",
                            style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.normal,
                                color: Color(0xff333333)),
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          Text(
                            "??????????????? ?????? ?????? ????????? ????????? ??? ?????????.",
                            style: TextStyle(
                                fontSize: 12.sp, color: Color(0xff999999)),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed("/product/apply");
              },
              child: SizedBox(
                height: 45.h,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Icon(Icons.note_add),
                      SizedBox(
                        width: 16,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "?????? ?????? ??????",
                            style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.normal,
                                color: Color(0xff333333)),
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          Text(
                            "???????????? ????????? ????????? ??????????????????.",
                            style: TextStyle(
                                fontSize: 12.sp, color: Color(0xff999999)),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        )));
  }

  void _showDialog(context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomDialog(dialogChild(), "??????", () {
            Navigator.of(context).pop();
            setState(() {
              _selectedIndex = 3;
            });
          });
        });
  }

  Widget dialogChild() {
    return Column(
      children: [
        Text(
          "???????????? ???????????????.",
          style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Color(0xff333333)),
        ),
        SizedBox(
          height: 20.h,
        ),
      ],
    );
  }

  getPopUp(context) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    int myTimestamp = pref.getInt("timestamp");

    if (myTimestamp == null || myTimestamp == 0) {
      showDialog(
          context: context,
          builder: (_) => CustomPopup(),
          barrierDismissible: false);
      return;
    }

    DateTime myDateTime = DateTime.fromMillisecondsSinceEpoch(myTimestamp);
    DateTime now = DateTime.now();

    Duration timeDifference = now.difference(myDateTime);

    if (timeDifference.inDays >= 1) {
      showDialog(
          context: context,
          builder: (_) => CustomPopup(),
          barrierDismissible: false);
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async{
      await Provider.of<FCMModel>(context, listen: false).getMbToken();
      await Provider.of<UserProvider>(context, listen: false).AddFCMtoken(
          Provider.of<FCMModel>(context, listen: false).mbToken
      );
      await Provider.of<BannerProvider>(context, listen: false).getBanners();
    });
    Provider.of<ProductProvider>(context, listen: false).getGeolocator();
    if (Provider.of<UserProvider>(context, listen: false).isLoggenIn) {
      Provider.of<UserProvider>(context, listen: false).me();
    }

    KeyboardVisibility.onChange.listen((bool visible) {
      print('Keyboard visibility update. Is visible: ${visible}');
      if (visible)
        showOverlay(context);
      else
        removeOverlay();
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      pref = await SharedPreferences.getInstance();
      setAuthToken();
    });
    getPopUp(context);
    // firebaseCloudMessaging_Listeners();
  }

  showOverlay(BuildContext context) {
    if (overlayEntry == null) return;
    OverlayState overlayState = Overlay.of(context);
    overlayEntry = OverlayEntry(builder: (context) {
      return Positioned(
        bottom: MediaQuery.of(context).viewInsets.bottom + 10,
        right: 10.0,
        child: InputDoneView(),
      );
    });
    overlayState.insert(overlayEntry);
  }

  removeOverlay() {
    if (overlayEntry != null) {
      overlayEntry.remove();
      overlayEntry = null;
    }
  }

  Widget buildSetAddressBottomSheet(BuildContext context) {
    TextStyle titleStyle = TextStyle(
        fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.black);

    TextStyle descriptionStyle = TextStyle(
        fontSize: 11.sp,
        fontWeight: FontWeight.normal,
        color: Color(0xff999999));

    TextStyle buttonStyle = TextStyle(
        fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.white);
    return SafeArea(
      child: Container(
        height: 148,
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "????????? ???????????? ???????????????!",
                style: titleStyle,
              ),
              SizedBox(
                height: 4,
              ),
              Text(
                "????????? ?????? ???????????? ?????????????????? ??????????????? ???????????????.",
                style: descriptionStyle,
              ),
              Spacer(),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                    color: Theme.of(context).primaryColor,
                    child: Text(
                      "???????????? ????????????",
                      style: buttonStyle,
                    ),
                    onPressed: () async {
                      // Geolocator geolocator = Geolocator()
                      //   ..forceAndroidLocationManager = true;
                      print('?????? ?????? ?????? ?????? ??????');
                      // geolocator
                      //     .getCurrentPosition(
                      //         desiredAccuracy: LocationAccuracy.best)
                      //     .then((Position position) {
                      //   print("${position.latitude}, ${position.longitude}");

                        // pref.setString("address",
                        //     "${position.latitude}, ${position.longitude}");
                        print("===================================");
                        Navigator.pop(context);
                        print("===================================");
                      // }).catchError((e) {
                      //   print('?????? ?????? ??????');
                      //   print("location exception: $e");
                      //   Navigator.pop(context);
                      // });
                      // Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
                      // print(position.latitude);
                      // print(position.longitude);
                      Navigator.pop(context);
                    }),
              )
            ],
          ),
        ),
      ),
    );
  }
}
