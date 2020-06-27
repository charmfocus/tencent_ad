import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'o.dart';

class SplashAdView extends StatefulWidget {
  final String posID;
  final SplashADEventCallback callback;

  const SplashAdView({Key key, this.posID, this.callback}) : super(key: key);

  @override
  _SplashAdViewState createState() => _SplashAdViewState();
}

class _SplashAdViewState extends State<SplashAdView> {
  Size size;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    size ??= MediaQuery.of(context).size;

    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: 'plugins.tencent.ads/splashadview',
        onPlatformViewCreated: (id) {
          var methodChannel = MethodChannel('$splashID\_$id');
          methodChannel.setMethodCallHandler(_handleMethodCall);
          methodChannel.invokeMethod('loadAd', {
            'posID': widget.posID,
          });
        },
      );
    }
    return Container();
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    if (widget.callback != null) {
      SplashADEvent event;
      switch (call.method) {
        case 'onADExposure':
          event = SplashADEvent.onADExposure;
          break;
        case 'onADPresent':
          event = SplashADEvent.onADExposure;
          break;
        case 'onADLoaded':
          event = SplashADEvent.onADLoaded;
          break;
        case 'onADClicked':
          event = SplashADEvent.onADClicked;
          break;
        case 'onADTick':
          event = SplashADEvent.onADTick;
          break;
        case 'onADDismissed':
          event = SplashADEvent.onADDismissed;
          break;
        case 'onNoAD':
          event = SplashADEvent.onNoAD;
          break;
      }
      widget.callback(event, call.arguments);
    }
  }
}
