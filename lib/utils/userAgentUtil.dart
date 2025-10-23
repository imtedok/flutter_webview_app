import 'dart:io';

/// 由于Google 登录接口会校验请求的 User-Agent（用户代理），
/// 而 Flutter 内置 WebView 的默认 User-Agent 被 Google 判定为 “非标准浏览器 / 自动化工具”，属于政策禁止的访问来源
///
/// 修改 WebView 的 User-Agent，模拟标准浏览器
String getUserAgent() {
  var userAgent = Platform.isAndroid
      ? "Mozilla/5.0 (Linux; Android 13; SM-G998B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0.0.0 Mobile Safari/537.36"
      : "Mozilla/5.0 (iPhone; CPU iPhone OS 16_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.5 Mobile/15E148 Safari/604.1";
  return userAgent;
}