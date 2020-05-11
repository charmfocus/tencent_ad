import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:tencent_ad/o.dart';
export 'tencent_ad.dart';
export 'native.dart';
export 'splash.dart';
export 'banner.dart';
export 'inters.dart';
export 'reward.dart';

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
}
