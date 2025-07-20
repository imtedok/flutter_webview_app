import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:game_shell_engine/utils/jpushUtil.dart';

class WebControllerUtil {
  static WebControllerUtil? _singleton;

  factory WebControllerUtil() => _singleton ??= WebControllerUtil._();

  WebControllerUtil._();

  InAppWebViewController? controller;
  bool isWebViewCreated = false;
  bool isUrlLoadStop = false;

  void initWebFields(InAppWebViewController webController, bool isCreated) {
    controller = webController;
    isWebViewCreated = isCreated;
  }

  /// 网页 JS 调用 flutter 方法，主动发送数据给 flutter，同时 flutter 处理数据后可以再发送响应数据给 JS
  void addJavaScriptHandler() {
    controller?.addJavaScriptHandler(
      handlerName: 'sendMessageToNative',
      callback: (arguments) {
        if (kDebugMode) {
          print("JS called Flutter: $arguments");
        }
        if (arguments.isNotEmpty) {
          if (kDebugMode) {
            print("JS called Flutter: ${arguments[0]['type']}");
          }
          if (arguments[0]['type'] == 'NativeInfo') {
            return {
              "status": "000000",
              "received": {
                'regId': JPushUtil().registrationID,
                'platform': Platform.operatingSystem
              }
            };
          }
        }

        return {"status": "000000", "received": null};
      },
    );
  }

  /// flutter 主动调用 JS 中定义的全局方法
  Future<void> evaluateJavascript() async {
    final jsonData = JPushUtil().needPushMsg;
    if (jsonData == null) {
      return;
    }
    if (isUrlLoadStop) {
      String jsonString = jsonEncode(jsonData);
      JPushUtil().needPushMsg = null;
      await controller?.evaluateJavascript(
          source: '''
            try {
              const data = JSON.parse('${_escapeJsonString(jsonString)}');
              if (typeof window.nativeCallJs === 'function') {
                window.nativeCallJs(data);
              } else {
                console.log('Received from Flutter:', data);
              }
            } catch (e) {
              console.error('Error parsing JSON from Flutter:', e);
            }
          '''
      );
    }
  }

  // 转义JSON字符串中的特殊字符
  String _escapeJsonString(String json) {
    return json
        .replaceAll(r'\', r'\\')
        .replaceAll(r"'", r"\'")
        .replaceAll(r'"', r'\"')
        .replaceAll(r'$', r'\$')
        .replaceAll(r'\n', r'\\n')
        .replaceAll(r'\r', r'\\r')
        .replaceAll(r'\t', r'\\t');
  }
}
