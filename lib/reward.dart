import 'package:flutter/services.dart';
import 'package:tencent_ad/o.dart';
import 'package:tencent_ad/tencent_ad.dart';

class RewardAD {
  final String posID;
  final RewardADCallback adEventCallback;

  MethodChannel _methodChannel;

  RewardAD({this.posID, this.adEventCallback}) {
    _methodChannel = MethodChannel('$rewardID\_$posID');
    _methodChannel.setMethodCallHandler(_handleCall);
    TencentADPlugin.toastRewardAD(posID: posID);
  }

  Future<void> _handleCall(MethodCall call) async {
    if (adEventCallback != null) {
      RewardADEvent event;
      switch (call.method) {
        case 'onADExpose':
          event = RewardADEvent.onADExpose;
          break;
        case 'onADClick':
          event = RewardADEvent.onADClick;
          break;
        case 'onVideoCached':
          event = RewardADEvent.onVideoCached;
          break;
        case 'onReward':
          event = RewardADEvent.onReward;
          break;
        case 'onADClose':
          event = RewardADEvent.onADClose;
          break;
        case 'onADLoad':
          event = RewardADEvent.onADLoad;
          break;
        case 'onVideoComplete':
          event = RewardADEvent.onVideoComplete;
          break;
        case 'onADShow':
          event = RewardADEvent.onADShow;
          break;
        case 'onError':
          event = RewardADEvent.onError;
          break;
      }
      adEventCallback(event, call.arguments);
    }
  }

  Future<void> loadAD() async {
    await _methodChannel.invokeMethod('load');
  }

  Future<void> showAD() async {
    await _methodChannel.invokeMethod('show');
  }
}

typedef RewardADCallback = Function(RewardADEvent event, Map args);

enum RewardADEvent {
  onADExpose,
  onADClick,
  onVideoCached,
  onReward,
  onADClose,
  onADLoad,
  onVideoComplete,
  onADShow,
  onError,
}
