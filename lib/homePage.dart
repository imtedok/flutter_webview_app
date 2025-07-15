import 'dart:io';

import 'package:draggable_float_widget/draggable_float_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:game_shell_engine/utils/jpushUtil.dart';
import 'package:game_shell_engine/windowPopup.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey webViewKey = GlobalKey();
  late InAppWebViewController _controler;
  bool _isVisibleProgress = true;
  double currentProgress = 0.0;

  PullToRefreshController? pullToRefreshController;
  PullToRefreshSettings pullToRefreshSettings = PullToRefreshSettings(
    enabled: true,
    color: Color.fromARGB(255, 65, 34, 144),
  );
  bool pullToRefreshEnabled = true;

  @override
  void initState() {
    super.initState();
    // 在页面构建完成后执行
    WidgetsBinding.instance.addPostFrameCallback((_) {
      /// 初始化极光推送国际版
      JPushUtil().initJPush();
    });
    pullToRefreshController = kIsWeb
        ? null
        : PullToRefreshController(
            settings: pullToRefreshSettings,
            onRefresh: () async {
              await _controler.reload();
            },
          );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        /// 已处理弹出则直接返回
        if (didPop) return;

        if (await _controler.canGoBack()) {
          _controler.goBack();
        } else {
          if (mounted) {
            /// 手动触发返回
            if (Platform.isAndroid) {
              SystemNavigator.pop();
            } else if (Platform.isIOS) {
              exit(0);
            }
          }
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                /// 渐变颜色
                colors: [
                  Color.fromARGB(255, 65, 34, 144),
                  Color.fromARGB(255, 60, 34, 140)
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: InAppWebView(
                      key: webViewKey,
                      initialUrlRequest: URLRequest(
                        /// WebUri('https://reimagined-memory-jjgwj4xwqgxrfq4p4-8080.app.github.dev/')
                        /// WebUri('http://192.168.18.182')
                        /// WebUri('https://www.kkgametop.xyz')
                        url: WebUri('https://www.kkgametop.xyz'),
                      ),
                      initialSettings: InAppWebViewSettings(
                        javaScriptEnabled: true,
                        allowsBackForwardNavigationGestures: true,
                        javaScriptCanOpenWindowsAutomatically: true,
                        supportMultipleWindows: true,
                        mediaPlaybackRequiresUserGesture: false,
                        allowsInlineMediaPlayback: true,
                        // 允许不安全请求（如http）
                        allowUniversalAccessFromFileURLs: true,
                        // 允许混合内容 (HTTP/HTTPS)，解决在android手机上网址访问（http跳转链接、http图片链接等）不了的问题
                        mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
                      ),
                      pullToRefreshController: pullToRefreshController,
                      onWebViewCreated: (controller) async {
                        _controler = controller;

                        /// 网页 JS 调用 flutter 方法，主动发送数据给 flutter，同时 flutter 处理数据后可以再发送响应数据给 JS
                        controller.addJavaScriptHandler(
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
                      },
                      onLoadStop: (controller, url) async {
                        /// 链接加载完时回调
                        /// 同时关掉闪屏页
                        FlutterNativeSplash.remove();
                        pullToRefreshController?.endRefreshing();

                        /// flutter 主动调用 JS 中定义的全局方法
                        /*await controller.evaluateJavascript(
                            source: '''
                            if (window.nativeCallJs) {
                              window.nativeCallJs("Hello from Flutter");
                            }
                        ''');*/
                      },
                      onReceivedError: (controller, request, error) {
                        /// 链接加载出错时回调
                        /// 同时关掉闪屏页
                        FlutterNativeSplash.remove();
                        pullToRefreshController?.endRefreshing();
                      },
                      onProgressChanged: (controller, progress) {
                        if (kDebugMode) {
                          print('progress = $progress');
                        }

                        setState(() {
                          currentProgress = double.parse(NumberFormat("#.##").format(progress / 100));
                          _isVisibleProgress = progress < 100;
                        });

                        if (progress == 100) {
                          pullToRefreshController?.endRefreshing();
                        }
                      },
                      shouldOverrideUrlLoading:
                          (controller, navigationAction) {
                        if (kDebugMode) {
                          print(
                              'navigationAction = ${navigationAction.toString()}');
                        }
                        final uri = navigationAction.request.url;
                        if ((uri?.toString().startsWith('https://www.kkgametop.xyz') ??false)
                          || (uri?.toString().startsWith('http://192.168.18.182') ??false)
                          || (uri?.toString().startsWith('https://reimagined-memory-jjgwj4xwqgxrfq4p4-8080.app.github.dev') ??false)) {
                          /// 放行
                          return Future(
                                () => NavigationActionPolicy.ALLOW,
                          );
                        }

                        /// 禁止网址打开
                        return Future(
                              () => NavigationActionPolicy.CANCEL,
                        );
                      },
                      onCreateWindow: (controller, createWindowAction) async {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return WindowPopup(
                                createWindowAction: createWindowAction);
                          },
                        );
                        return true;
                      },
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Visibility(
                      visible: _isVisibleProgress,
                      child: SizedBox(
                        height: 2,
                        child: LinearProgressIndicator(
                          value: currentProgress,
                          color: Color.fromARGB(255, 65, 34, 144),
                          backgroundColor: Colors.white70,
                        ),
                      ),
                    ),
                  ),
                  DraggableFloatWidget(
                    width: 48,
                    height: 48,
                    // eventStreamController: eventStreamController,
                    config: DraggableFloatWidgetBaseConfig(
                      isFullScreen: false,
                      initPositionYInTop: false,
                      initPositionYMarginBorder: 50,
                      borderBottom: 50 + defaultBorderWidth,
                    ),
                    onTap: () async {
                      await _controler.reload();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(360),
                      ),
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(5),
                      child: Icon(Icons.refresh_rounded, color: Colors.white, size: 32),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
