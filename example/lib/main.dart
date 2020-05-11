import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tencent_ad/tencent_ad.dart';

void main() {
  runApp(TencentADApp());
}

class TencentADApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TencentADAppState();
}

class _TencentADAppState extends State<TencentADApp> {
  @override
  void initState() {
    TencentADPlugin.config(appID: '1109716769').then(
      (_) => SplashAD(
          posID: configID['splashID'],
          callBack: (event, args) {
            switch (event) {
              case SplashADEvent.onNoAD:
              case SplashADEvent.onADDismissed:
                SystemChrome.setEnabledSystemUIOverlays([
                  SystemUiOverlay.top,
                  SystemUiOverlay.bottom,
                ]);
                SystemChrome.setSystemUIOverlayStyle(
                  SystemUiOverlayStyle(statusBarColor: Colors.transparent),
                );
                break;
              default:
            }
          }).showAD(),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.0,
        centerTitle: true,
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        title: Text(
          '腾讯广告',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.values[0],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: Colors.black,
            ),
            onPressed: () {
              showMenu(
                context: context,
                position: RelativeRect.fromLTRB(1.0, 80.0, 0.0, 32.0),
                items: [
                  PopupMenuItem(
                    child: Text('退出'),
                    value: 0,
                  ),
                ],
              ).then((value) {
                switch (value) {
                  case 0:
                    SystemNavigator.pop();
                    exit(0);
                    break;
                  default:
                }
              });
            },
          )
        ],
      ),
      body: GridView.count(
        crossAxisCount: 3,
        children: [
          ItemIcon(
            icon: 'reward_video',
            name: '激励视频广告',
            onTap: () {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => RewardADWidget(
                  configID['rewardID'],
                ),
              );
            },
          ),
          ItemIcon(
            icon: 'interstital_ad',
            name: '插屏广告',
            onTap: () {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => IntersADWidget(
                  configID['intersID'],
                ),
              );
            },
          ),
          ItemIcon(
            icon: 'banner_ad',
            name: '横幅广告',
            onTap: () {
              showModalBottomSheet<void>(
                context: context,
                enableDrag: true,
                builder: (context) {
                  return _buildBanner();
                },
              );
            },
          ),
          ItemIcon(
            icon: 'origin_ad',
            name: '原生广告',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return NativeADPage();
                  },
                ),
              );
            },
          ),
          ItemIcon(
            icon: 'splash_ad',
            name: '闪屏广告',
            onTap: () {
              SplashAD(
                  posID: configID['splashID'],
                  callBack: (event, args) {
                    switch (event) {
                      case SplashADEvent.onNoAD:
                      case SplashADEvent.onADDismissed:
                        SystemChrome.setEnabledSystemUIOverlays([
                          SystemUiOverlay.top,
                          SystemUiOverlay.bottom,
                        ]);
                        SystemChrome.setSystemUIOverlayStyle(
                          SystemUiOverlayStyle(
                              statusBarColor: Colors.transparent),
                        );
                        break;
                      default:
                    }
                  }).showAD();
            },
          ),
        ],
      ),
    );
  }

  // 横幅广告示例
  Widget _buildBanner() {
    final _adKey = GlobalKey<BannerADState>();
    final size = MediaQuery.of(context).size;
    return BannerAD(
      posID: configID['bannerID'],
      key: _adKey,
      callBack: (event, args) {
        switch (event) {
          case BannerEvent.onADClosed:
          case BannerEvent.onADCloseOverlay:
            showMenu(
              context: context,
              position: RelativeRect.fromLTRB(1.0, size.height * .82, 0.0, 0.0),
              items: [
                PopupMenuItem(
                  child: Text('刷新'),
                  value: 0,
                ),
                PopupMenuItem(
                  child: Text('关闭'),
                  value: 1,
                ),
              ],
            ).then((value) {
              switch (value) {
                case 0:
                  _adKey.currentState.loadAD();
                  break;
                case 1:
                  _adKey.currentState.closeAD();
                  Navigator.pop(context);
                  break;
                default:
              }
            });
            break;
          default:
        }
      },
      refresh: true,
    );
  }
}

class ItemIcon extends StatelessWidget {
  const ItemIcon({
    @required this.icon,
    @required this.name,
    @required this.onTap,
  });

  final String icon;
  final String name;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            child: SvgPicture.asset(
              'assets/svg/$icon.svg',
              width: 88.0,
              height: 88.0,
              fit: BoxFit.cover,
            ),
          ),
          Text('$name'),
        ],
      ),
    );
  }
}

class IntersADWidget extends StatefulWidget {
  final String posID;

  IntersADWidget(this.posID);

  @override
  State<StatefulWidget> createState() => IntersADWidgetState();
}

class IntersADWidgetState extends State<IntersADWidget> {
  IntersAD intersAD;

  @override
  void initState() {
    super.initState();
    intersAD = IntersAD(posID: widget.posID, adEventCallback: _adEventCallback);
    intersAD.loadAD();
  }

  @override
  Widget build(BuildContext context) => Container();

  void _adEventCallback(IntersADEvent event, Map params) {
    switch (event) {
      case IntersADEvent.onADReceived:
        intersAD.showAD();
        break;
      case IntersADEvent.onADClosed:
        Navigator.of(context).pop();
        break;
      default:
    }
  }
}

class RewardADWidget extends StatefulWidget {
  final String posID;

  RewardADWidget(this.posID);

  @override
  State<StatefulWidget> createState() => RewardADWidgetState();
}

class RewardADWidgetState extends State<RewardADWidget> {
  RewardAD rewardAD;

  @override
  void initState() {
    super.initState();
    rewardAD = RewardAD(posID: widget.posID, adEventCallback: _adEventCallback);
    rewardAD.loadAD();
  }

  @override
  Widget build(BuildContext context) => Container();

  void _adEventCallback(RewardADEvent event, Map params) {
    switch (event) {
      case RewardADEvent.onADLoad:
        rewardAD.showAD();
        break;
      case RewardADEvent.onADClose:
        Navigator.of(context).pop();
        break;
      default:
    }
  }
}

class NativeADPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _NativeADPageState();
}

class _NativeADPageState extends State<NativeADPage> {
  bool isToogle = true;

  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        centerTitle: true,
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          '腾讯广告',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.values[0],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: Colors.black,
            ),
            onPressed: () {
              showMenu(
                context: context,
                position: RelativeRect.fromLTRB(1.0, 80.0, 0.0, 32.0),
                items: [
                  PopupMenuItem(
                    child: Text(isToogle ? '单个模版+自渲染' : '自渲染&模版消息流'),
                    value: 0,
                  ),
                ],
              ).then((value) {
                switch (value) {
                  case 0:
                    setState(() => isToogle = !isToogle);
                    break;
                  default:
                }
              });
            },
          )
        ],
      ),
      body: isToogle
          ? ListView.builder(
              itemCount: 6,
              physics: BouncingScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                if (index % 2 == 0) {
                  return NativeADWidget(posID: configID['nativeID']);
                }
                return Container(
                  height: 240.0,
                  margin: const EdgeInsets.all(8.0),
                  color: Colors.orangeAccent,
                );
              },
            )
          : NativeRenderWidget(),
    );
  }
}

class NativeRenderWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _NativeRenderWidgetState();
}

class _NativeRenderWidgetState extends State<NativeRenderWidget> {
  double adHeight;
  bool adRemoved = false;
  final _adKey = GlobalKey<NativeADState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: adHeight == null ? 1 : adHeight,
          child: NativeAD(
            key: _adKey,
            posID: configID['nativeID'],
            adEventCallback: (event, args) {
              if (event == NativeADEvent.onLayoutChange && mounted) {
                setState(() {
                  // 根据选择的广告位模板尺寸计算，这里是1280x720
                  adHeight = MediaQuery.of(context).size.width *
                      args['height'] /
                      args['width'];
                  print(args['height']);
                  print(args['width']);
                });
                return;
              }
              if (event == NativeADEvent.onADClosed) {
                setState(() {
                  adRemoved = true;
                });
              }
            },
            refreshOnCreate: true,
            requestCount: 1,
          ),
        ),
      ],
    );
  }
}

Map<String, String> get configID {
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return {
        'appID': '1109716769',
        'splashID': '7020785136977336',
        'bannerID': '9040882216019714',
        'intersID': '2041008945668154',
        'rewardID': '6021002701726334',
        'nativeDIYID': '8041808915486340',
        'nativeID': '7071115139492917',
      };
      break;
    case TargetPlatform.iOS:
      return {
        'appID': '',
        'splashID': '',
        'bannerID': '',
        'intersID': '',
        'rewardID': '',
        'nativeID': '',
      };
      break;
    default:
      return {'': ''};
  }
}
