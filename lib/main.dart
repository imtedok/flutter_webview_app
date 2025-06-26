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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KK Game',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      navigatorObservers: [FlutterSmartDialog.observer],
      builder: FlutterSmartDialog.init(),
      home: const HomePage(title: 'KK Game'),
    );
  }
}
