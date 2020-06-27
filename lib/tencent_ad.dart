import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tencent_ad/o.dart';

export 'banner.dart';
export 'inters.dart';
export 'native_render.dart';
export 'native_template.dart';
export 'o.dart';
export 'reward.dart';
export 'splash.dart';
export 'splash_ad_view.dart';
export 'tencent_ad.dart';

class TencentADPlugin {
  static const MethodChannel channel = const MethodChannel(pluginID);

  static Future<bool> config({@required String appID}) async =>
      await channel.invokeMethod('config', {'appID': appID});

  static Future<String> get tencentADVersion async {
    final String version = await channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<bool> toastIntersAD({@required String posID}) async {
    return await channel.invokeMethod('loadIntersAD', {'posID': posID});
  }

  static Future<bool> toastRewardAD({@required String posID}) async {
    return await channel.invokeMethod('loadRewardAD', {'posID': posID});
  }

  static Future<bool> createNativeRender({@required String posID}) async {
    return await channel.invokeMethod('loadNativeRender', {'posID': posID});
  }
}
