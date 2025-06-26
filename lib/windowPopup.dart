import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WindowPopup extends StatefulWidget {
  const WindowPopup({super.key, required this.createWindowAction});

  final CreateWindowAction createWindowAction;

  @override
  State<WindowPopup> createState() => _WindowPopupState();
}

class _WindowPopupState extends State<WindowPopup> {
  String title = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(mainAxisSize: MainAxisSize.max, children: [
              Expanded(
                child:
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.close))
            ]),
            Expanded(
              child: InAppWebView(
                gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                  Factory<OneSequenceGestureRecognizer>(
                        () => EagerGestureRecognizer(),
                  ),
                },
                windowId: widget.createWindowAction.windowId,
                onTitleChanged: (controller, title) {
                  setState(() {
                    this.title = title ?? '';
                  });
                },
                onCloseWindow: (controller) {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}