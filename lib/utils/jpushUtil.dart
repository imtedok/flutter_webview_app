import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_plugin_engagelab/flutter_plugin_engagelab.dart';
import 'package:game_shell_engine/webUrl.dart';

import 'WebControllerUtil.dart';

class JPushUtil {
  static JPushUtil? _singleton;

  factory JPushUtil() => _singleton ??= JPushUtil._();

  JPushUtil._();

  /// jpush官网配置的app key
  /// 测试
  // static const JPUSH_APP_KEY = 'f2ce36eb5892b8c954a301e7';
  /// 线上
  static const JPUSH_APP_KEY = jpushAppKey;

  Map<String, dynamic>? needPushMsg;

  late String registrationID;
  Timer? timer; // 使用可空的 Timer，方便取消
  void initTimer() {
    timer?.cancel();
    timer = null;
  }

  Future<String> _getRegistrationID() async {
    registrationID = await FlutterPluginEngagelab.getRegistrationId();
    if (registrationID.isEmpty) {
      initTimer();
      timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
        if (kDebugMode) {
          print('轮询执行: ${DateTime.now()}');
        }
        // 再次获取rgid
        _getRegistrationID();
      });
      return '';
    } else {
      initTimer();
    }
    initBadgeCount(null);
    FlutterPluginEngagelab.printMy(
        "flutter get registration id : $registrationID");
    /*SmartDialog.show(builder: (context) {
      return Container(
        height: 80,
        width: 220,
        decoration: BoxDecoration(
          color: Colors.blueGrey,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text('推送id: $registrationID',
            style: TextStyle(color: Colors.white)),
      );
    }, onDismiss: () {
      var msg = {
        "content": "您有一份饿了么外卖即将送达，请注意查收！",
        "contentType": "",
        "messageId": "676992463",
        "platform": 0,
        "title": "重磅通知",
        "extras": {"foodName": "肯德基大盘鸡", "price": "100"}
      };
      JPushUtil().sendLocalMessage(msg);
    });*/
    return registrationID;
  }

  /// 初始化极光推送
  Future<void> initJPush() async {
    FlutterPluginEngagelab.configDebugMode(true);
    FlutterPluginEngagelab.addEventHandler(
        onMTCommonReceiver: (Map<String, dynamic> message) async {
      /*message:反回的事件数据
            message["event_name"]: 为事件类型
              android:
                "onNotificationStatus":应用通知开关状态回调,内容类型为boolean，true为打开，false为关闭
                "onConnectStatus":长连接状态回调,内容类型为boolean，true为连接
                "onNotificationArrived":通知消息到达回调，内容为通知消息体
                "onNotificationClicked":通知消息点击回调，内容为通知消息体
                "onNotificationDeleted":通知消息删除回调，内容为通知消息体
                "onCustomMessage":自定义消息回调，内容为通知消息体
                "onPlatformToken":厂商token消息回调，内容为厂商token消息体
                "onTagMessage":tag操作回调
                "onAliasMessage":alias操作回调
                "onNotificationUnShow":在前台，通知消息不显示回调（后台下发的通知是前台信息时）
                "onInAppMessageShow": 应用内消息展示
                "onInAppMessageClick": 应用内消息点击
              ios:
                "willPresentNotification":通知消息到达回调，内容为通知消息体
                "didReceiveNotificationResponse":通知消息点击回调，内容为通知消息体
                "networkDidReceiveMessage":自定义消息回调，内容为通知消息体
                "networkDidLogin":登陆成功
                "checkNotificationAuthorization":检测通知权限授权情况
                "addTags":添加tag回调
                "setTags":设置tag回调
                "deleteTags":删除tag回调
                "cleanTags":清除tag回调
                "getAllTags":获取tag回调
                "validTag":校验tag回调
                "setAlias":设置Alias回调
                "deleteAlias":删除Alias回调
                "getAlias":获取Alias回调
                "deleteAlias":删除Alias回调
                "onInAppMessageShow": 应用内消息展示
                "onInAppMessageClick": 应用内消息点击
                "onNotiInMessageShow": 增强提醒展示
                "onNotiInMessageClick": 增强提醒点击
                "onSetUserLanguage": 设置用户语言
                "onReceiveDeviceToken": 收到deviceToken
            message["event_data"]: 为对应内容
          */
      var formatMessage = Map.castFrom(message);
      String eventName = formatMessage["event_name"].toString();
      Map<String, dynamic> eventData = jsonDecode(formatMessage["event_data"]);
      if (kDebugMode) {
        print("flutter onMTCommonReceiver eventData = $eventData-${eventData.runtimeType}");
      }

      if (eventName == "onNotificationArrived" ||
          eventName == "willPresentNotification") {
        // 推送通知栏新消息，tips：当通知栏被关闭时手机状态栏不会出现通知消息，只有app运行位于前台时会触发此回调
        // 安卓收到的消息数据：{event_name: onNotificationArrived, event_data: {"badge":1,"bigPicture":"","bigText":"","builderId":0,"category":"","channelId":"","content":"恭喜您中奖了","defaults":0,"extras":{"name":"tox"},"inbox":[],"intentSsl":"","intentUri":"","largeIcon":"","messageId":"558497131","notificationId":558497131,"overrideMessageId":"","platform":0,"platformMessageId":"","priority":0,"smallIcon":"","sound":"","style":0,"title":"通知"}}
        // 苹果收到的消息数据：{event_name: willPresentNotification, event_data: {"_j_msgid":561712896,"_j_business":1,"_j_engagel_cloud":1,"_j_uid":40011962683,"aps":{"mutable-content":1,"alert":{"title":"重要通知","body":"您有一份大餐即将送达，请注意查收！！！"},"badge":2,"sound":"default"},"foodName":"大盘鸡","inapp":{"inapp_end_time":1750485066112},"price":"200","extras":{"inapp":{"inapp_end_time":1750485066112},"_j_engagel_cloud":1,"price":"200","foodName":"大盘鸡"}}}
        // _doNext(eventData);
        // JPushUtil().sendLocalMessage(eventData);
        needPushMsg = eventData;
        WebControllerUtil().evaluateJavascript();
      } else if (eventName == "onNotificationClicked" ||
          eventName == "didReceiveNotificationResponse") {
        // 点击通知栏消息，在此时通常可以做一些页面跳转等
        // _doNext(eventData);
        needPushMsg = eventData;
        WebControllerUtil().evaluateJavascript();
      } else if (eventName == "onCustomMessage" ||
          eventName == "networkDidReceiveMessage") {
        // todo 自定义消息回调，在此时通常可以做一些页面跳转等
        // _doNext(eventData);
        // JPushUtil().sendLocalMessage(eventData);
      } else {}
    });

    if (Platform.isIOS) {
      FlutterPluginEngagelab.setUnShowAtTheForegroundIos(false);
      FlutterPluginEngagelab.initIos(
        appKey: JPUSH_APP_KEY,
        channel: "testChannel",
      );
    } else if (Platform.isAndroid) {
      FlutterPluginEngagelab.configAppKeyAndroid(JPUSH_APP_KEY);
      FlutterPluginEngagelab.initAndroid();
    }

    // todo 暂时注释掉
    await _getRegistrationID();
  }

  void _doNext(Map<String, dynamic> data) {
    if (kDebugMode) {
      print('jpushUtil.dart doNext = ${data.toString()}');
    }
  }

  void initBadgeCount(int? count) {
    if (count == null || count == 0) {
      FlutterPluginEngagelab.resetNotificationBadge();
    } else {
      FlutterPluginEngagelab.setNotificationBadge(count);
    }
  }

  /// PRIORITY与IMPORTANCE 相互转换关系
  /// PRIORITY_MIN = -2 对应 IMPORTANCE_MIN = 1;
  /// PRIORITY_LOW = -1; 对应 IMPORTANCE_LOW = 2;
  /// PRIORITY_DEFAULT = 0; 对应 IMPORTANCE_DEFAULT = 3;
  /// PRIORITY_HIGH = 1; 对应 IMPORTANCE_HIGH = 4;
  /// PRIORITY_MAX = 2; 对应 IMPORTANCE_MAX = 5;
  void sendLocalMessage(Map<String, dynamic> msg) {
    var fireDate = DateTime.fromMillisecondsSinceEpoch(
        DateTime.now().millisecondsSinceEpoch + 3000);
    var localNotification = LocalNotification(
        id: int.tryParse(msg["messageId"].toString()),
        title: msg["title"].toString(),
        content: msg["content"].toString(),
        fireTime: fireDate,
        // iOS only
        subtitle: '',
        // iOS only
        category: 'local',
        // Android only
        priority: 2,
        // Android only
        badge: 1,
        // iOS only
        extra: (msg["extras"] ?? {}) as Map<String, String>);
    FlutterPluginEngagelab.sendLocalNotification(localNotification);
  }
}
