const String webUrl = 'https://new.ccgametest.live';
const String jpushAppKey = '8b68b9303424eadca9e99ae9';

/// 默认允许打开的链接
const urlWhiteList = [
  'https://www.kkgametop.xyz',
  'http://192.168.18.182',
  'https://reimagined-memory-jjgwj4xwqgxrfq4p4-8080.app.github.dev',
  'https://accounts.google.com'
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