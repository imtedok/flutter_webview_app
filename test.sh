#!/bin/bash

echo "Update webUrl.dart..."

WEB_URL="https://new.ccgametest.live?ch=3&type=1"
JPUSH_APP_KEY="8b68b9303424eadca9e99ae9"

REAL_WEB_URL=$(echo "$WEB_URL" | sed 's/&/\\&/g')  # 自动将 & 转义为 \&

sed -e "s#const String webUrl = '[^']*'#const String webUrl = '${REAL_WEB_URL}'#g" \
    -e "s#const String jpushAppKey = '[^']*'#const String jpushAppKey = '${JPUSH_APP_KEY}'#g" \
    lib/webUrl.dart > lib/webUrl.dart.tmp && mv lib/webUrl.dart.tmp lib/webUrl.dart

echo "Verifying updated variables..."
cat lib/webUrl.dart