import 'dart:convert';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:game_shell_engine/homePage.dart';
import 'package:game_shell_engine/utils/WebControllerUtil.dart';
import 'package:game_shell_engine/webUrl.dart';

void main() async {
  var widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  /// 初始化闪屏页绑定
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  if (!kIsWeb &&
      kDebugMode &&
      defaultTargetPlatform == TargetPlatform.android) {
    await InAppWebViewController.setWebContentsDebuggingEnabled(kDebugMode);
  }

  /// 设置状态栏字体为白色（适用于深色背景）
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // 状态栏透明（可选）
      statusBarIconBrightness: Brightness.light, // Android 状态栏图标为白色
      statusBarBrightness: Brightness.dark, // iOS 状态栏字体为白色
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AppLinks _appLinks = AppLinks();
  var isLoadEnd = false;

  // 刷新页面
  void refreshState({bool refreshWebUrl = false}) {
    setState(() {
      isLoadEnd = true;
    });

    // 需要刷新重新加载webUrl
    if (refreshWebUrl) {
      if (kDebugMode) {
        print('tox refreshState 重新加载webUrl，webController = ${WebControllerUtil().controller}');
      }
      WebControllerUtil().controller?.loadUrl(
        urlRequest: URLRequest(url: WebUri(getRandomWebUrl())),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _initAppLinks(); // 初始化链接监听
  }

  // 初始化链接监听
  void _initAppLinks() async {
    // 1. 监听应用冷启动时的初始链接（如从网页唤起未运行的应用）
    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) {
      _handleUri(initialUri);

      refreshState();
    } else {
      if (kDebugMode) {
        print('tox 手动打开app');
      }
      /// 读取剪切板信息 拿到第一条数据
      /// 判断是否为json且包含info字段
      // 仅获取文本类型的剪贴板数据
      ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
      // 返回文本内容，若剪贴板无文本则为null
      String? clipboardText = data?.text;
      if (clipboardText == null || clipboardText.isEmpty) {
        if (kDebugMode) {
          print("tox 剪贴板为空");
        }
        prefixParams = '';
      } else {
        try {
          // 2. 尝试解析JSON（支持对象/数组，这里统一转为Map，数组可单独处理）
          dynamic jsonResult = jsonDecode(clipboardText);
          if (kDebugMode) {
            print("tox 剪贴板内容类型是否为json = ${ jsonResult is Map<String, dynamic> }");
          }
          // 3. 判断解析结果是否为JSON对象（Map）或数组（List）
          if (jsonResult is Map<String, dynamic>) {
            if (jsonResult.containsKey('info')) {
              prefixParams = 'info=${jsonResult['info']?.toString()}';
            }
          } else {
            prefixParams = '';
          }
        } catch (e) {
          // 解析失败（非JSON格式）
          prefixParams = '';
        }
      }

      refreshState();
    }

    // 2. 监听应用已启动（热启动）时的链接
    _appLinks.uriLinkStream.listen((uri) {
      _handleUri(uri);

      refreshState(refreshWebUrl: true);
    });
  }

  // 处理链接逻辑（解析参数、跳转页面等）
  void _handleUri(Uri uri) {
    if (kDebugMode) {
      print('tox 唤起链接: ${uri.toString()}');
    }

    // 解析链接参数（示例：ccgameapp://open.native.app/page?page=detail&id=123）
    final info = uri.queryParameters['info']; // 取值
    if (info != null) {
      prefixParams = 'info=$info';
    }

    // 根据参数执行跳转
    // if (page == 'detail' && id != null) {
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //       builder: (context) => DetailPage(id: id),
    //     ),
    //   );
    // }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CC Game',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      navigatorObservers: [FlutterSmartDialog.observer],
      builder: FlutterSmartDialog.init(),
      home: isLoadEnd ? const HomePage(title: 'CC Game') : const CircularProgressIndicator(),
    );
  }
}
