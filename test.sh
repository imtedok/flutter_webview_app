#!/bin/bash

echo "Update webUrl.dart..."

# 定义要设置的新值
NEW_WEB_URL="https://www.baidu.com"
NEW_JPUSH_KEY="0000011111aaaaabbbbbb"

# 更精确的匹配，包括const String前缀
sed -e "s#const String webUrl = '[^']*'#const String webUrl = '$NEW_WEB_URL'#g" \
    -e "s#const String jpushAppKey = '[^']*'#const String jpushAppKey = '$NEW_JPUSH_KEY'#g" \
    lib/webUrl.dart > lib/webUrl.dart.tmp && mv lib/webUrl.dart.tmp lib/webUrl.dart

echo "Verifying updated variables..."
cat lib/webUrl.dart