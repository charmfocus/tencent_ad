const pluginID = 'tencent_ad';
const bannerID = '$pluginID/banner';
const splashID = '$pluginID/splash';
const intersID = '$pluginID/inters';
const rewardID = '$pluginID/reward';
const nativeID = '$pluginID/native';
const nativeDIYID = '$pluginID/native_diy';

enum SplashADEvent {
  onADExposure,
  onADPresent,
  onADLoaded,
  onADClicked,
  onADTick,
  onADDismissed,
  onNoAD,
}

typedef SplashADEventCallback = Function(
    SplashADEvent event, dynamic arguments);
