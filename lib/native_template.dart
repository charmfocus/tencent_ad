import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tencent_ad/o.dart';

class NativeAD extends StatefulWidget {
  const NativeAD({
    Key key,
    this.posID,
    this.width,
    this.height,
    this.requestCount: 5,
    this.adEventCallback,
    this.refreshOnCreate,
  }) : super(key: key);

  final String posID;
  final double width;
  final double height;
  final int requestCount; // 默认请求次数: 5
  final NativeADEventCallback adEventCallback;
  final bool refreshOnCreate;

  @override
  NativeADState createState() => NativeADState();
}

class NativeADState extends State<NativeAD> {
  Size size;
  MethodChannel _methodChannel;

  @override
  Widget build(BuildContext context) {
    Widget view;
    size ??= MediaQuery.of(context).size;
    var width = widget.width == 0 ? size.width : widget.width;
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      view = UiKitView(
        viewType: '$nativeID',
        onPlatformViewCreated: _onPlatformViewCreated,
        creationParams: {'posID': widget.posID, 'count': widget.requestCount},
        creationParamsCodec: StandardMessageCodec(),
      );
    }
    view = AndroidView(
      viewType: '$nativeID',
      onPlatformViewCreated: _onPlatformViewCreated,
      creationParams: {'posID': widget.posID, 'count': widget.requestCount},
      creationParamsCodec: const StandardMessageCodec(),
    );
    return Container(
      height: widget.height ?? 0,
      width: width,
      child: view,
    );

  }

  void _onPlatformViewCreated(int id) {
    this._methodChannel = MethodChannel('$nativeID\_$id');
    this._methodChannel.setMethodCallHandler(_handleMethodCall);
    if (this.widget.refreshOnCreate == true) {
      this.refreshAD();
    }
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    if (widget.adEventCallback != null) {
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
      widget.adEventCallback(event, call.arguments);
    }
  }

  Future<void> closeAD() async {
    if (_methodChannel != null) {
      await _methodChannel.invokeMethod('close');
    }
  }

  Future<void> refreshAD() async {
    if (_methodChannel != null) {
      await _methodChannel.invokeMethod('refresh');
    }
  }
}

class NativeADWidget extends StatefulWidget {
  final String posID;
  final int requestCount;
  final GlobalKey<NativeADState> adKey;
  final NativeADEventCallback adEventCallback;
  final double loadingHeight;

  NativeADWidget({
    GlobalKey<NativeADState> adKey,
    this.posID,
    this.requestCount,
    this.adEventCallback,
    this.loadingHeight: 1.0,
  }) : adKey = adKey ?? GlobalKey();

  @override
  NativeADWidgetState createState() =>
      NativeADWidgetState(height: loadingHeight);
}

class NativeADWidgetState extends State<NativeADWidget> {
  double _height;
  NativeAD _ad;

  NativeADWidgetState({double height}) : _height = height;

  @override
  void initState() {
    super.initState();
    _ad = NativeAD(
      posID: widget.posID,
      key: widget.adKey,
      requestCount: widget.requestCount,
      adEventCallback: _adEventCallback,
      refreshOnCreate: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _height,
      child: _ad,
    );
  }

  void _adEventCallback(NativeADEvent event, dynamic arguments) async {
    if (widget.adEventCallback != null) {
      widget.adEventCallback(event, arguments);
    }
    if (event == NativeADEvent.onLayoutChange && this.mounted) {
      this.setState(() {
        _height = MediaQuery.of(context).size.width *
            arguments['height'] /
            arguments['width'];
      });
      return;
    }
  }
}

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

typedef NativeADEventCallback = Function(NativeADEvent event, Map arguments);
