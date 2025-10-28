import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:game_shell_engine/homePage.dart';

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
    }

    // 2. 监听应用已启动（热启动）时的链接
    _appLinks.uriLinkStream.listen((uri) {
      _handleUri(uri);
    });
  }

  // 处理链接逻辑（解析参数、跳转页面等）
  void _handleUri(Uri uri) {
    if (kDebugMode) {
      print('唤起链接: ${uri.toString()}');
    }

    // 解析链接参数（示例：ccgameapp://open.native.app/page?page=detail&id=123）
    // final path = uri.path; // 取值：/page
    // final page = uri.queryParameters['page']; // 取值：detail
    // final id = uri.queryParameters['id']; // 取值：123

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
      home: const HomePage(title: 'CC Game'),
    );
  }
}
