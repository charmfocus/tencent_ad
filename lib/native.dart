import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'o.dart';

enum NativeADEvent {
  onLayoutChange,
  onNoAD,
  onADLoaded,
  onRenderFail,
  onRenderSuccess,
  onADExposure,
  onADClicked,
  onADClosed,
  onADLeftApplication,
  onADOpenOverlay,
  onADCloseOverlay,
}

typedef NativeADCallback = Function(NativeADEvent event, dynamic arguments);

class NativeExpressAD extends StatefulWidget {
  NativeExpressAD({
    Key key,
    this.posID,
    this.requestCount: 5,
    this.callback,
    this.refreshOnCreate,
  }) : super(key: key);

  final String posID;
  final int requestCount; // 广告计数请求，默认值是5
  final NativeADCallback callback;
  final bool refreshOnCreate;

  @override
  NativeExpressADState createState() => NativeExpressADState();
}

class NativeExpressADState extends State<NativeExpressAD> {
  MethodChannel _methodChannel;

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: '$nativeID',
        onPlatformViewCreated: _onPlatformViewCreated,
        creationParams: {'posID': widget.posID, 'count': widget.requestCount},
        creationParamsCodec: StandardMessageCodec(),
      );
    }
    return AndroidView(
      viewType: '$nativeID',
      onPlatformViewCreated: _onPlatformViewCreated,
      creationParams: {'posID': widget.posID, 'count': widget.requestCount},
      creationParamsCodec: const StandardMessageCodec(),
    );
  }

  void _onPlatformViewCreated(int id) {
    _methodChannel = MethodChannel('$nativeID\_$id');
    _methodChannel.setMethodCallHandler(_handleMethodCall);
    if (widget.refreshOnCreate == true) {
      refreshAD();
    }
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    if (widget.callback != null) {
      NativeADEvent event;
      switch (call.method) {
        case 'onLayoutChange':
          event = NativeADEvent.onLayoutChange;
          break;
        case 'onNoAD':
          event = NativeADEvent.onNoAD;
          break;
        case 'onADLoaded':
          event = NativeADEvent.onADLoaded;
          break;
        case 'onRenderFail':
          event = NativeADEvent.onRenderFail;
          break;
        case 'onRenderSuccess':
          event = NativeADEvent.onRenderSuccess;
          break;
        case 'onADExposure':
          event = NativeADEvent.onADExposure;
          break;
        case 'onADClicked':
          event = NativeADEvent.onADClicked;
          break;
        case 'onADClosed':
          event = NativeADEvent.onADClosed;
          break;
        case 'onADLeftApplication':
          event = NativeADEvent.onADLeftApplication;
          break;
        case 'onADOpenOverlay':
          event = NativeADEvent.onADOpenOverlay;
          break;
        case 'onADCloseOverlay':
          event = NativeADEvent.onADCloseOverlay;
          break;
      }
      widget.callback(event, call.arguments);
    }
  }

  Future<void> closeAD() async => await _methodChannel.invokeMethod('close');

  Future<void>refreshAD() async =>
      await _methodChannel.invokeMethod('refresh');
}

class NativeExpressADWidget extends StatefulWidget {
  final String posID;
  final int requestCount;
  final GlobalKey<NativeExpressADState> adKey;
  final NativeADCallback adEventCallback;
  final double loadingHeight;

  NativeExpressADWidget(
    this.posID, {
    GlobalKey<NativeExpressADState> adKey,
    this.requestCount,
    this.adEventCallback,
    this.loadingHeight: 1.0,
  }) : adKey = adKey ?? GlobalKey();

  @override
  NativeExpressADWidgetState createState() =>
      NativeExpressADWidgetState(height: loadingHeight);
}

class NativeExpressADWidgetState extends State<NativeExpressADWidget> {
  double _height;
  NativeExpressAD _nativeAD;

  NativeExpressADWidgetState({double height}) : _height = height;

  @override
  void initState() {
    super.initState();
    _nativeAD = NativeExpressAD(
      key: widget.adKey,
      posID: widget.posID,
      requestCount: widget.requestCount,
      callback: _adEventCallback,
      refreshOnCreate: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _height,
      child: _nativeAD,
    );
  }

  void _adEventCallback(NativeADEvent event, dynamic arguments) async {
    if (widget.adEventCallback != null) {
      widget.adEventCallback(event, arguments);
    }
    if (event == NativeADEvent.onLayoutChange && mounted) {
      setState(() {
        _height = MediaQuery.of(context).size.width *
            arguments['height'] /
            arguments['width'];
      });
      return;
    }
  }
}