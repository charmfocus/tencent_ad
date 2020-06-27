import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'o.dart';
import 'tencent_ad.dart';

class SplashAD {
  MethodChannel _methodChannel;

  final String posID;
  final SplashADEventCallback callBack;

  SplashAD({@required this.posID, this.callBack}) {
    _methodChannel = MethodChannel('$splashID\_$posID');
    _methodChannel.setMethodCallHandler(_handleMethodCall);
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    if (callBack != null) {
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
      callBack(event, call.arguments);
    }
  }

  Future<void> showAD() async {
    await TencentADPlugin.channel.invokeMethod('showSplash', {'posID': posID});
  }
}
