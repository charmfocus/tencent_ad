import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tencent_ad/tencent_ad.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    TencentADPlugin.config(appID: '1109716769').then(
      (_) => SplashAD('7020785136977336').showAD(),
    );
  } on PlatformException {}
  runApp(TencentADApp());
}

class TencentADApp extends StatefulWidget {
  @override
  _TencentADAppState createState() => _TencentADAppState();
}

class _TencentADAppState extends State<TencentADApp> {
  bool _adClosed = false;
  GlobalKey<UnifiedBannerADState> _adKey = GlobalKey();

  void _adEventCallback(BannerEvent event, dynamic arguments) {
    if (event == BannerEvent.onADClosed) {
      if (this.mounted) {
        this.setState(() {
          _adClosed = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(),
        body: ListView(
          children: <Widget>[
            Column(
              children: <Widget>[
                Container(
                  height: _adClosed ? 0 : UnifiedBannerAD.ratio,
                  child: _adClosed
                      ? Container()
                      : UnifiedBannerAD(
                          '9040882216019714',
                          key: _adKey,
                          adEventCallback: _adEventCallback,
                          refreshOnCreate: true,
                        ),
                ),
                Row(
                  children: <Widget>[
                    RaisedButton(
                      onPressed: () {
                        this.setState(() => this._adClosed = false);
                        _adKey.currentState?.loadAD();
                      },
                      child: Text('刷新横幅'),
                    ),
                    RaisedButton(
                      onPressed: () async {
                        await _adKey.currentState?.closeAD();
                        if (this.mounted) {
                          this.setState(() => _adClosed = true);
                        }
                      },
                      child: Text('关闭横幅'),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 500.0,
              child: NativeExpress(),
            ),
          ],
        ),
      ),
    );
  }
}

class NativeExpress extends StatefulWidget {
  @override
  _NativeExpressState createState() => _NativeExpressState();
}

class _NativeExpressState extends State<NativeExpress> {
  double adHeight;

  bool adRemoved = false;

  GlobalKey<NativeExpressADState> _adKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          Row(
            children: <Widget>[
              RaisedButton(
                onPressed: () {
                  setState(() {
                    adHeight = null;
                    adRemoved = false;
                  });
                  _adKey.currentState?.refreshAD();
                },
                child: Text('刷新消息流'),
              ),
              RaisedButton(
                onPressed: () async {
                  await _adKey.currentState?.closeAD();
                  if (this.mounted) {
                    this.setState(() {
                      adRemoved = true;
                      adHeight = null;
                    });
                  }
                },
                child: Text('关闭消息流'),
              ),
            ],
          ),
          adRemoved
              ? Container()
              : Container(
                  height: adHeight == null ? 1 : adHeight,
                  child: NativeExpressAD(
                    key: _adKey,
                    posID: '8041808915486340',
                    callback: _adEventCallback,
                    refreshOnCreate: true,
                  ),
                ),
          Container(
            height: 200.0,
            color: Colors.accents[0],
          ),
          NativeExpressADWidget('8041808915486340'),
        ],
      ),
    );
  }

  void _adEventCallback(NativeADEvent event, dynamic arguments) async {
    if (event == NativeADEvent.onLayoutChange && this.mounted) {
      this.setState(() {
        // 根据选择的广告位模板尺寸计算，这里是1280x720
        adHeight = MediaQuery.of(context).size.width *
            arguments['height'] /
            arguments['width'];
      });
      return;
    }
    if (event == NativeADEvent.onADClosed) {
      this.setState(() {
        adRemoved = true;
      });
    }
  }
}
