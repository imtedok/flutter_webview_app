import 'dart:math';
import 'package:flutter/foundation.dart';

const String webUrl = 'https://blockurl.lol';
const String jpushAppKey = '8b68b9303424eadca9e99ae9';
var prefixParams = '';

/// 当 webUrl 是由多个域名以逗号,隔开时 随机取一个域名地址加载
String getRandomWebUrl() {
  // 判断是否包含逗号
  if (webUrl.contains(',')) {
    // 分割成数组
    List<String> urlList = webUrl.split(',');
    // 随机取一个元素（确保数组不为空）
    if (urlList.isNotEmpty) {
      var url = urlList[Random().nextInt(urlList.length)];
      if (kDebugMode) {
        print('tox getRandomWebUrl url = ${url.toString()}, prefixParams = $prefixParams');
      }
      return url.contains('?') ? '$url&$prefixParams' : '$url?$prefixParams';
    }
  }

  if (kDebugMode) {
    print('tox getRandomWebUrl webUrl = ${webUrl.toString()}, prefixParams = $prefixParams');
  }
  // 如果没有逗号或分割后为空，直接返回原字符串
  return webUrl.contains('?') ? '$webUrl&$prefixParams' : '$webUrl?$prefixParams';
}

/// 默认允许打开的链接
const urlWhiteList = [
  'https://www.kkgametop.xyz',
  'http://192.168.18.182',
  'https://reimagined-memory-jjgwj4xwqgxrfq4p4-8080.app.github.dev',
  // google 登录需要
  'https://accounts.google.com',
  // google 登录需要
  'https://accounts.youtube.com'
];

/// 判断 URL 是否以白名单中的任一链接开头
bool isUrlInWhiteList(String? url) {
  if (url == null || url.isEmpty) return false; // 空 URL 直接返回 false
  // 遍历白名单，检查 URL 是否以列表中的某个前缀开头
  for (String prefix in urlWhiteList) {
    if (url.startsWith(prefix)) {
      return true; // 匹配的前缀，返回 true
    }
  }
  return false; // 无匹配，返回 false
}